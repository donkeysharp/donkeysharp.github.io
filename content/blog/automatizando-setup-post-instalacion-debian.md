---
title: "Automatizando setup post-instalación en mis máquinas Debian"
date: 2019-05-13T21:45:39-04:00
draft: false
---

Hola, hace un tiempo [publiqué sobre el setup inicial]({{< ref "/blog/my-computer-setup.md" >}}) que tengo en los equipos Debian con los que trabajo, como ser: aplicaciones, configuraciones de apariencia del escritorio, etc. Los últimos meses instalé y reinstalé Debian varias veces en los equipos con los que trabajo (nuevos, actualizaciones de un nuevo disco duro, etc.) y ya se volvió una tarea repetitiva.

Básicamente lo que realizaba es revisar mi anterior entrada de blog y repetía esas acciones. Hasta ahora me funcionó, pero al volverse repetitivo me animé en automatizar todo este proceso tanto de instalación y configuración de ciertas aplicaciones como el manejo de la apariencia del escritorio (con el setup que siempre utilizo).


## La Idea
Si bien podría haber hecho este proyecto utilizando un simple script Bash, me animé por utilizar Bash + [Ansible](https://docs.ansible.com/) a modo de practicar y divertirme :smile:.

Lo que tenía en mente al momento de iniciar este proyecto fue que ni bien termine la instalación del sistema operativo (en mi caso la distribución Debian), solo tendría que ejecutar un comando y "mágicamente" todas las apliaciones, configuraciones, etc. sobre mi [setup personal]({{< ref "/blog/my-computer-setup.md" >}}) se aplicarían.

## Analizando el Proyecto
Este proyecto lo publiqué en [Github](https://github.com/sguillen-proyectos/fresh-install-setup/) si desean ver el código fuente.

Al ser este un proyecto que utiliza Ansible, existe cierta convención en cuestión a árbol de directorios, nombres de archivos, etc. Decidí utilizar la siguiente estructura:

```
├── init-setup.sh
├── inventory
├── README.md
├── roles
│   ├── chrome
│   ├── common
│   ├── docker
│   ├── dotenvs
│   │   ├── tasks
│   │   └── templates
│   ├── games
│   │   └── tasks
│   │       └── main.yml
│   ├── mysql
│   │   ├── files
│   │   └── tasks
│   ├── node
│   ├── php7
│   ├── virtualbox
│   ├── vscode
│   └── xfce4
├── setup-playbook.yml
└── update-desktop-layout.sh
```

En Ansible lo que se denominaría como el programa principal es el `playbook` el cual se encarga de ejecutar diferentes tareas en contra de uno o más servidores, en este caso, el programa principal de Ansible sería el archivo `setup-playbook.yml`. Como se puede ver este archivo tiene una sección llamada `roles`.

> **Nota:** En Ansible lo que se denomina `role` llega a ser una pieza de código reutilizable (como un módulo). Esto nos permite tener el proyecto mejor organizado y cuenta con una estructura interna de directorios como se ve en el árbol de directorios de arriba.

Dividí el proyecto en diferentes roles, cada uno para un diferente propósito como ser: una aplicación específica o un grupo de aplicaciones incluidas sus configuraciones. Por ejemplo, en el role `common` instala todas las utilidades de escritorio y las utilidades de línea de comandos que utilizo día a día. Y en general hay roles para cosas específicas que utilizo, Docker, herramientas y tecnologías de desarrollo de software y otros. Si tienen más curiosidad pueden revisar el repo :smile:.

Siguiendo con la explicación, dentro de Ansible existe un concepto bastante importante que es el `inventory`, el cual indica todos los servidores en los que se aplicarán las tareas especificada en los roles. Este proyecto tiene un archivo llamado `inventory` con opciones particulares, ya que todas las tareas no se ejecutarán en contra de varios servidores, sino en contra de uno solo y es la misma máquina local.

```
[local]
localhost ansible_connection=local
```

Lo explico: `[local]` es el grupo de servidores, yo lo denominé `local` pero podría llamarse cualquier cosa, lo importante es que si se cambiase de nombre, este nombre también debería reflejarse en `setup-playbook.yml` en `hosts: local`. Luego la siguientes líneas indican el hostname que en este caso es `localhost` y `ansible_connection=local` que indica que será una ejecución local y de ese modo evitar el proceso de autenticación por SSH que Ansible realiza en cada ejecución hacia la misma máquina.

Finalmente el script `init-setup.sh` es un wizard el cual pregunta por ciertas opciones antes de realizar todo el proceso de instalación y configuración. Este llegaría a ser el comando "mágico" que se encarga de todo:

```
wget https://raw.githubusercontent.com/sguillen-proyectos/fresh-install-setup/master/init-setup.sh && bash init-setup.sh
```

## ¿Qué gano con esto?
Bueno, primero aprendí un par de cosas que no sabía sobre Ansible, me divertí y lo más importante para mí (además que era el objetivo de este proyecto) es que ahora me ahorro todo el tiempo de configuración manual que realizaba en un sistema operativo recién instalado.

Si bien ya tenía mi [guía]({{< ref "blog/my-computer-setup.md" >}}) de qué paquetes instalar y que configuraciones realizar, eso me tomaba entre una a dos horas, ahora todo este tiempo de setup esta principalmente condicionado a la velocidad de internet.

Algo en este proyecto que es bastante útil para mí, es que logré uniformizar mis configuraciones de escritorio (en este caso Xfce4), ya que en muchas ocaciones el "estilizar" mi escritorio es en lo que más perdía mi tiempo.

## Comentarios Finales
Si bien este proyecto solo esta orientado para mi setup personal, decidí compartirlo por si la idea de automatizar el environment le sirve a alguna de las personas que lean esta entrada.

Durante el tiempo que invertí para realizar este proyecto sucedieron varias cosas divertidas y que me hicieron renegar de las cuales aprendí algo nuevo. Escribiré sobre esa serie de eventos desafortunados en una siguiente entrada.

Happy Hacking!
