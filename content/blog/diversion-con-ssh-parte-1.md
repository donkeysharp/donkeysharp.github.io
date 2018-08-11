---
title: "Diversión con SSH (Parte 1)"
date: 2018-08-11T10:44:57-04:00
draft: true
---

El otro día cenando con mi amigo Francisco, él me comentaba que tiene un proyecto personal en mente y lo que desea conseguir. Escuchando sus preguntas la primera herramienta que pasó por mi cabeza para resolver esos problemas fue utilizar la herramienta OpenSSH.

Esta entrada la hago principalmente para mi amigo Francisco pero la redactaré de forma general para que el benficio sea general.

## Qué es SSH?
[SSH](https://es.wikipedia.org/wiki/Secure_Shell) significa Secure Shell y es un protocolo para administrar servicios en una red mediante un canal cifrado (he ahí el porqué de "Secure" :wink:). Algunas de las tareas más comunes que se pueden realizar con este protocolo es la de poder iniciar sesión en un servidor o máquina en una red o la ejecución remota de comandos.

Al ser SSH solamente un protocolo necesitamos una herramienta que implemente este protocolo. La más utilizada es [OpenSSH](https://es.wikipedia.org/wiki/OpenSSH) y es la herramienta que utilizaremos para esta guía. OpenSSH u otras implementaciones vienen por defecto en sistemas Unix-like (OSX, OpenBSD, FreeBSD, Linux, etc.) y en el caso de Windows personalmente yo instalo [Git Bash](https://git-scm.com/downloads) ya que es una terminal Unix-like en Windows. Otros prefieren utilizar PuTTY.

## Ensuciandono las manos
Para esta guía si bien podríamos probarlo con una máquina virtual o una PC con Linux instalada en una red local, o incluso en la misma máquina local prefiero hacerlo en un entorno más real para probar mi punto, es por eso que crearé un servidor público.

### Creando un servidor público
> **Importante** Si bien esta sección utilizo DigitalOcean, pueden utilizar cualquier servidor público que probablemente tengan u otros cloud providers e.g. [AWS](https://aws.amazon.com/free), [Vultr](https://www.vultr.com/promo25b?service=promo25b), [Linode](https://welcome.linode.com/), etc. La idea es tener un servidor que pueda ser accedido desde internet.

Para esto voy a utilizar el cloud provider DigitalOcean que además de vender servidor virtuales públicos, este tiene una política de cobrar por hora, es decir que una máquina que nos costaría 5 USD al mes, si la utilizamos solo un par de horas, nos costará aproximadamente entre 0.007 a 0.014 centavos de USD. Pueden ver los precios en esta [página](https://www.digitalocean.com/pricing/).

El proceso de creación de un servidor en DigitalOcean es bastante simple, solo un par de clicks y saber elegir la distribución Linux y la cantidad de recursos a asignar. Yo elegiré Debian 9 x64 con 1GB de memoria y me costará 0.007 USD la hora.

Les recomiendo que al momento de crear el droplet para esta guía, lo [asocien con una llave SSH](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/).

Este [link](https://www.digitalocean.com/docs/droplets/how-to/create/) muestra como crear un droplet en DigitalOcean.

### Iniciando sesión por SSH
<!-- TODO: Make a post for cloudinit on digitalocean -->
Por defecto DigitalOcean permite por defecto acceder a los servidores con usuario `root` lo cual es considerado una [mala práctica en términos de seguridad](https://unix.stackexchange.com/questions/82626/why-is-root-login-via-ssh-so-bad-that-everyone-advises-to-disable-it).

Para poder iniciar sesión la forma de hacerlo es en el siguiente formato:

```
$ ssh usuario@servidor
```

Para el caso de DigitalOcean sería:

```
$ ssh root@ip_droplet
```

Una vez conectados al servidor remoto podemos hacer distintas cosas: ejecutar comandos, configurarlo, instalar/desinstalar paquetes, etc. Ya con esto podemos comenzar a jugar un poco con algunas de las cosas divertidas que podemos hacer con SSH.

### Local Port Forwarding
Los explicaré con un ejemplo: imaginemos que tenemos un servidor público, y detrás de este existe una red privada donde pueden haber servidores de base de datos, servicios disponibles solo en la red privada, etc. Entonces al estar estos en una red privada no hay una forma directa de acceder a ellos desde internet. Algunas opciones para poder acceder a servicios detrás de una red privada es utilizando una VPN o utilizar Local Port Forwading.

Veamos la siguiente configuración:

![](/img/ssh_guide_1.png)

En la imagen vemos que existe un servidor de base de datos MySQL en una red privada con la dirección IP `10.100.1.23` y puerto `3306` y existe un servidor público con la dirección IP `152.190.23.56`.

Si desearamos acceder a este servidor de base de datos tendríamos que estar dentro de la red privada lo cual no es cierto ya que nosotros estamos en la red local (privada) de nuestra casa, universidad, trabajo, etc. Por suerte el servidor `152.190.23.56` tiene acceso a esta red privada además de poder acceder a este desde internet.

Lo que haremos es utilizar la característica de Local Port Forwarding de OpenSSH para crear un canal seguro por medio del servidor público `152.190.23.56` entre el puerto `3306` de mi máquina local (PC o laptop) hacia el puerto `3306` del servidor privado de base de datos `10.100.1.23`.

El formato de ejecución es el siguiente:

```
ssh -nNT -L puertoA:host_privado:puertoB usuario@servidor
```

Donde:

- `-n` evita leer desde STDIN o leer la escritura por línea de comandos
- `-N` no ejecutar un comando remoto
- `-T` deshabilitar la opción de mostrar una terminal
- `-L` indicador de Local Port Forwarding
- `puertoA` puerto de nuestra computadora donde será expuesto el servicio remoto (MySQL)
- `host_privado` la dirección IP del host al cual no podemos llegar públicamente pero si a través del servidor público
- `puertoB` puerto TCP del servicio que el `host_privado` esta exponiendo

En nuestro ejemplo sería algo similar a:

```
ssh -nNT -L 3306:10.100.1.23:3306 root@ip_droplet
```

Es importante saber que si tuvieramos instalado MySQL en nuestra computadora local habría un conflicto por el puerto `3306` entonces como este puede ser cualquier puerto podemos utilizar otro puerto:

```
ssh -nNT -L 3307:10.100.1.23:3306 root@ip_droplet
```

Ahora imaginemos el caso en que yo en mi red local de casa, universidad o trabajo existe gente que desea acceder al servidor de base de datos. La respuesta simple es que ellos podrían aplicar el mismo procedimiento y tener acceso a MySQL desde sus máquinas locales.

En el supuesto caso que existiera la restricción de que ellos no tengan y no deban tener acceso al servidor público, una solución es que yo exponga el servicio de MySQL en la red local utilizando Local Port Forwarding y otras máquinas en mi red local puedan conectarse a mi computadora como si yo estuviera exponiendo un servicio MySQL pero en realidad estoy exponiendo el servicio MySQL que esta corriendo en una red privada en algún lugar del mundo.

El diagrama muestra lo que deseo consguir:

![](/img/ssh_guide_2.png)

Para poder conseguir esto solo adicionamos un pequeño cambio a la ejecución previa y debemos ejecutar en el siguiente formato:

```
ssh -nNT -L ip_local:puertoA:host_privado:puertoB usuario@servidor
```
Donde

- `ip_local` es la dirección IP de nuestra máquina en la red local privada, de no estar seguros cual es esta simplemente podemos poner el valor `0.0.0.0` para exponer por cualquier interfaz de red.

```
ssh -nNT -L 192.168.1.100:3306:10.100.1.23:3306 root@ip_droplet
```
De este modo las demás máquinas en nuestra red local podrán conectarse a `192.168.1.100:3306` y así acceder al servicio de MySQL.

### Reproduciendo el ejemplo en nuestro servidor público
Una ventaja que MySQL por defecto no expone su puerto `3306` a ninguna red por seguridad. Entonces si instalamos MySQL en nuestro servidor público el puerto `3306` no será expuesto al público y este lo podríamos considerar como si estuviera en una "red privada" y poder aplicar lo aprendido.

Para instalar MySQL ejecutamos los siguiente:

```
$ apt install mysql-server
```


