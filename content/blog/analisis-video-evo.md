---
title: "Analisis Video Evo"
date: 2019-11-26T13:08:36-04:00
draft: true
---

Hola, durante los meses de Octubre y Noviembre sucedieron diferentes conflictos sociales y políticos en Bolivia, esta entrada no es tanto para discutir el tema político, es más será una entrada 100% técnica pero se encuentra relacionada con estos hechos.

La anterior semana una gran cantidad de clientes de un ISP local recibieron un SMS con un link de `bit.ly` hacia un video MP4 en Dropbox que después fue dado de baja, este video que fue viral no solo por SMS sino en redes sociales y medios de comunicación locales, mostraba la llamada que en la que [un dirigente local habla](https://www.eldeber.com.bo/157244_video-que-registra-una-llamada-entre-evo-morales-y-un-dirigente-fue-encontrado-en-el-desbloqueo-en-t) con [Evo Morales](https://es.wikipedia.org/wiki/Evo_Morales).

Corrieron rumores de que el video era un malware o era utilizado para hacer tracking de las personas que lo abriesen, la verdad no suelo tirar mucha bola a eso, pero esta vez me interesó porque días atrás Facebook habia notificado una falla de seguridad de Stack Buffer Overflow que posiblemente podría generar RCE en la aplicación de Whatsapp justamente con un video MP4 malicioso!. Este es el [link](https://www.facebook.com/security/advisories/cve-2019-11931) de la alerta de seguridad.

Bueno, me dió mucha curiosidad ver que había o si efectivamente había algo malicioso en ese video o simplemente era spam. De entrada sabía que aprendería varias cosas porque muy poca idea tenía de como podría analizar si el video efectivamente era malicioso o no y bueno ya con el video que lo enviaron a un grupo público de chat, mis amigos [Gonzalo](https://twitter.com/lorddemon) y [Cristhian](https://twitter.com/crhystamil) me dijeron que ponga una entrada en mi blog sobre lo que encuentre y de no encontrar nada que hable sobre los ángulos de grabación del video XD. Bueno el resto del blog será sobre lo que encontré y aprendí y gracias por animarme a investigar muchachos, me divertí mucho.

## El video
El video justamente era un archivo mp4 con este sha512 `a378c367e3c9a4be3ca639822fe79adf75aaa30ba25ca97ff8f6eb3945d36ed9eb160703ed611ecfe5fdc448c6a099e8af3a74a2c7078695db9c258a25800246`. Primeramente verificar que efectivamente es un mp4 viendo los [magic numbers](https://asecuritysite.com/forensics/magic) del fichero. Generalmente los magic numbers de cualquier archivo son los primeros bytes de un archivo.

En el caso de un mp4 son los bytes debería ser: `00 00 00 (18 o 1C) 66 74 79 70 6D 70 34 32` y al correr:

```
$ hexdump -C evo-telefono.mp4 | head -n1
00000000  00 00 00 1c 66 74 79 70  6d 70 34 32 00 00 00 01  |....ftypmp42....|
```

Efectivamente tiene esos magic numbers que identifican a un mp4, una forma más simple de verificar es utilizando el comando `file`:

```
$ file evo-telefono.mp4
evo-telefono.mp4: ISO Media, MP4 v2 [ISO 14496-14]
```

## Primeras ideas
Para ver si encuentro algo interesante el comando `strings` contra el video y ver si encontraba alguna cadena ASCII interesante, como la vulnerabilidad explica que el error radica en la metadata del archivo, entonces imagine que la estructura era algo interno como clave valor todo en ASCII, esa suposición la descarté al no encontrar nada interesante usando `strings`.

```
$ strings evo-telefono.mp4
```

La siguiente idea fue utilizar una herramienta que puede ver la metadata de diferentes formatos que se llama `mediainfo` y `mediainfo-gui`. Para esta primera etapa del análisis use `mediainfo` porque no entendía muy bien la forma en como se presentaba con `mediainfo-gui` (ver imagen), pero esta gui más adelante fue de mucha más utilidad.

![](/img/vid-analysis-mediainfo-gui.png)
<!-- Imagen de mediainfo gui en estructura de árbol -->

Utilizando esta herramienta contra el video `evo-telefono.mp4` y obtuve la siguiente salida, pondré solo ciertas partes pero dejo este [gist](https://gist.github.com/donkeysharp/ecdfb633e2a75844019985cc61904c3c) con la salida completa del comando.

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

Visualmente esa información es clave-valor pero gran parte de esas cadenas no se encontraba cuando utilicé `strings` lo cual me lleva a la conclusión que el formato es en su mayoría binario y que los números en esta salida no estan representados como una cadena ASCII sino en bytes similar a un paquete IP.

> **Nota:** un paquete IP es binario en el sentido que el puerto y otros flags no estan en modo texto ASCII sino encapsulados en bytes. Por ejemplo la ip 10.0.1.11 se representa en 4 bytes como 0A 00 01 0B

En este punto sentí que estaba pateando oxigeno y que no llegaría a ningún lado. Lo siguiente que hice es buscar si había ya algún exploit o tutorial de como explotar este CVE y efectivamente con la ayuda de Google llegue a este repositorio en [Github](https://github.com/kasif-dekel/whatsapp-rce-patched).

Este repo tenía un mp4 llamado `poc.mp4` que en teoría explotaba esta vulnerabilidad y junto a este archivo la librería dinámica de Whatsapp `libwhatsapp.so` y un programa en C que invoca esta librería dinámicamente usando `dlfcn.h` (espero hacer un post sobre dlfcn.h en el futuro, super interesante). Lo más importante de este repositorio que me podría ayudar es tener una muestra de algo que si causa este error.

Lo primero que hice fue ejecutar nuevamente `mediainfo` contra `poc.mp4` y ver las diferencias entre `evo-telefono.mp4` y `poc.mp4`, tristemente fue más frustrante ya que lo único diferente era un nuevo tag llamado `com.android.version` con el valor de `9` en ASCII y bueno, ya me quedé sin ideaas. Al inicio pense que junto a este tag viendo el hexadecimal tal vez había un shellcode, buscando opcodes comunes y eso, pero realmente sentía que la estrategia que estaba utilizando era bastante "naive" y no estaba entendiendo el formato MP4 como tal y bueno, creo que ese era el siguiente paso. La mayoría de los archivos tiene una especificación de como están estructurados, ya sea en texto plano en un formato como json o xml o en binario como el caso de MP4. Busqué en Google los spec files, le dí una leida super rápida a lo que encontré para ver si mencionaba cosas como bytes y cosas así y no encontré uno como tal y bueno ahí pausé por un día este análisis para descansar.

### Entendiendo el formato MP4 y la vulnerabilidad
Horas despues que pause mi amigo [Elvin](https://twitter.com/ElvinMollinedo) envió este [link de Hack A Day](https://hackaday.com/2019/11/22/this-week-in-security-more-whatsapp-nextcry-hover-to-crash-and-android-permissions-bypass/) que da un resumen de la vulnerabilidad y somo esta siendo explotada. La verdad cuando lo leí no entendí ciertos detalles de la parte más importante que es donde estaba el bug y justamente fue porque no entendía aún la estructura de un archivo mp4.

De acá todos los pasos que sigo son solamente con el archivo `poc.mp4` y al final aplicaré lo aprendido a `evo-telefono.mp4`.

Lo primero que hice es tratar de reproducir el único paso que menciona en el post de Hack A Day con la herramienta `AtomicParsley` contra `poc.mp4`. Al ejecutarlo me salió un `Segmentation Fault` pero lo mismo con `evo-telefono.mp4`, es más un error de la herramienta que la parecer anda descontinuada.

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

Como se ve en la salida un monton de info que no entendía xD, pero algo que si mencionaban en el post es la posición en bytes y que MP4 es una estructura jerárquica y la estructura básica de de MP4 es el "Atom", entonces el size del atom padre es el total de todos los bytes en los hijos y lo que se resalta y es mencionado en el post es lo siguiente:

El atom `meta` tiene un tamaño de 117 bytes pero dentro de este atom hay un atom hijo sin nombre que tiene un tamaño de 6943 bytes que es mayor a los 117 bytes del padre y bueno esa da una pista.

```
         Atom  @ 152 of size: 6943, ends @ 7095					 ~
```

En el post posteriormente hace referencia a 33 bytes y 1.6GB del size del atom y bueno ahí me perdí y eso era efectivamente la clave para entender el error.

Lo siguiente ya lo había procrastinado suficiente era leer las especificaciones de un archivo MP4. De los archivos que conseguí ninguno era al nivel que quería, es decir, a nivel de bytes. Por suerte, una vez más el post hace referencia a dos documentos: la especificación en el sitio de [Apple Developers](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/Metadata/Metadata.html) y otra especificación un [poco más rebuscada](http://xhelmboyx.tripod.com/formats/mp4-layout.txt) y es donde se llega a entender completamente este error.
