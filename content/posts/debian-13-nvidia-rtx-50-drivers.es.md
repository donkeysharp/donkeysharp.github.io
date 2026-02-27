---
title: "Instalando Nvidia RTX serie 50 en Debian 13 Trixie"
url: "instalando-drivers-nvidia-rtx-50-debian13-trixie"
date: 2026-02-27T08:02:12-04:00
tags: ["homelab", "linux", "nvidia", "drivers"]
draft: false
---

![](/img/nvidia-drivers/nvidia-setup.jpeg)

> Traducido del artículo original en Inglés

¡Hola a todos! En este post les voy a mostrar el proceso de instalación de los Drivers Oficiales de Nvidia para Linux para las tarjetas gráficas RTX serie 50 en Debian 13 (Trixie). Algunos problemas que encontré y otros escenarios a considerar como actualizaciones del sistema operativo.

Algo que me encanta de usar GNU/Linux es que hay múltiples formas de resolver un problema. Y a veces dependerá del hardware que estés usando, arquitectura, entorno de escritorio, etc, etc.

Hay dos opciones, la forma recomendada (usando repositorios de Nvidia) y la otra alternativa que es instalar el archivo `.run`. Les mostraré ambas.

¡Manos a la obra!

## Mi relación de amor con Debian
Mi mejor amigo me presentó Debian en 2009, era Debian 5 (Lenny), y lo he usado desde entonces, inicialmente como dual-boot cuando Windows XP todavía existía y en 2013 empecé a usar Debian al 100% para todo lo que hacía, incluyendo trabajo. Probé otras distribuciones, y personalmente me gustó Debian porque es aburrido y simplemente funciona, hace todo lo que tiene que hacer para mí. Generalmente no necesito la última versión de todo el software, y después de que empecé a usar Docker en 2015, tener la última versión de la mayoría del software ya no fue un problema para mí. Por supuesto para ciertas cosas que no funcionaban out-of-the-box, tuve que hacer un par de fixes, pero el 99% del tiempo, todo lo que necesito funciona bien. Siempre he usado la versión estable, ni testing ni sid.

Algo importante de mencionar es que no uso hardware nuevo ni GPU nuevas, me gusta comprar computadoras reacondicionadas/usadas, generalmente las que salieron hace 5 años como Thinkpads, u otras workstations de escritorio usadas. Y no tuve problemas con drivers, compatibilidad, etc. Todo funcionó de maravilla para todo lo que necesitaba.

Desde mediados de 2025, empecé a investigar sobre IA y decidí hacerlo en mi setup local y no en la nube (estaba usando AWS), así que esta vez decidí comprar las partes para una computadora de escritorio nueva, y una de las partes es una Nvidia RTX 5070 Ti, que salió hace casi un año.

Sorpresa, sorpresa. ¡Debian 13 no funcionó con la RTX 5070 Ti! Debian no soporta oficialmente los drivers más recientes para este modelo.

Entonces cuando instalas Debian y en tu primer arranque, verás la pantalla negra con el cursor de la terminal parpadeando. Eso significa que tu entorno de escritorio no cargó porque no tienes los drivers apropiados instalados para tu tarjeta gráfica.

En ese caso podrías conectarte por ssh a tu máquina desde otra máquina, o usar la TTY (esa terminal negra), para ejecutar los siguientes pasos, dependere de tí!

## Instalación del driver
### Deshabilitar Nouveau
Por defecto, Debian instalará el módulo del kernel Nouveau, necesitamos ignorarlo.

Primero verifiquemos si Nouveau está siendo usado:

```sh
lspci -nnk | less # y busca VGA Controller

01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GB203 [GeForce RTX 5070 Ti] [10de:2c05] (rev a1)
      Subsystem: ASUSTeK Computer Inc. Device [1043:89f4]
      Kernel modules: nouveau
```

En este caso el módulo del kernel está siendo usado, así que necesitamos ponerlo en lista negra. Creemos el siguiente archivo `/etc/modprobe.d/blacklist-nouveau.conf` con el siguiente contenido:

```
blacklist nouveau
options nouveau modeset=0
```

Recreemos el `initramfs` que es requerido cada vez que queremos habilitar/deshabilitar módulos del kernel y reiniciemos la instancia:

```sh
sudo update-initramfs -u
sudo reboot
```

De nuevo, sin interfaz gráfica de usuario (es esperado) así que nos logueamos en modo terminal y validamos que el driver del kernel Nouveau ya no está siendo usado.

```sh
lsmod | grep nouveau
# no debería imprimir nada
```

### Requisitos
Primero, desinstalemos cualquier paquete relacionado con nvidia, no deberías tener ninguno en caso de que tengas una instalación fresca.

```sh
apt remove --purge '*nvidia*'
```

Necesitamos instalar algunas utilidades de compilación para compilar los drivers oficiales de Nvidia. Para eso ejecutamos:

```sh
apt update
apt install linux-headers-$(uname -r) build-essential libglvnd-dev pkg-config dkms
```

### Método A: La forma recomendada, usando repositorios de Nvidia
Este método también se menciona en la [documentación oficial de Debian](https://wiki.debian.org/NvidiaGraphicsDrivers#Nvidia-packaged_data-center_drivers).

Es un método muy simple, agregas el repositorio APT, actualizas, e instalas los drivers. Sin embargo la [documentación oficial de Nvidia](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/debian.html) (al momento de escribir esto 2026-02-27) no está actualizada y algunos enlaces que sugieren están rotos. Así que si quieres ir con este método, te recomiendo el siguiente video en su lugar:

{{< youtube FaDENzwkzys >}}

> **Nota Importante:**
> Es importante notar que al momento en que ese video fue grabado, Nvidia tenía un repositorio APT que solo soportaba Debian 12, sin embargo es compatible con Debian 13 (se menciona en el video).
>
> Si usas el método del video hoy, verás que agregar el repo de Nvidia agregará un repo para Debian 13 ahora, sin embargo solo tiene la versión 590 del Driver que todavía está en desarrollo. Así que te recomiendo usar el repo de Debian 12 para las versiones 580.x.x del driver.

### Método B: Usando el instalador .run
Para este método necesitas descargar el instalador `.run` del sitio web de Nvidia y [buscar los drivers disponibles](https://www.nvidia.com/en-us/drivers/) para la RTX 5070 Ti.

![](/img/nvidia-drivers/00-driver-search.png)

En mi caso elegí la última versión y después de descargarlo, debes agregar permisos de ejecución al archivo `.run`.

![](/img/nvidia-drivers/01-driver-choice.png)

```sh
chmod +x NVIDIA-Linux-x86_64-580.126.18.run
```

Ahora ejecutémoslo de la siguiente manera:
```sh
sudo ./NVIDIA-Linux-x86_64-580.126.18.run --dkms
```

El flag `--dkms` significa que el driver de Nvidia será reconstruido automáticamente cuando actualicemos nuestro SO con una nueva versión del kernel de Linux. ([Ver siguiente sección](#método-b-actualizando-debian-13)).

![](/img/nvidia-drivers/02-driver-installer.png)

Asegúrate de elegir MIT/GPL, ya que para los modelos más recientes, debemos usar la versión oficial open source de los drivers (gracias Lapsus$).

Sigue los siguientes pasos aceptando DKMS, construir initramfs, actualizar configuración de X11.
![](/img/nvidia-drivers/04-driver-installer-X-server.png)
![](/img/nvidia-drivers/05-driver-installer.png)
![](/img/nvidia-drivers/06-driver-installer.png)
![](/img/nvidia-drivers/06-driver-installer.png)
![](/img/nvidia-drivers/07-driver-installer.png)
![](/img/nvidia-drivers/07-driver-installer.png)
![](/img/nvidia-drivers/07-driver-installer.png)
![](/img/nvidia-drivers/08-driver-installer.png)
![](/img/nvidia-drivers/09-driver-installer.png)
![](/img/nvidia-drivers/10-driver-installer.png)

Y eso es todo. Una vez que la instalación termine, reinicia tu computadora y podrás usar tu entorno de escritorio como siempre.

Para asegurarte de que todo está funcionando, solo ejecuta el programa `nvidia-smi`:

![](/img/nvidia-drivers/05-debian-nvidia-smi.png)

### Método B: Actualizando Debian 13
Cuando intentes actualizar a la última versión de Debian disponible, es muy probable que haya una nueva versión del kernel de Linux para instalar. Eso significa que el driver que instalaste previamente ya no funcionará porque fue compilado para la versión anterior del kernel.

Si instalaste el driver `.run` con DKMS, la actualización debería funcionar de maravilla y reconstruirá el driver y lo instalará durante la actualización.

```sh
sudo apt update
sudo apt upgrade -y
```

Verás que durante la actualización, el módulo del kernel está siendo construido para la nueva versión del kernel.

![](/img/nvidia-drivers/03-driver-debian-upgrade.png)


¡Actualizar mi SO funcionó de maravilla! Sin pasos difíciles o adicionales.

## Pensamientos finales
Personalmente, después de probar ambos métodos, me quedaré con el método **no recomendado**, solo para ver cómo funciona y experimentar.

De hecho tuve algunos problemas con **xfce4**, no estaba relacionado con el método de instalación, sino con algunas configuraciones del compositor que empezaron a fallar con versiones posteriores a `580.105.08`. Lo escribiré con más detalle en mi próximo post sobre cómo arreglar ese problema.

Como mencioné, Debian no me causó problemas en el día a día, pero tiene sentido ya que uso hardware viejo la mayor parte del tiempo. De hecho, estoy escribiendo este post desde una Thinkpad T450 (lanzada hace más de una década). Pero esta vez tengo hardware que no es viejo, tenía sentido que necesitaría hacer algunos pasos extra.

¡Happy hacking!

## Referencias
- https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/debian.html#debian-installation
- https://wiki.debian.org/GraphicsCard
- https://www.nvidia.com/en-us/drivers/unix/
- https://wiki.debian.org/NvidiaGraphicsDrivers#Nvidia-packaged_data-center_drivers
