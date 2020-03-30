---
title: "Gocho, Compartir Archivos En Una Red Local"
date: 2018-03-29T22:22:46-04:00
draft: false
---

Holas, durante mi tiempo libre estuve trabajando en un proyecto llamado [Gocho](https://github.com/donkeysharp/gocho). Esta pequeña aplicación permite compartir archivos en una red local, por ejemplo la red de la casa, red del trabajo, etc. con la característica de auto-descubrimiento de nodos (auto-discovery). En este post explicaré de que se trata, por qué lo hice y algunos de los retos que surgieron al hacer la aplicación.

![](/img/gocho-dashboard.gif)
<center><a href="/img/gocho-dashboard.gif" target="_blank">Ver</a></center>

## Por qué lo hice?
Lo hice porque deseaba una aplicación donde pueda compartir un directorio; poder aguantar varias descargas al mismo tiempo; no tener que preguntar la dirección IP o puerto de los recursos que otros comparten; tener algo que sea simple de ejecutar en cualquier sistema operativo (Windows, OSX, GNU/Linux) sin tener que instalar ningún requisito previo.

Este tipo de proyectos siempre los hago a modo de aprender algo nuevo. En este caso ya desde el año pasado (2017) tenía ganas de hacer algo con [Go](https://golang.org/). Si bien hice uno que otro experimento a modo de aprender ([Golondrina](https://github.com/donkeysharp/golondrina); [EazyPanel](https://github.com/donkeysharp/eazy-panel)), esta aplicación me pareció un buen caso de uso para este lenguaje en específico (lo elaboro más adelante).

## Por qué Go?
Si alguien ya ejecutó la aplicación es fácil notar que no es algo de otro mundo. Gocho podría haber sido desarrollado en otros lenguajes como: C/C++, Python, Ruby, Java, CSharp, etc. pero tenía algunas observaciones preliminares:

* Python/Ruby - es importante tener los intérpretes instalados, en Windows no vienen por defecto.
* Java/CSharp - es importante tener las máquinas virtuales respectivas instaladas (JVM o NetCore). No siempre se dá el caso que ya venga instalado por defecto en el sistema operativo.
* C/C++ - sería la opción más obvia, pero un par de problemas que encontré sería que por defecto son dinámicamente enlazados, lo cual causaría en algún caso la instalación de librerias necesarias (a menos que use el flag de estáticamente enlazados) y el segundo problema es que a pesar que se leer C/C++ no me siento en la confianza de lanzarme a hacer algo
* Go - estáticamente compilado por defecto (todo en un binario), el binario resultante no require que exista la instalación previa de alguna librería, intérprete, máquina virtual y otros.

Con esta lista &mdash;un poco parcializada :wink:&mdash; Go cumple con las necesidades que tengo.

Algo no mencionado es la facilidad con la que puedo crear binarios para diferentes plataformas. Por ejemplo Gocho esta disponible para distintas plataformas sin mucho problema. [Releases Gocho](https://github.com/donkeysharp/gocho/releases)

## Algunos Problemas que Encontré

### Problema 1: Compartir Archivos
En la empresa donde trabajo existe una diversidad en cuestión a sistemas operativos. Algun@s compañer@s utilizan Windows, OSX y otr@s GNU/Linux. Para compartir archivo, existe un Active Directory o algo similar configurado, personalmente nunca logré acceder a las carpetas compartidas por otros (uso GNU/Linux). Al intentar acceder me salía la opción de insertar un dominio y credenciales; pése a que introducía los datos &mdash;que en teoría eran correctos&mdash; no lograba acceder a los archivos compartidos.

En el trabajo hay compañeros que comparten información por ejemplo videos, cursos, etc. montando un servidor `httpd` en su máquina local o en mi caso ejecutaba `python -m SimpleHTTPServer` en el directorio que deseaba compartir. Noté un problema con `SimpleHTTPServer`, con pocas personas tratando de descargar el mismo archivo, esta pequeña utilidad solo permite manejar una descarga al mismo tiempo.

Mi segundo intento fue utilizar algo un poco más robusto que `SimpleHTTPServer` pero sin la necesidad de levantar algo grande como `httpd`. Tuve la suerte de chocar con un ejemplo en la documentación de Go para el modulo `net/http` que justamente &mdash;con pocas líneas de código&mdash; me permitía compartir un directorio y podía soportar varias descargas simultáneas sin problemas.

{{< highlight go >}}
package main

import (
    "log"
    "net/http"
)

func main() {
    // Simple static webserver:
    directory := "some/directory"
    log.Fatal(http.ListenAndServe(":8080", http.FileServer(http.Dir("/home/myuser/some/directory"))))
}
{{< /highlight >}}

Solo tuve que compilar este archivo; poner el binario que llamé `http` en algún directorio que se encuentre en mi `PATH` de ejecución y voila! ya contaba con algo más robusto que pueda aguantar más descargas y no tenga que montar todo un servicio.

>> *ya contaba con algo más robusto que pueda aguantar más descargas*
>
> Con esto me refiero a algo que aguante varias conexiones simultáneas, algo que Go lo plantea de una manera simple y en el caso del módulo `net/http` ya viene por defecto.

Hasta este punto, solamente tengo un pequeño binario que me permite compartir un directorio y pueda aguantar varias descargas simultáneas &mdash;algo no tan complejo como montar un servicio `httpd` pero más robusto que `SimpleHTTPServer` de Python.

La verdad si compilara este binario `http` para varios sistemas operativos sería suficiente para compartir archivos, pero quería ir un poco más alla.

### Problema 2: Indicar Donde se Encuentran los Archivos Compartidos
Otro problema que encontré es que cada vez que un usuario comparte algo en una red local, este debe &mdash;de algún modo&mdash; comunicar como acceder a los recursos que se comparten. Una forma común de realizar esto es compartir la url de descarga `http://ip_red_local:algun_puerto` en algun grupo de chat o similar.

Ya que esta aplicación la tengo orientada para el contexto de una red local, algo que se me pasó por la cabeza son los juegos en red como StarCraft. En StarCraft cuando alguien crea una partida de red de área local, los jugadores que se unirán a una partida no especifican como tal la dirección IP de la máquina servidor a la que se conectarán. El juego simplemente muestra las partidas creadas en la red actualmente y uno puede conectarse sin problemas de forma automática.

Investigando un poco sobre cómo estos juegos hacian posible mostrar las partidas ya existentes en la red sin tener que especificar una dirección IP o algo similar, me llevó al concepto de [multicast](https://en.wikipedia.org/wiki/Multicast).

En palabras simples, Multicast es un método que permite enviar información a nodos interesados en una red.

Por ejemplo, si deseo enviar el mensaje "hola mundo" a computadoras interesadas en recibir este mensaje sin que yo tenga que saber a qué máquinas específicamente, la idea sería la siguiente:

* *Mi Computadora*: Enviar datagrama UDP con mensaje "hola mundo" a alguna [dirección IP reservada para multicast](https://en.wikipedia.org/wiki/Multicast_address#IPv4) ej. 239.6.6.6:1234
* *Computadora Interesada 1*: Escuchar por datagramas UDP en 239.6.6.6:1234
* *Computadora Interesada 2*: Escuchar por datagramas UDP en 239.6.6.6:1234
* *Computadora Interesada n*: Escuchar por datagramas UDP en 239.6.6.6:1234

De este modo multicast permite que cualquier máquina que desee compartir algo, solo debe enviar su información de nodo (identificador, dirección IP, puerto) por multicast y otras máquinas interesadas.

Sabiendo esto, Gocho además de compartir un directorio podrá saber lo que otros nodos Gocho estan compartiendo.

Ya viendo un poco la implementación de esto, podemos ver algunos trozos de código que utilicé en Gocho.

[pkg/node/net.go](https://github.com/donkeysharp/gocho/blob/master/pkg/node/net.go)

La función `announceNode` básicamente envía un paquete multicast.

{{< highlight go >}}
func announceNode(nodeInfo *NodeInfo) {
    address, err := net.ResolveUDPAddr("udp", MULTICAST_ADDRESS)
    // error handling

    conn, err := net.DialUDP("udp", nil, address)
    // error handling

    for {
        ...
        conn.Write([]byte(message))
        time.Sleep(ANNOUNCE_INTERVAL_SEC * time.Second)
    }
}
{{< /highlight >}}

La función `listenForNodes` que escucha los mensajes multicast.

{{< highlight go >}}
func listenForNodes(nodeList *list.List) {
    address, err := net.ResolveUDPAddr("udp", MULTICAST_ADDRESS)
    // error handling
    conn, err := net.ListenMulticastUDP("udp", nil, address)
    // error handling

    conn.SetReadBuffer(MULTICAST_BUFFER_SIZE)

    for {
        packet := make([]byte, MULTICAST_BUFFER_SIZE)
        size, udpAddr, err := conn.ReadFromUDP(packet)
        ...
    }
}
{{< /highlight >}}

Entonces gran parte de la "mágia" de Gocho se encuentra en el trabajo con multicast. Con multicast una máquina puede anunciarse a sí misma y a la vez descubrir a otros nodos.

### Problema 3: Formato de los Mensajes
Si bien ya tenemos una forma de comunicarnos entre nodos, ví conveniente poder identificar los paquetes que envía Gocho con otros. Básicamente el paquete (en esta versión inicial) debe seguir lo siguiente:

1. Los primeros 4 bytes deben ser `0x60`, `0x0d`, `0xf0`, `0x0d` o `0x600df00d`, que es la cabecera que identifica que lo enviado es un mensaje de otro nodo de Gocho
2. El siguiente byte especifica el comando, actualmente solo existe un solo comando que es `0x01` que indica que un nodo se esta anunciando. La información del nodo se encuentra en el payload
3. Finalmente el resto es el payload. Para esto decidí utilizar el formato JSON

Un hexdump de un mensaje en el que se anuncia un nodo luce de la siguiente forma:

```
00000000  60 0d f0 0d 01 7b 22 6e  6f 64 65 49 64 22 3a 22  |`....{"nodeId":"|
00000010  6e 6f 64 6f 2d 73 65 72  67 69 6f 22 2c 22 69 70  |nodo-sergio","ip|
00000020  41 64 64 72 65 73 73 22  3a 22 22 2c 22 77 65 62  |Address":"","web|
00000030  50 6f 72 74 22 3a 22 35  30 30 30 22 7d           |Port":"5000"}|
```

La decisión de tener este formato fue la de ahorrar la mayor cantidad de bytes posibles. De hecho, si no utilizara el formato JSON se ahorrarían unos cuantos bytes más.

En el futuro es posible que existan más comandos diferentes al de anunciar un nodo (`0x01`). Es por eso que se dejó un byte reservado para ello.

## Diseño de la aplicación
Esta sección habla un poco más de la implementación ya habiendo conocido los problemas mencionados arriba. Para poder seguir esta sección hago referencia al [código fuente](https://github.com/donkeysharp/gocho) de la aplicación.

### Estructura del Código
La estructura de código del proyecto Gocho está basada en este [artículo](https://peter.bourgon.org/go-best-practices-2016/#repository-structure) en el que se plantea una esctructura para proyectos en Go. Esta estructura es bastante utilizada en diferentes proyectos, entre ellos algunos proyectos bastante conocidos como [Kubernetes](https://github.com/kubernetes/kubernetes) o [Docker](https://github.com/moby/moby).

El proyecto incluye un archivo `Makefile` el cual indica los pasos necesarios para poder construir o desarrollar el proyecto, como también crear los binarios para las plataformas soportadas.

### Componentes del Servicio
En el anterior punto mencioné la estructura de código que utilizo. En este punto me enforcaré en los componentes dentro del directorio `pkg`, especialmente en `pkg/node`.

Componente | Descripción
--- | ---
`pkg/info` | Información básica de la aplicación como nombre o versión.
`pkg/cmds` | Toda la lógica de flags de la utilidad de línea de comandos. Por ejemplo `gocho start [options]` o `gocho configure`.
`pkg/config` | Todo el código con la lógica y estructuras necesarias para representar la lógica de Gocho. Aca se encuentra la lógica de establecer valores por defecto o cargar las diferentes configuraciones de un archivo `.gocho.conf` o de los options establecidos por línea de comandos.
`pkg/node` | La lógica principal de la aplicación radica en este directorio. El cómo se tiene un dashboard web embebido; el formato de los paquetes; el mecanismo de auto-discovery (multicast) y el índice de archivos que muestra el contenido del directorio compartido.

### Algunas Estructuras de Datos y Lógica Utilizada
La aplicación debe guardar la información de otros nodos, para esto decidí hacer uso de una lista enlazada por la simplicidad al borrar o insertar elementos.

Es importante notar que mientras más nodos se anuncien en una red, es posible que partes del código (de cualquier nodo) tendrá que ejecutar las mismas sentencias al mismo tiempo. Para evitar problemas de concurrencia: principalmente en la lista enlazada que guarda información de otros nodos, hice uso de un [Mutex](https://golang.org/pkg/sync/#Mutex) con lo cual pude controlar estos comportamientos que podrían llevar a resultados inesperados.

Algo importante es notar que existen algunos timeouts por defecto que constantemente verifican la lista enlazada de nodos. Básicamente estos timeouts nos permite liberar recursos, cuando un nodo después de cierto tiempo deja de anunciarse.

### El Dashboard
Para el desarrollo del dashboard de frontent hice uso de [React](https://reactjs.org/) solamente. Tal vez algunos se preguntan ¿por qué no utilicé otras librerias como Redux o React-Router?. Pues la respuesta es simple, como el bundle javascript resultante se encuentra embebido en el binario, si tenemos un bundle más grande y pesado, el binario resultante será más grande y pesado.

Los componentes y el código para la UI se encuentra en el directorio `ui`. Para la estructura quise mantener las cosas cosas simple así que utilicé [Create React App](https://github.com/facebook/create-react-app) para este propósito.

De la misma forma para los estilos, si bien podría haber utilizado un procesador como *SASS*, decidí mantener los estilos y solo utilizar el estándar por defecto *CSS*, que como verán en el código es un [archivo](https://github.com/donkeysharp/gocho/blob/master/ui/src/App.css) de 184 líneas de código.

Para generar el bundle javascript solo es necesario ejecutar el siguiente comando.

    $ make dist

Internamente esto utiliza los scripts de Create React App y para poder tener el bundle embebido dentro del binario, hago uso de [Go Generate](https://blog.golang.org/generate).

[Este archivo](https://github.com/donkeysharp/gocho/blob/master/cmd/gocho/gocho.go) tiene un comentario:

{{< highlight go >}}
package main

//go:generate go-bindata -o ../../assets/assets_gen.go -pkg assets ../../ui/build/...

import (
    "github.com/donkeysharp/gocho/pkg/cmds"
    "os"
)
...
{{< /highlight >}}

donde se especifica donde se encuentra el bundle resultante que será embebido en el binario resultante.

### El Índice de Archivos Compartidos
Esta fue una de las partes en las que tuve mucha diversión. Como mencioné en el *Problema 1*, Go presenta un ejemplo para poder compartir un directorio. El problema con esto es que no cuenta con estilos, extensibilidad, el directorio `..` para poder subir un nivel el directorio.

Para poder personalizar este código ya existente tuve que utilizar [Interceptor Pattern](https://en.wikipedia.org/wiki/Interceptor_pattern) y un middleware personalizado para poder adicionar íconos y HTML personalizados, el directorio `..` para ir un nivel hacia arriba y agrupar directorios de archivos de forma ordenada.

Toda la lógica para la personalización de `net/http.FileServer` se encuentra en el archivo [index.go](https://github.com/donkeysharp/gocho/blob/master/pkg/node/index.go).

Espero poder crear otra entrada en la que muestro específicamente la implementación de esta parte que puede ser reutilizada con cualquier otra aplicación.

## Comentarios Finales
Hay varias cosas que deseo mejorar de [Gocho](https://github.com/donkeysharp/gocho). Al ser un proyecto open-source sientanse libres de abrir un issue o mejor contribuir con algo de código (bugfixing, nuevos features, documentación, etc.)

Esta es la primera vez que trabajo en una aplicación, la cual envia y recibe información de varias máquinas o nodos al mismo tiempo y hayan diferentes cosas que sincronizar. Personalmente fue &mdash;y espero siga siendo&mdash; una experiencia educativa.
