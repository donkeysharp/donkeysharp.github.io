---
title: "Mis Configuraciones De Escritorio en Debian"
date: 2018-03-09T23:15:16-04:00
draft: false
---

> **Update**
>
> *2018-04-28* Added more packages I use and new settings I do (reinstalled machine)

En esta entrada explico las aplicaciones y configuraciones que uso para mi máquina de desarrollo local.

*Sistema Operativo:* GNU/Linux - Debian Stretch

*Dektop Manager:* xfce4

## Aplicaciones usadas frecuentemente
Estas son las aplicaciones que uso con más frecuencia y siempre trato de tenerlas instaladas, algunas son de proposito general y otras relacionadas con programación, experimentos, trabajo y proyectos personales.

* Gnome file roller para comprimir archivos `file-roller`
* Font Viewer para la instalación de fuentes `gnome-font-viewer`
* Google Chrome
* Terminal music player `mocp`
* Vim editor, para edición por línea de comandos y servidores `vim`
* Build essentials `build-essential`
* SublimeText3 editor de texto que uso para casi todo.
* Emacs editor de texto que uso para algunas cosas `emacs`
* Redshift para cambiar la temperatura del monitor `redshift`
* Kazam para grabar el escritorio `kazam`
* Kupfer similar a Spotlight para búsquedas rápidas `kupfer`
* Shutter para screenshots `shutter`
* Editor de gráficos vectoriales `inkscape`
* Gnome Hex Editor `ghex`
* Meld para comparar diferencias entre dos archivos `meld`
* Armagetron, juego basado en Tron `armagetronad`
* DOSBox emulador de juegos antiguos de DOS `dosbox`
* Drivers faltantes `firmware-linux-free` `firmware-linux-nonfree`
* Ristretto Image viewer
* Ettercap para investigación de ataques MITM, pensé en usar Bettercap pero no soy un fanático de Ruby
* Transmission cliente bit torrent `transmission`
* Wireshark para interceptar paquetes de red `wireshark`
* Slack messaging, personalmente uso la versión web gran parte del tiempo, pero cuando necesito compartir mi escritorio es cuando uso la versión de escritorio (descargar de su sitio)
* Pavu Controller para configuraciones de audio `pavucontrol`
* VLC Media Player `vlc`
* Evince como visor de pdf `evince`
* xCHM visor de archivos .chm `xchm`
* Utildad para manejar discos `gparted`
* Información del hardware `hardinfo`
* Docker Community Edition
* NodeJs

Esta es otra lista de aplicaciones que utilizo con más frecuencia específicamente en línea de comandos:

* Terminal multiplexer `tmux`
* htop visor de procesos basado en ncurses `htop`
* Tracer de llamadas al sistema `strace`
* Cliente HTTP `curl`
* Utilidades de DNS `dnsutils`
* Instalar `sudo`
* Compresores `zip`
* `sudo`

Obviamente hay otros paquetes para cosas bastante específicas los cuales los instalando cuando es necesario.

## Escritorio
Uso xfce4 con dos panels ambos en la parte superior. El primero contiene el menú de aplicación con el logo de Debian; un separador transparente que se extiende; las ventanas abiertas; otro separador transparente que se extiende. El segundo panel tiene estos items: las áreas de trabajo con dos files y dos áreas en cada fila; el visor de uso de CPU; el área de notificaciones; plugin de PulseAudio para cambiar el volumen; finalmente el plugin de fecha mostrando la fecha arriba y la hora abajo.

El primer panel tiene un fondo negro mientras que el otro usa el estilo por defecto del sistema para evitar colisión en colores de fuente.

![](/img/debian-desktop.png)
<center><a href="/img/debian-desktop.png" target="_blank">Ver</a></center>

### Apariencia
Para mis configuraciones de apariencia utilizo lo siguiente:

* Iconos `Numix Light` que vienen en el paquete `numix-icon-theme`
* Tema de ventanas `Adwaita`
* Fuente por defecto: Sans (10) con antialias en `Slight` y DPI en `101`

![](/img/thunar.png)
<center><a href="/img/thunar.png" target="_blank">Ver</a></center>

### Tweaks Extra
El "Switcher de Ventanas" (alt + tab) de xfce4 que viene en Debian Stretch no me agrada por el tamaño gigante de preview de ventana. Personalmente prefiero tener solo los íconos pequeños sin nombre de la ventana, para ello son solo un par de cambios a realizar: ir a `Settings > Window Manager Tweaks` y en el tab `Cycling` deseleccionar `Cycle through windows in a list` y finalmente en el tab `Compositor` deseleccionar `Show windows preview in place of icons when cycling`.

### Hotkeys
Tengo algunos hotkeys que uso en xfce4 para tareas comunes. Para configurar los hotkeys de xfce4 voy a `Settings > Keyboard > Application Shortcuts tab`. Mis hotkeys son los siguientes:

Hotkey | Comando | Descripción
--- | --- | ---
`win_key + f` | `thunar` | Abrir manejador de archivos Thunar
`win_key + t` | `/usr/bin/xfce4-terminal` | Abrir una nueva terminal
`win_key + n` | `mocp --next` | Ir a la siguiente canción en MOC player
`win_key + b` | `mocp --previous` | Ir a la anterior canción en MOC player
`win_key + o` | `mocp --pause` | Pausar la canción actual en MOC player
`win_key + p` | `mocp --unpause` | Reanudar reproducción en MOC player


**Otras hotkeys:** Este no es un hotkey de xfce4 pero lo uso con mucha frecuencia `ctrl + shift + space` para lanzar kupfer.


## Terminal
### Tema
Para la terminal uso la que viene por defecto `xfce4-terminal` con [estas configuraciones](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-terminalrc) en `~/.config/xfce4/terminal/terminalrc`.

### Prompt
Por defecto la terminal bash tiene un prompt simple como `usuario@host:directorio-actual`. En mi caso que uso bastantes repositorios git, este prompt por defecto no es suficiente ya que quiero ver en el prompt si hay cambios, conflictos, etc. Podria correr `git status` pero con un prompt personalizado podría ahorrarme ese paso :wink:. [Este es el script](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-custom_prompt.sh) que llamo desde mi archivo `.bashrc`, que basicamente muestra hora, directorio actual y la información del repositorio en caso de estar usando uno. Gracias a [Mike Stewart](https://twitter.com/mdrmike_) que es el autor original de este script.

Intente utilizar `zsh` y sus frameworks pero no me sentia comodo y me fue difícil acostumbrarme a este, así que la forma más simple fue tener un prompt personalizado. Afortunadamente habian muchos recursos disponibles para ello, así que no fue un dolor.

![](/img/terminal.png)
<center><a href="/img/terminal.png" target="_blank">Ver</a></center>

## Configuración
### Configuración de Tmux
Utilizo tmux desde Debian Wheezy pero cuando cambié a Debian Jessie tuve algunos problemas con el directorio al crear nuevos panels. Este es el [.tmux.conf](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-tmux-conf) que uso.

### Configuración de MOC Player
Como esta es una herramienta de línea de comandos pienso que entra en esta sección. Hay dos archivos que tengo `.moc/config` y el tema que uso, ambos pueden ser encontrados en mi [gist](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-moc_config_file).

![](/img/mocp.png)
<center><a href="/img/mocp.png" target="_blank">Ver</a></center>

## Comentarios Finales
Si bien estas configuraciones son bastante personalizadas para mi caso, hice esta entrada con el propósito de tener algo que leer por si olvido y lo compartí en caso le sea de utilidad a algún lector.
