---
title: "Gocho, Compartir Archivos En Una Red Local"
date: 2018-03-21T22:22:46-04:00
draft: true
---

Holas, durante mi tiempo libre estuve trabajando en un proyecto llamado [Gocho](https://github.com/donkeysharp/gocho). Esta pequeña aplicación permite compartir archivos en una red local, por ejemplo la red de la casa, red del trabajo, etc. con la característica de auto-descubrimiento de nodos (self-discovery). En este post explicaré de que se trata, por qué lo hice y algunos de los retos que surgieron al hacer la aplicación.

## Por qué lo hice?
Lo hice porque deseaba una aplicación donde pueda compartir un directorio; poder aguantar varias descargas al mismo tiempo; no tener que preguntar la dirección IP o puerto de los recursos que otros comparten; tener algo que sea simple de ejecutar en cualquier sistema operativo (Windows, OSX, GNU/Linux) sin tener que instalar ningún requisito previo.

Este tipo de proyectos siempre los hago a modo de aprender algo nuevo. En este caso ya desde el año pasado (2017) tenía ganas de hacer algo con [Go](https://golang.org/). Si bien hice uno que otro experimento a modo de aprender ([Golondrina](https://github.com/donkeysharp/golondrina); [EazyPanel](https://github.com/donkeysharp/eazy-panel)), esta aplicación me pareció un buen caso de uso para este lenguaje en específico (lo elaboro más adelante).

## Por qué Go?
Si alguien ya ejecutó la aplicación es fácil notar que no es algo de otro mundo. Gocho podría haber sido desarrollado en otros lenguajes como: C/C++, Python, Ruby, Java, CSharp, etc.

La verdadera razón por la que decidí utilizar Go es por la facilidad de distribución, cosa que no puedo lograr con los anteriores mencionados (excepto C/C++) sin tener que instalar algo antes:

* Python/Ruby necesitan tener instalado el intérprete, en Windows no vienen por defecto
* Java/CSsharp, necesitan tener instalado las máquinas virtuales respectivas JVM, .NetCore
* En el caso de C/C++, si bien puedo leerlos y entenderlos, aún no agarré valor para poder lanzarme a realizar un proyecto con alguno de estos lenguajes.

Otra cosa que me encanta de Go es la capacidad de compilar binarios para diferentes plataformas desde una misma máquina. Yo utilizo GNU/Linux y pude compilar binarios para Windows y OSX sin nigún problema.

## Algunos Problemas que Encontré

### Problema 1: Compartir Archivos
En la empresa donde trabajo, existe una diversidad en cuestión a sistemas operativos, algun@s compañer@s utilizan Windows, OSX y otr@s GNU/Linux. Si bien existe un Active Directory o algo similar configurado, personalmente nunca pude lograr acceder a las carpetas compartidas por otros (uso GNU/Linux). Al intentar acceder me salía la opción de insertar un dominio y credenciales; pése a que introducía los datos &mdash;que en teoría eran correctos&mdash; no lograba acceder a los archivos compartidos.

En el trabajo hay compañeros que comparten archivos por ejemplo videos, cursos, etc. montando un servidor `httpd` en su máquina local o en mi caso ejecutaba `python -m SimpleHTTPServer` en el directorio que deseaba compartir. Noté un problema con `SimpleHTTPServer`, con pocas personas tratando de descargar el mismo archivo, esta pequeña utilidida solo permite manejar una descarga al mismo tiempo.

Mi segundo intento fue utilizar algo un poco más robusto que `SimpleHTTPServer`, pero sin la necesidad de levantar algo grande como `httpd`. Tuve la suerte de chocar con un ejemplo en la documentación de Go para el modulo `net/http` que justamente &mdash;con pocas líneas de código&mdash; me permitía compartir un directorio y podía soportar varias descargas simultáneas sin problemas.

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

Solo tuve que compilar este archivo; poner el binario que llamé `http` en algún directorio que se encuentre en mi `PATH` de ejecución y viola! ya contaba con algo más robusto que pueda aguantar más descargas y no tenga que montar todo un servicio.

>> *ya contaba con algo más robusto que pueda aguantar más descargas*
>
> Con esto me refiero a algo que aguante varias conexiones simultáneas, algo que Go lo plantea de una manera simple y en el caso del módulo `net/http` ya viene por defecto.

Hasta este punto, solamente tengo un pequeño binario que me permite compartir un directorio y pueda aguantar varias descargas simultáneas. Algo no tan complejo como montar un servicio `httpd` pero más robusto que `SimpleHTTPServer` de Python.

### Problema 2: Indicar Donde se Encuentran los Archivos Compartidos
Otro problema que encontré es, que cada vez que un usuario comparte algo en una red local, este debe &mdash;de algún modo&mdash; comunicar como acceder a los recursos que este comparte. Una forma común de realizar esto es compartir la url de descarga `http://ip_red_local:algun_puerto` en algun grupo de chat o similar.

Ya que esta aplicación la tengo orientada para el contexto de una red local, algo que se me pasó por la cabeza son los juegos en red ejemplo StarCraft. En StarCraft cuando alguien crea una partida de red de área local, los jugadores que se unirán a una partida no especifican como tal la dirección IP de la máquina servidor a la que se conectarán. El juego simplemente muestra las partidas creadas en la red actualmente y uno puede conectarse sin problemas de forma automática.

Investigando un poco sobre el cómo estos juegos hacian posible mostrar las partidas ya existentes en la red sin tener que especificar una dirección IP o algo similar, me llevó al concepto de [multicast](https://en.wikipedia.org/wiki/Multicast).

En palabras simples, Multicast es un método que permite enviar información a nodos interesados en una red.

Por ejemplo, si deseo enviar el mensaje "hola mundo" a computadoras interesadas en recibir este mensaje sin que yo tenga que saber a qué máquinas específicamente, la idea sería la siguiente:

* *Mi Computadora*: Enviar datagrama UDP con mensaje "hola mundo" a alguna [dirección IP reservada para multicast](https://en.wikipedia.org/wiki/Multicast_address#IPv4) ej. 239.6.6.6:1234
* *Computadora Interesada 1*: Escuchar por datagramas UDP en 239.6.6.6:1234
* *Computadora Interesada 2*: Escuchar por datagramas UDP en 239.6.6.6:1234
* *Computadora Interesada n*: Escuchar por datagramas UDP en 239.6.6.6:1234

De este modo Multicast permite que cualquier máquina que desee compartir algo simplemente enviará su información de nodo (identificador, dirección IP, puerto) por multicast y otras máquinas interesadas, además de compartir podrán saber que otras máquinas estan compartiendo algo.

Ya viendo un poco la implementación de esto, podemos ver algunos trozos de código que utilicé en Gocho.

[pkg/node/net.go](https://github.com/donkeysharp/gocho/blob/master/pkg/node/net.go)

Donde existe la función  `announceNode` que básicamente envía un paquete multicast.

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

Y una función `listenForNodes` que escucha los mensajes multicast.

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

