---
title: "Gocho - Compartir Archivos En Una Red Local"
date: 2018-03-21T22:22:46-04:00
draft: true
---

Holas, durante mi tiempo libre estuve trabajando en un proyecto llamado [Gocho](https://github.com/donkeysharp/gocho). Esta pequeña aplicación permite compartir archivos en una red local e.g. red de la casa, red del trabajo, etc. En este post explicaré de que se trata, por qué lo hice y algunos de los retos que surgieron al hacer la aplicación.

## Por qué lo hice?
Este tipo de proyectos siempre lo hago modo de aprender algo nuevo. En este caso ya desde el año pasado (2017) tenía ganas de hacer algo con [Go](https://golang.org/). Si bien hice uno que otro experimento con Go en el pasado a modo de aprender ([Golondrina](https://github.com/donkeysharp/golondrina); [EazyPanel](https://github.com/donkeysharp/eazy-panel)), aún seguía con ganas de hacer algo que otros pueda utilizar.

En la empresa donde trabajo actualmente existe una diversidad en cuestión a sistemas operativos, algun@s compañer@s utilizan Windows, OSX y otr@s GNU/Linux. Si bien existe un Active Directory o algo similar configurado, desde que entré a trabajar hasta ahora nunca pude lograr acceder a las carpetas compartidas de otros. Al intentar acceder me salía la opción de insertar un dominio y credenciales; pese a que introducía los datos que en teoría eran correctos no lograba acceder a los archivos compartidos.

Al parecer no era el único que tenía este tipo de problemas y otros compañeros compartian archivos e.g. videos, cursos, etc. montando un servidor `httpd` o en mi caso ejecutando `python -m SimpleHTTPServer` en el directorio que deseaba compartir. El problema que encontré a esta opción es que con pocas personas tratando de descargar el mismo archivo (3 o 4 a lo que probé) comenzaban a saltar excepciones y en algunos casos el pequeño servidor HTTP moría.

Mi segundo intento fue utilizar algo un poco más robusto que `SimpleHTTPServer` pero sin la necesidad de levantar algo grande como `httpd`. Tuve la suerte de chocar con un ejemplo en la documentación de Go para el modulo `net/http` que justamente &mdash;con pocas líneas de código&mdash; me permitía compartir un directorio y podía soportar sin problemas varias descargas simultáneas.

{{< highlight go >}}
package main

import (
    "log"
    "net/http"
)

func main() {
    // Simple static webserver:
    log.Fatal(http.ListenAndServe(":8080", http.FileServer(http.Dir("/usr/share/doc"))))
}
{{< /highlight >}}


