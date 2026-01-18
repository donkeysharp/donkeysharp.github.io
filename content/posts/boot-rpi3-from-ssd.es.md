---
title: "Arrancando Raspberry Pi 3 Model B desde SSD"
url: "boot-rpi-3-model-b-from-ssd"
date: 2026-01-18T08:11:13-04:00
tags: ["rpi", "homelab", "linux"]
draft: false
---

![alt text](/img/rpi-homelab.jpeg)

> Versión traducida automáticamente a Español de [la versión original](/boot-rpi-3-model-b-from-ssd).

Hola a todos! En este post voy a compartir mi experiencia arrancando la Raspberry Pi 3 Model B desde un SSD por USB. Aunque es algo que hice hace casi un año, quería compartirlo... ¡perdón por el retraso de 1 año xD!

> Probablemente haya algo que se me haya pasado en mi solución, así que cualquier feedback es apreciado!

Antes que la pandemia inicie, un amigo me vendió 4 Raspberry Pi 3 Model B y un Raspberry Pi 3 Model B+. Los usé para un proyecto de electrónica + domótica que ya no necesito, así que decidí reutilizarlos para algo nuevo, un nuevo proyecto en el que comencé a trabajar y del cual haré otra entrada de blog.

Esta vez, como no iba a usar los RPIs para electrónica, sino para algo que requeriría más uso de disco, quería probar algo que personalmente no había intentado antes. Quería arrancar los RPIs desde un SSD. En lugar de gastar dinero en tarjetas SD nuevas, confiables y rápidas, decidí usar algunos SSDs que tenía guardados. Esto definitivamente es algo que ya se había hecho antes, pero en mi caso hubo algunos detalles que me tomaron varios días descubrir cómo solucionar, y quería compartir esa experiencia con ustedes.

### Mi setup
Para este experimento usé:

- 4 RPI 3 Model B
- 1 RPI 3 Model B+
- 5 power supplies con el voltaje y amperaje adecuados
- 5 SSDs
- 5 conversores USB a SATA

## Arrancando desde SSD
Hay múltiples publicaciones de blogs, entradas de foros y ahora LLMs que explican cómo arrancar una RPI desde un SSD (agregué las referencias que usé en la sección de referencias más abajo). En resumen, los pasos requeridos para que la RPI 3 Model B arranque por USB desde un SSD son los siguientes:

- Usando una tarjeta SD con RaspberryPI OS instalado, ejecutar una actualización completa:
  ```sh
  sudo apt update -y && sudo apt full-upgrade -y
  ```
- El siguiente comando dará dos posibles resultados dependiendo de si el arranque por USB está habilitado o no:
  ```sh
  vcgencmd otp_dump | grep 17
  17:1020000a <<<< significa que el arranque USB está deshabilitado
  17:3020000a <<<< significa que el arranque USB está habilitado
  ```
- En caso de que esté deshabilitado, la forma de habilitarlo es agregando las siguientes líneas al `/boot/firmware/config.txt`. Algunos tutoriales mencionan `/boot/config.txt` pero esos están desactualizados.
  ```sh
  program_usb_boot_mode=1
  program_usb_boot_timeout=1
  ```
- Finalmente, clonar el contenido de la tarjeta SD que tiene RaspberryPI OS al SSD, puedes hacerlo con dd:
  ```sh
  # /dev/mmcblk0 es la tarjeta SD en mi caso
  # /dev/sdb es el SSD conectado por USB
  dd if=/dev/mmcblk0 of=/dev/sdb status=progress
  ```
- Luego retirar la tarjeta SD de la RPI, conectar el SSD por USB y reiniciar.
- ¡Felicidades! Arrancaste tu RPI desde USB y un SSD. Ahora puedes redimensionar particiones y demás.

Ese es el resultado que deseaba tener, pero no, no funcionó para 4 de mis 5 RaspberryPIs. Déjame contarte cómo lo solucioné (más o menos).

## La diferencia entre RPI3 Model B y RPI3 Model B+
Ejecuté los pasos anteriores primero (por coincidencia en el RPI 3 **Model B+**). Y funcionó de maravilla. Luego para los siguientes RPIs 3 Model B (no B+) no funcionó, probé los 4 RPIs con el mismo resultado. Me aseguré de agregar la configuración `program_usb_boot_timeout=1` al archivo `/boot/firmware/config.txt` para aumentar el tiempo de espera para que la RPI detecte el disco, incluso con esa verificación no funcionó. No hubo arranque USB para los RPIs 3 Model B.

En ese punto, llegué a la conclusión de que al menos en términos de arranque, el RPI 3 Model B y el RPI 3 Model B+ tienen diferencias.

### Mi solución (de chiripa)
Después de probar múltiples combinaciones que no funcionaron, funcionó! Verifiqué en la terminal y efectivamente, arrancó desde el SSD. Ejecuté algunas pruebas de velocidad de IO para asegurarme de que realmente estaba usando el SSD. ¡Finalmente funcionó!

El nuevo problema era que no agregué ningún cambio de configuración nuevo xD, así que estaba super confundido de por qué funcionó. Y noté que esta vez olvidé remover la tarjeta SD. Tanto la SD como el SSD USB estaban conectados.

Mi hipótesis era que para el RPI 3 Model B, todavía se requiere una tarjeta SD para arrancar, sin importar si el sistema operativo está instalado en un SSD USB.

Para finalmente verificar esa hipótesis, formateé la tarjeta SD y simplemente copié el contenido del directorio `/boot/` desde el SSD, en realidad **deben** ser iguales.

¡Voilà! ¡Arrancó de nuevo!

Con esa prueba, estaba seguro de que la **RPI 3 Model B requiere una tarjeta SD para arrancar sin importar dónde esté ubicado el SO**.

Usé las tarjetas SD de mi proyecto anterior, las formateé y copié el contenido de `/boot/firmware` desde cada SSD y funcionó bien.

Es importante **no** copiar el contenido del directorio `/boot/firmware` de **un SSD a todas las tarjetas SD**, ya que cada SSD tiene un UUID diferente especificado en el archivo `/boot/firmware/cmdline.txt`. Copia desde cada SSD o asegúrate de que el `/boot/firmware/cmdline.txt` tenga los valores correctos para el UUID del disco.

Un ejemplo del `cmdline.txt`
```
console=serial0,115200 console=tty1 root=PARTUUID=e000a75d-02 rootfstype=ext4 fsck.repair=yes rootwait cfg80211.ieee80211_regdom=US cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```

### Actualizando el sistema operativo
Todos los pasos que mencioné antes ocurrieron cuando el último RaspberryPI OS estaba basado en Debian 12. Ahora que la última versión de RaspberryPI OS fue lanzada basada en Debian 13, decidí que en lugar de formatear y hacer el mismo proceso desde cero, seguiría los pasos para hacer una actualización mayor de RaspberryPI OS.

Estos son los pasos que seguí para esto:

- Editar `/etc/apt/sources.list` y `/etc/apt/sources.list.d/raspi.list` y cambiar de `bookworm` a `trixie`.
- Ejecutar `apt update` para refrescar los índices de paquetes
- Ejecutar `apt install -y apt dpkg` para instalar la última versión del gestor de paquetes.
- Ejecutar `apt upgrade --without-new-pkgs` para instalar la última versión sin instalar nuevas dependencias. Asegúrate de que todo esté bien.
- Finalmente `apt full-upgrade`
- Reiniciar

Eso sería suficiente en cualquier configuración (funciona en el **RPI 3 Model B+**), pero en este caso como arrancamos desde la tarjeta SD primero y no desde el SSD, necesitaremos seguir algunos pasos extra.

Recordemos algo de teoría de Linux: La imagen del kernel de Linux está ubicada en el directorio `/boot`, pero en nuestro caso la RPI arranca desde la SD. Todavía tenemos el contenido de arranque de la instalación anterior. Después de la actualización cuando reinicié, el kernel seguía siendo `6.1` y no `6.12` que es el que viene con Debian 13.

Para tener la actualización 100% lista, tuve que repetir los pasos anteriores que hice para hacer que la RPI arranque desde el SSD.
- Montar la tarjeta SD `mount /dev/mmcblk0p1 /mnt/sdboot/`,
- Copiar `/boot/firmware` del SSD a la tarjeta SD: `cp -r /boot/firmware/* /mnt/sdboot/`
- Reiniciar

Después de seguir esos pasos, pude tener la actualización 100% funcional.

### Si quieres usar contenedores
En caso de que quieras usar contenedores o un orquestador de contenedores como K3S, asegúrate de que los campos `cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory` estén configurados en el `/boot/firmware/cmdline.txt`

## Referencias
- [https://forums.raspberrypi.com/viewtopic.php?t=359795](https://forums.raspberrypi.com/viewtopic.php?t=359795)
- [https://www.makeuseof.com/how-to-boot-raspberry-pi-ssd-permanent-storage/](https://www.makeuseof.com/how-to-boot-raspberry-pi-ssd-permanent-storage/)
- [https://pysselilivet.blogspot.com/2020/10/raspberry-pi-1-2-3-4-usb-ssd-boot.html](https://pysselilivet.blogspot.com/2020/10/raspberry-pi-1-2-3-4-usb-ssd-boot.html)
