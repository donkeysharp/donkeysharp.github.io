---
title: "My desktop setup in Debian"
date: 2018-03-09T23:15:16-04:00
draft: false
---

> **Update**
>
> *2018-04-28* Added more packages I use and new settings I do (reinstalled machine)

In this post I show the applications and settings I commonly use for my local development machine.

*Operating System:* GNU/Linux - Debian Stretch

*Dektop Manager:* xfce4

## Frequently Used Applications
<!-- Estas son las aplicaciones que uso con más frecuencia y siempre trato de tenerlas instaladas, algunas son de proposito general y otras relacionadas con programación, experimentos, trabajo y proyectos personales. -->

This is the list of application I frequently use and try to have them installed after I have a fresh computer. Some applications are general purpose and others are related with programming, things I investigate, my job and personal projects.

* Gnome file roller allows the user to compress files`file-roller`
* Font Viewer helps install fonts `gnome-font-viewer`
* Google Chrome
* Terminal music player `mocp`
* Vim editor, command line text editor`vim`
* Build essentials `build-essential`
* SublimeText3 text editor I use for almost everything.
* Emacs text editor I use for certain things `emacs`
* Redshift helps me change my monitor temperature `redshift`
* Kazam desktop recording `kazam`
* Kupfer similar to Spotlight that allows me to lauch application the easy way `kupfer`
* Shutter for screenshots `shutter`
* Vector graphics editor `inkscape`
* Gnome Hex Editor `ghex`
* Meld to compare differences between two files `meld`
* Armagetron, Tron based game `armagetronad`
* DOSBox emulator for old DOS games `dosbox`
* Missing drivers `firmware-linux-free` `firmware-linux-nonfree`
* Ristretto Image viewer
* Ettercap
* Transmission torrent client `transmission`
* Wireshark to see network traffic `wireshark`
* Slack messaging, I personally use the web version but when I need to share my screen I'm force to use the desktop verison.
* Pavu Controller for audio configuration `pavucontrol`
* VLC Media Player `vlc`
* Evince PDF viewer `evince`
* xCHM .chm files viewer `xchm`
* Utility to manage disks `gparted`
* Hardware information `hardinfo`
* Docker Community Edition
* NodeJs

This is another list of application I use frequently in the terminal.

* Terminal multiplexer `tmux`
* htop ncurses-based process viewer `htop`
* Track system calls of a process `strace`
* HTTP client `curl`
* DNS utils `dnsutils`
* Install always `sudo`
* Compress utils `zip`


Of course there are other packets for specific very specific things that I install when required.

## Desktop
I use XFCE4 with two panels both on the top section of the screen. The first one contains the applications menu with the Debian logo; a separator with transparency enabled that extends; list of opened windos; another transparent separator that extends. The second panel has these items: workspace areas four workspace area in two rows (2x2); a CPU usage viewr; notification are; plugin for PulseAudio; and the date-time plugin.

First panel has a dark background while the other uses the style that comes by default.

![](/img/debian-desktop.png)
<center><a href="/img/debian-desktop.png" target="_blank">View</a></center>

### Look and feel
For my look and feel settings I use the next:

* `Numix Light` icons that are installed with `numix-icon-theme`
* `Adwaita` window theme
* Default font: Sans (10) with antialiasing enabled `Slight` and DPI set to `101`.

![](/img/thunar.png)
<center><a href="/img/thunar.png" target="_blank">Ver</a></center>

### Extra Tweaks
I don't like the Windows Switcher (alt + tab) that comes with XFCE4 by default, it is too big with a preview of each window. I prefer to have small icons without the name of the window or things like that. With a couple of changes I can get that by going to: `Settings > Window Manager Tweaks` and select the `Cycling` tab and unselect `Cycle through windows in a list` and finally in the `Compositor` tab unselect `Show windows preview in place of icons when cylcing`.

### Hotkeys
<!-- Tengo algunos hotkeys que uso en xfce4 para tareas comunes. Para configurar los hotkeys de xfce4 voy a `Settings > Keyboard > Application Shortcuts tab`. Mis hotkeys son los siguientes: -->

I have some hotkeys configure in XFCE4 for common tasks I do. To configure hotkeys in XFCE4 go to `Settings > Keyboard > Application Shortcuts tab`. My common hotkeys are:

Hotkey | Comando | Descripción
--- | --- | ---
`win_key + f` | `thunar` | Open Thunar file manager
`win_key + t` | `/usr/bin/xfce4-terminal` | Open a new terminal
`win_key + n` | `mocp --next` | Next song in MOC player
`win_key + b` | `mocp --previous` | Previous song in MOC player
`win_key + o` | `mocp --pause` | Paus the actual song in MOC player
`win_key + p` | `mocp --unpause` | Continue playing song in MOC player


**Other hotkeys:** This is not an XFCE4 hotkey but I use it frequently `ctrl + shift + space` that launches Kupfer.


## Terminal
### Theme
I use `xfce4-terminal` with the next [settings](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-terminalrc) in ~/.config/xfce4/terminal/terminalrc`.

### Prompt

By default Bash comes with a prompt similar to `usuario@host:directorio-actual`. In my case I use a lot of Git repositories, this default prompt is not good enough for me as I need to check the current branch, if there are conflicts or unstaged changes, etc. Of course I can run `git status` but the prompt can help me with that :wink:. [This is the script](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-custom_prompt.sh) I export in `.bashrc`, that basically shows repository information, current directory and the time. Thanks to [Mike Stewart](https://twitter.com/mdrmike_) who is the original author of that script.

I tried to use `zsh` and its frameworks but I didn't feel comfortable and it was kind of hard getting used to it, so the simplest way for me was having a custom prompt light and simple. Fortunately there were so many resources available on the Internet so it wasn't a pain.

![](/img/terminal.png)
<center><a href="/img/terminal.png" target="_blank">View</a></center>

## Dot env settings
### Tmux settings

I started using Tmux sing Debian Wheezy but when I upgraded to Debian Jessie I had some problems with the current working directory when creating new panels. This is the [.tmux.conf](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-tmux-conf) I use.

### MOC Player Settings
Because MOC is a CLI tool I think it fits in this section. I use two files `.moc/config` and another one for the theme. Both can be found [here](https://gist.github.com/donkeysharp/b4fe1d9b366963314202c4b8c130ba6f#file-moc_config_file).

![](/img/mocp.png)
<center><a href="/img/mocp.png" target="_blank">View</a></center>

## Final Comments
Although this configurations are more for my personal usage, I wrote this post with the purpose to read if I forget something and shared in case it is useful for a reader.
