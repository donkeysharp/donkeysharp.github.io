---
title: "Análisis De Video En Busca De Supuesto Malware"
url: post/analisis-video-evo
date: 2019-11-26T13:08:36-04:00
draft: false
---

Hola, durante los meses de Octubre y Noviembre sucedieron diferentes conflictos sociales y políticos en Bolivia, esta entrada no es tanto para discutir el tema político, es más será una entrada 100% técnica pero se encuentra relacionada con estos hechos.

La anterior semana una gran cantidad de clientes de un ISP local recibieron un SMS con un link de `bit.ly` a un video MP4 en Dropbox que después fue dado de baja.

![](/img/vid-analysis-link-video.png)
<!-- video con el link del video original -->

Este video que fue viral no solo por SMS sino en redes sociales y medios de comunicación locales, mostraba la llamada que en la que [un dirigente local habla](https://www.eldeber.com.bo/157244_video-que-registra-una-llamada-entre-evo-morales-y-un-dirigente-fue-encontrado-en-el-desbloqueo-en-t) con [Evo Morales](https://es.wikipedia.org/wiki/Evo_Morales).

Corrieron rumores de que el video era un malware o era utilizado para hacer tracking de las personas que lo abriesen, la verdad no suelo tirar mucha bola a eso, pero esta vez me interesó porque días atrás Facebook habia notificado una falla de seguridad de Stack Buffer Overflow que posiblemente podría generar RCE en la aplicación de Whatsapp justamente con un video MP4 malicioso!. Este es el [link](https://www.facebook.com/security/advisories/cve-2019-11931) de la alerta de seguridad.

Bueno, me dió mucha curiosidad ver que había o si efectivamente había algo malicioso en ese video o simplemente era spam. De entrada sabía que aprendería varias cosas porque muy poca idea tenía de como podría analizar si el video era malicioso o no y bueno ya con el video que lo enviaron a un grupo público de chat, mis amigos [Gonzalo](https://twitter.com/lorddemon) y [Cristhian](https://twitter.com/crhystamil) me dijeron que ponga una entrada en mi blog sobre lo que encuentre y de no encontrar nada que hable sobre los ángulos de grabación del video XD. Bueno el resto del blog será sobre lo que encontré y aprendí. Gracias por animarme a investigar muchachos, me divertí mucho.

## El video
El video justamente era un archivo mp4 llamado `evo-telefono.mp4` con este sha512:

```plaintext
a378c367e3c9a4be3ca639822fe79adf75aaa30ba25ca97ff8f6eb3945d36ed9eb160703ed611ecfe5fdc448c6a099e8af3a74a2c7078695db9c258a25800246
```

Primeramente verificar que efectivamente es un mp4 viendo los [magic numbers](https://asecuritysite.com/forensics/magic) del fichero. Generalmente los magic numbers de cualquier archivo son los primeros bytes de un archivo.

En el caso de un mp4 los bytes deberían ser: `00 00 00 (18 o 1C) 66 74 79 70 6D 70 34 32` y al correr:

```
$ hexdump -C evo-telefono.mp4 | head -n1
00000000  00 00 00 1c 66 74 79 70  6d 70 34 32 00 00 00 01  |....ftypmp42....|
```

Efectivamente tiene esos magic numbers que identifican a un mp4. Una forma más simple de verificar es utilizando el comando `file`:

```
$ file evo-telefono.mp4
evo-telefono.mp4: ISO Media, MP4 v2 [ISO 14496-14]
```

## Primeras ideas
Para ver si encuentro algo interesante ejecuté el comando `strings` contra el video y ver si encontraba alguna cadena ASCII interesante, como la vulnerabilidad explica que el error radica en la metadata del archivo, entonces imaginé que la estructura era algo interno como "clave-valor" todo en ASCII, esa suposición la descarté al no encontrar nada interesante usando `strings`.

```
$ strings evo-telefono.mp4
```

La siguiente idea fue utilizar una herramienta que puede ver la metadata de diferentes formatos que se llama `mediainfo` y `mediainfo-gui`. Para esta primera etapa del análisis utilicé `mediainfo` porque no entendía muy bien la forma en como se presentaba con `mediainfo-gui`, pero esta gui más adelante fue de mucha más utilidad.

Utilizando `mediainfo` contra el video `evo-telefono.mp4` obtuve la siguiente salida, pondré solo ciertas partes pero dejo este [gist](https://gist.github.com/donkeysharp/ecdfb633e2a75844019985cc61904c3c) con la salida completa del comando.

```
$ mediainfo evo-telefono.mp4
General
Complete name                            : evo-telefono.mp4
Format                                   : MPEG-4
Format profile                           : Base Media / Version 2
Codec ID                                 : mp42 (isom/mp41/mp42)
File size                                : 6.41 MiB
Duration                                 : 1 min 2 s
Overall bit rate                         : 857 kb/s
Encoded date                             : UTC 2019-11-21 12:31:56
Tagged date                              : UTC 2019-11-21 12:31:59

...
```

Visualmente esa información es clave-valor pero gran parte de esas cadenas no se encontraba cuando utilicé `strings` lo cual me lleva a la conclusión que el formato es en su mayoría binario y que los números en esta salida no estan representados como una cadena ASCII sino en bytes similar a un paquete IP o TCP.

> **Nota:** un paquete IP es binario en el sentido que la IP y otros flags no estan en modo texto ASCII sino encapsulados en bytes. Por ejemplo la ip 10.0.1.11 (9 bytes en ASCII) se representa en 4 bytes como 0A 00 01 0B

En este punto sentí que estaba pateando oxígeno y que no llegaría a ningún lado. Lo siguiente que hice es buscar si había ya algún exploit o tutorial de como explotar este CVE y efectivamente con la ayuda de Google llegue a este repositorio en [Github](https://github.com/kasif-dekel/whatsapp-rce-patched).

Este repo tenía un mp4 llamado `poc.mp4` que en teoría explotaba esta vulnerabilidad y junto a este archivo la librería dinámica de Whatsapp `libwhatsapp.so` y un programa en C que invoca esta librería dinámicamente usando `dlfcn.h` (espero hacer un post sobre dlfcn.h en el futuro, súper interesante). Lo más importante de este repositorio que me ayudó fue tener una muestra de algo que sí causa este error.

Lo primero que hice fue ejecutar nuevamente `mediainfo` contra `poc.mp4` y ver las diferencias entre `evo-telefono.mp4` y `poc.mp4`, tristemente fue más frustrante ya que lo único diferente era un nuevo tag llamado `com.android.version` con el valor de `9` en ASCII y bueno, ya me quedé sin ideas. Al inicio pense que junto a este tag viendo el hexadecimal tal vez había un shellcode, buscando opcodes comunes y eso, pero realmente sentía que la estrategia que estaba utilizando era bastante "naive" y no estaba entendiendo el formato MP4 como tal y bueno, creo que ese era el siguiente paso. La mayoría de los archivos tiene una especificación de como están estructurados, ya sea en texto plano en un formato como json o xml o en binario como el caso de MP4. Busqué en Google los spec files, le dí una leida super rápida a lo que encontré para ver si mencionaba cosas como bytes y cosas así y no encontré uno como tal y bueno ahí pausé por un día este análisis para descansar.

## Entendiendo el formato MP4 y la vulnerabilidad
Horas después que pausé, mi amigo [Elvin](https://twitter.com/ElvinMollinedo) envió este [link de Hack A Day](https://hackaday.com/2019/11/22/this-week-in-security-more-whatsapp-nextcry-hover-to-crash-and-android-permissions-bypass/) que da un resumen de la vulnerabilidad y somo esta siendo explotada, muchísimas gracias por compartirlo fue uno de los recursos más importantes para esta investigación. La verdad cuando lo leí no entendí ciertos detalles que justamente eran los más importantes, no entendía aún la estructura de un archivo mp4.

**Desde acá** todos los pasos que sigo son solamente con el archivo `poc.mp4` y al final aplicaré lo aprendido a `evo-telefono.mp4`.

Lo primero que hice es tratar de reproducir el único paso que menciona en el post de Hack A Day con la herramienta `AtomicParsley` contra `poc.mp4`. Al ejecutarlo me salió un `Segmentation Fault` pero lo mismo con `evo-telefono.mp4`, al parecer es más un error de la herramienta que ya anda descontinuada.

```
$ AtomicParsley poc.mp4 -T

Atom ftyp @ 0 of size: 24, ends @ 24
Atom moov @ 24 of size: 794, ends @ 818
     Atom mvhd @ 32 of size: 108, ends @ 140
     Atom meta @ 140 of size: 117, ends @ 257
         Atom  @ 152 of size: 6943, ends @ 7095					 ~

 ~ denotes an unknown atom
------------------------------------------------------
Total size: 7095 bytes; 4 atoms total.
Media data: 0 bytes; 7095 bytes all other atoms (100.000% atom overhead).
Total free atom space: 0 bytes; 0.000% waste.
------------------------------------------------------
AtomicParsley version: 0.9.6 (utf8)
------------------------------------------------------
Segmentation fault
```

Como se ve en la salida un montón de info que no entendía xD, pero algo que si mencionaban en el post de Hack A Day es la posición en bytes y que MP4 es una estructura jerárquica y la estructura básica de de MP4 es el "Atom" (existen diferentes tipos de atoms). Más adelante hablaré con más detalle sobre los Atoms.


Cada atom tiene una cabecera que indica el size del atom. Al ser una estructura jerárquica un atom puede contener otros atoms dentro. Al ser así, el tamaño de un atom padre es el total de todos los bytes de los atom hijos y lo que se resalta y es mencionado en el post es lo siguiente:

El atom `meta` tiene un tamaño de 117 bytes pero dentro de este atom hay un atom hijo sin nombre que tiene un tamaño de 6943 bytes que es mayor a los 117 bytes del padre y bueno eso da una pista.

```
         Atom  @ 152 of size: 6943, ends @ 7095 				 ~
```

En el post posteriormente hace referencia a 33 bytes y 1.6GB del size del atom y bueno ahí me perdí y eso era efectivamente la clave para entender el error.

Lo siguiente en hacer --ya lo había procrastinado suficiente-- era leer las especificaciones de un archivo MP4. De los archivos que conseguí ninguno era al nivel que quería, es decir, a nivel de bytes. Por suerte, una vez más el post de Hack A Day hace referencia a dos documentos: la especificación en el sitio de [Apple Developers](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/Metadata/Metadata.html) y otra especificación un [poco más rebuscada](http://xhelmboyx.tripod.com/formats/mp4-layout.txt) y es donde se llega a entender completamente este error.

## El formato MP4
Como resumen super corto tras leer la especificación se puede decir que Mp4 está organizado jerárquicamente en bloques llamados Atom (lo que mencioné arriba) y cada Atom tiene una cabecera de 8 bytes, 4 bytes definen el tamaño del Atom y los otros 4 bytes (generalmente en ASCII) representan el tipo del Atom.

Ahora existen varios tipos de Atoms pero los que se muestran en el post son los siguientes:

- `moov` que representa lo que es "Movie Data" que puede tener otros Atoms. Basicamente el contenido de este atom es información de la película e.g. cuando se creó, duración, etc.
- `meta` otro atom que encapsula información de Metadata
- `hdlr` un atom que es considerado el handler y viene dentro del atom `meta`, este atom define toda la estructura que tendrá toda la metadata dentro del atom `meta`

La siguiente imagen muestra la representación gráfica de los atoms en forma de caja:

![](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/art/metadata_atom.jpg)

¿Pero cómo se puede entender este formato a nivel binario? Esta parte me tomó un poco de tiempo pero al final utilizando `mediainfo-gui` y un editor hexadecimál fue algo mucho más simple.

Un atom tiene una cabecera de 8 bytes donde los primeros 4 bytes indican el tamaño del atom y los siguientes 4 bytes el tipo de atom e.g. `moov`, `meta`, `hdlr` entre otros y luego vienen N bytes que son el contenido del atom, donde N es el tamaño del atom especificado en los primeros 4 bytes restando 8 bytes (la cabecera).

Un ejemplo:

Un atom de 794 bytes de tamaño de tipo `moov` se representaría como:

```
00 00 03 1A 6D 6F 6F 76 XX XX XX ... 786 bytes ... XX XX
```

Según la especificación los primeros 4 bytes son el tamaño, los siguientes 4 bytes son el tipo de atom y el resto es el cuerpo.

Los primeros 4 bytes se pueden representar como `0x0000031A` o `0x31A` que en decimal es `794`.

Los siguientes 4 bytes indican el tipo de atom que es texto ASCII, entonces solo es convertir los siguientes bytes a su caracter en ASCII y tendremos:

```
6D -> m
6F -> o
6F -> o
76 -> v
```

Ahora el contenido de este atom (los restante 786 bytes) pueden ser otros atoms identificados de la misma forma y en base a la especificación del formato MP4.

> Existen casos especiales de algunos Atoms que tienen un formato especial. Un ejemplo de estos atoms especiales es que después del header no definimos directamente otro atom, es posible que algunos bytes esten reservados con algún propósito (flags, etc) y luego de estos bytes reservados recién es posible definir atoms hijos. **Recuerden** este párrafo ya que verán es la llave al éxito.

Siguiendo con ejemplos en `poc.mp4`, hay un atom llamado `mdta` que es basicamente el nombre de key en la metadata (este atom tiene el key `com.android.version` que mencioné más arriba). Al igual que otro atom se lo representa con un header de 8 bytes y luego el contenido:

```
00 00 00 1B 6D 64 74 61 63 6F 6D 2E 61 6E 64 72 6F 69 64 2E 76 65 72 73 69 6F 6E
```

Donde:
- `0x0000001B` representa el tamaño que en decimal es 27 bytes
- `6D 64 74 61` representa en ASCII `mdta` el tipo del atom
- `63 6F 6D 2E 61 6E 64 72 6F 69 64 2E 76 65 72 73 69 6F 6E` convirtiendo a ASCII representa `com.android.version`

Para no hacer muy largo el post he creado un video donde muestro con más detalle cómo interpretar a nivel hexadecimal este formato utilizando `mediainfo-gui`.

{{< youtube JbvDRA7RGxs >}}

### Entendiendo el bug
En el anterior video se ve como entender y navegar por los diferentes atoms tanto como el visualizador de atoms `mediainfo-gui` como también a nivel hexadecimal. En esta parte utilizando el conocimiento adquirido hasta ahora se verá cómo el bug reportado en el CVE puede utilizarse.

> Parte de [CVE-2019-11931](https://www.facebook.com/security/advisories/cve-2019-11931):
> The issue was present in parsing the elementary stream metadata of an MP4 file and could result in a DoS or RCE

Este CVE y la forma como causar el overflow justamente dice que esta en la metadata, es decir, en el Atom `meta`. En el post de Hack A Day hace referencia a dos especificaciones del formato mp4. El link de Apple Developers indica que después de definir el atom de tipo `meta` como hijo se debería definir un atom de tipo `hdlr` y si vemos en el hexadecimal, sucede exactamente eso desde el offset `8C` como muestra las siguientes imágenes.

![](/img/vid-analysis-mediainfo-gui.png)
<!-- Imagen de mediainfo resaltando el atom meta -->

![](/img/vid-analysis-atom-meta-hex.png)
<!-- imagen de ghex mostrando lo mismo en hexdecimal -->

```
header size   meta type     header size   hdlr type
-----------   -----------   -----------  -----------
00 00 00 75   6d 65 74 61   00 00 00 21  68 64 6c 72 ...
0x00000075    meta          0x00000021   hdlr
0x75 o 117    meta          0x21 o 33    hdlr
```

Lo que se ve en `mediainfo-gui` y en el hexadecimal tiene mucho sentido, pero si recordamos la salida de la aplicación `AtomicParsley` no sale en ningún momento el atom `hdlr` que efectivamente esta definido y en lugar de eso muestra un error de que un atom *sin nombre* tiene tamaño de 6943 bytes (mayor a los 117 de su atom padre `meta`).

```
$ AtomicParsley poc.mp4 -T

Atom ftyp @ 0 of size: 24, ends @ 24
Atom moov @ 24 of size: 794, ends @ 818
     Atom mvhd @ 32 of size: 108, ends @ 140
     Atom meta @ 140 of size: 117, ends @ 257
         Atom  @ 152 of size: 6943, ends @ 7095	<<<<<< atom sin nombre

 ~ denotes an unknown atom
------------------------------------------------------
Total size: 7095 bytes; 4 atoms total.
Media data: 0 bytes; 7095 bytes all other atoms (100.000% atom overhead).
Total free atom space: 0 bytes; 0.000% waste.
------------------------------------------------------
AtomicParsley version: 0.9.6 (utf8)
------------------------------------------------------
Segmentation fault
```
Todos los atoms en la salida muestran su tipo `ftyp`, `moov`, `mvhd`, `meta` y dentro de `meta` este atom desconocido con un tamaño que es basicamente el resto del tamaño de `poc.mp4` que pesa 7095 bytes, ya que si se hacen cuentas sumando el tamaño de del atom `ftyp` (24), `mvhd` (108), el header de `meta` (8)resulta  `24 + 108 + 8 = 148` pero `7095 - 148 = 6947` que son 4 bytes extras de los 6943 que da en la salida de `AtomicParsley`.

**Qué son estos 4 bytes?**

Se ve que en `mediainfo-gui` todo se muestra bien, como si nada hubiera pasado y el formato esta correcto. Sin embargo, en `AtomicParsley` muestra un atom sin ningún tipo y tenemos un excedente en 4 bytes haciendo sumas y restas con la salida de `AtomicParsley`.

Lo que sucede y logré deducir es lo siguiente, si vemos el tipo de archivo de `poc.mp4` suando el comando `file` se ve que es `ISO Media, MP4 v2 [ISO 14496-14]`. Pasa que el formato mp4 esta en base al estándar `ISO 14496-14` que es la continuación de otro estándar llamado `ISO 14496-12` y lo más interesante viene aca: en el post de Hack A Day menciona dos links de especificaciones el de [Apple Developers](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/Metadata/Metadata.html) y uno un [poco más rebuscado](http://xhelmboyx.tripod.com/formats/mp4-layout.txt). En el segundo link indica claramente que es la especificación del estándar `ISO/IEC 14496-12` y justamente en este es donde indica que el atom `meta` despúes del header de 8 bytes tiene 4 bytes reservados (3 para flags y 1 para versión) y después de estos 4 bytes recién se pueden definir otros atoms hijo.

De ser así y volviendo a analizar el hexadecimal se tiene lo siguiente:

```
                            4 bytes
header size   meta type     reservados   header size  type inválido
-----------   -----------   -----------  -----------  -----------
00 00 00 75   6d 65 74 61   00 00 00 21  68 64 6c 72  00 00 00 00 ...
```

Sabiendo eso, los 4 bytes hacen que la definición del atom hijo se recorra y tenga la cabecera `68 64 6c 72  00 00 00 00` donde `0x68646c72` es el size y `00 00 00 00` es el type que en ASCII que no es nada válido y justamente eso explica el porqué del fallo de la aplicación `AtomicParsley`. Ahora si se convierte `0x68646c72` a decimal se obtiene el valor de 1751411826 es decir, el tamaño de ese atom desconocido sería de todo esa gran cantidad de bytes que llega a ser 1.6GB (igual que en el post de Hack A Day).

Sabiendo esto, ya pude reproducir con confianza el archivo `poc.mp4` xD.

Lo que deduzco es lo siguiente: la librería `libwhatsapp.so` ([repo](https://github.com/kasif-dekel/whatsapp-rce-patched)) posiblemente esta obedeciendo el estándar `ISO 14496-12` y no el `ISO 14496-14` o simplemente fue un error de desarrollo ya que en el update actual de Whatsapp esto no sucede. Ahora relacionado a la aplicación `AtomicParsley` muy probable que suceda lo mismo ya que esta si tuvo problemas con ese atom desconocido.

## Analizando el archivo `evo-telefono.mp4`
La verdad hasta este punto estaba feliz por lo mucho que había aprendido, pero faltaba el objetivo principal que era analizar si este archivo tenía algo malicioso específicamente por este CVE.

De entrada puedo decir que **NO** (al menos no con este CVE).

Las razón es la siguiente: para poder causar este error se necesita tener definido el atom `meta` el cual no se define dentro de ningún atom en el video `evo-telefono.mp4`. De todos modos es la primera vez que analizo un archivo a este nivel y bueno, en algunos grupos de chat mencionaron Pegasus y eso, no estaría de más darle una revisada a eso :smile:.


## Comentarios Finales
En serio que fue una experiencia buena en cuanto a aprendizaje y ver este tipo de vectores de ataque que se aprovechan de este tipo de detalles.

Otra cosa aprendida que para este tipo de análisis, al igual que al analizar protocolos de red es necesario leer el RFC, en el caso de formatos es necesario leer la especificación del formato de algún archivo. Hay un ezine llamado `Paged Out` que en una de sus secciones habla de técnicas de hacer reversing a formatos de archivos, se los recomiendo. [Link](https://pagedout.institute/download/PagedOut_001_beta1.pdf).

Finalmente agradecer nuevamente a Elvin por compartir ese post de Hack A Day que fue clave para este análisis y a Gonzalo y Cris por animarme a hacerlo, les debo una cerveza a los tres :smile:.
