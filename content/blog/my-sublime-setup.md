---
title: "Mi Entorno De Desarrollo En Sublime Text"
date: 2018-03-11T22:38:43-04:00
draft: true
---

## Introducción
Hola, en temas de desarrollo o edición de texto la mayor parte del tiempo &mdash;por no decir todo&mdash; utilizo Sublime Text 3 (desde ahora ST) como entorno de desarrollo. Los casos en los que no uso SublimeText son: edición en un servidor; edición por línea de comandos; no cuenta con [*artist-mode*](https://www.emacswiki.org/emacs/ArtistMode) como en Emacs.

Algo que adoro de ST es la gran capacidad de extensibilidad que este cuenta y la cantidad significate de plugins open-source disponibles. En este post deseo mostrar: como habilitar ST para poder instalar plugins con facilidad; las configuraciones que utilizo; un conjunto de hotkeys que fuí personalizando duranto algunos meses que hacen mi vida más simple dentro de ST.

ST por defecto tiene una interfaz de usuario elegante que soporta un gran número de lenguajes de programación para el *highlighting*; búsqueda rápida de archivos en un proyecto o directorio; un conjunto de comandos para manipular el texto y la configuración del editor como tal; es posible mejorar esta funcionalidad por defecto con los famosos *plugins*. Estos plugins son &mdash;en su mayoría&mdash; proyectos open-source que cumplen un propósito en específico como: trabajo avanzado con archivos; control de versiones; intellisense y otros.

## Instalando Plugins
Para poder instalar plugins existen dos formas: la manual que consta en clonar o copiar el directorio del plugin a un directorio predeterminado de ST o instalar *Package Control* de ST.

En esta entrada hablaré del Control de Paquetes, ya que además de automatizar el procedimiento manual este presenta una ventajas extras :wink:

Para instalar Package Control debemos ir al [sitio del proyecto](https://packagecontrol.io/installation#st3) y copiamos el código python del tab `Sublime Text 3` en la consola del editor (Menu View > Show Console). Luego de haber seguido este paso ya tendremos Package Control instalado lo cual nos permitirá buscar plugins, instalarlos, removerlos, habilitar/deshabilitar paquetes.

### Comandos Comúnes
Una vez instalado Package Control estarán disponibles una serie de comandos con los cuales se pueden realizar diferentes acciones relacionadas con plugins. Para poder ver estos paquetes presionamos las teclas `ctrl + shift + p` para visualizar la paleta de comandos. Los comandos que yo veo más comunes son:

Hotkey | Descripción
--- | ---
`Package Control: Install Package` | Nos permite visualizar todos los plugins disponibles para instalación y con solo presionar `enter` ST comienza a instalarlo.
`Package Control: Remove Package` | Elimina un plugin ya instalado
`Package Control: Add Repository` | Instala un plugin que no se encuentra en el índice oficial de *Package Control*
`Package Control: Disable Package` | Deshabilita un plugin ya instalado
`Package Control: Enable Package` | Habilita un plugin que ha sido deshabilitado


