---
title: "Mi Entorno De Desarrollo En Sublime Text (Parte 1)"
date: 2018-03-14T00:32:43-04:00
draft: false
---

> **Update**
>
> *2018-04-28* Otra forma de instalar paquetes

En temas de desarrollo o edición de texto la mayor parte del tiempo &mdash;por no decir todo&mdash; utilizo Sublime Text 3 como entorno de desarrollo. Es bueno recalcar que Sublime Text es un editor de texto, pero combinado con plugins se vuelve un entorno de desarrollo que para mí es suficiente.

Los casos en los que no uso Sublime Text son: edición en un servidor; edición por línea de comandos; no cuenta con [*artist-mode*](https://www.emacswiki.org/emacs/ArtistMode) como en Emacs.

Algo que adoro de Sublime Text (desde ahora ST) es la capacidad de extensibilidad que este cuenta y la cantidad significate de plugins open-source disponibles. En este post deseo mostrar: como habilitar ST para poder instalar plugins con facilidad; los plugins que utilizo; y algunas configuraciones del editor que hacen mi vida más simple.

ST por defecto tiene una interfaz de usuario elegante que soporta un gran número de lenguajes de programación para el *highlighting* de la sintaxis; búsqueda rápida de archivos en un proyecto o directorio; un conjunto de comandos para manipular el texto y la configuración del editor como tal; es posible mejorar esta funcionalidad por defecto con los famosos *plugins*. Estos plugins son &mdash;en su mayoría&mdash; proyectos open-source que cumplen un propósito en específico como: trabajo avanzado con archivos; control de versiones; intellisense y otros.

## Instalando Plugins
Para instalar plugins existen dos formas: la manual que consta en clonar o copiar el directorio del plugin a un directorio predeterminado de ST o instalar *Package Control*.

En esta entrada hablaré de *Package Control* que además de automatizar el procedimiento manual, presenta una ventajas extras :wink:

Para instalar Package Control debemos ir al [sitio del proyecto](https://packagecontrol.io/installation#st3) y copiamos el código python del tab `Sublime Text 3` en la consola del editor (`Menu View > Show Console`). Luego de haber seguido este paso ya tendremos Package Control instalado lo cual nos permitirá buscar plugins, instalarlos, removerlos, habilitar/deshabilitar paquetes.

### Comandos Comúnes
Una vez instalado Package Control estarán disponibles una serie de comandos con los cuales se pueden realizar diferentes acciones relacionadas con plugins. Para poder ver estas acciones presionamos las teclas `ctrl + shift + p` para visualizar la paleta de comandos. Los comandos que personalmente considero los más comunes son:

Hotkey | Descripción
--- | ---
`Package Control: Install Package` | Nos permite visualizar todos los plugins disponibles para instalación y con solo presionar `enter` ST comienza a instalar el plugin deseado.
`Package Control: Remove Package` | Elimina un plugin ya instalado
`Package Control: Add Repository` | Instala un plugin que no se encuentra en el índice oficial de *Package Control*
`Package Control: Disable Package` | Deshabilita un plugin ya instalado
`Package Control: Enable Package` | Habilita un plugin que ha sido deshabilitado

Ya sabiendo estos comandos instalar un plugin es algo tan simple como escribir `Package Control: Install Package` en la paleta de comandos, lo cual listará todos los plugins disponibles (en el índice de Package Control) y para finalizar presionamos `Enter` para poder comenzar con la instalación del plugin mencionado.

## Los Plugins Que Utilizo

* [**AdvancedNewFile**](https://github.com/skuroda/Sublime-AdvancedNewFile) -  Plugin que simplifica el trabajo de creación, modificación y eliminación de archivos en un proyecto o directorio. Algo que me gusta de este plugin es la capacidad de autocompletado de la ruta al momento de crear un archivo.
* [**Agila Theme**](https://github.com/arvi/Agila-Theme) - Tema visual basado en tonos oscuros
* [**Babel**](https://packagecontrol.io/packages/Babel) - Definiciones de sintaxis para ES6 y React JSX
* [**Color Picker**](https://packagecontrol.io/packages/ColorPicker) - Plugin (independiente al S.O.) que permite al usuario seleccionar un color elegido de una paleta de colores.
* [**Colorsublime**](https://packagecontrol.io/packages/Colorsublime) - Plugin que facilita la visualización de temas.
* [**Compare Side-By-Side**](https://packagecontrol.io/packages/Compare%20Side-By-Side) - Plugin que muestra la diferencia gráfica entre dos archivos (lo uso como alternativa rápida a meld, [Ver mi anterior post](/blog/mis-configuraciones-de-escritorio-en-debian/))
* [**DocBlockr**](https://packagecontrol.io/packages/DocBlockr) - Plugin que autocompleta los doc comments que soporta diferentes lenguajes de programación
* [**DocBlockr Python**](https://github.com/adambullmer/sublime_docblockr_python) - Basado en DocBlockr, este paquete da soporte específico a Python
* [**Dockerfile Syntax Highlighting**](https://packagecontrol.io/packages/Dockerfile%20Syntax%20Highlighting) - Plugin que permite el highlighting de Dockerfiles
* [**Git**](https://packagecontrol.io/packages/Git) - Plugin que realiza la integración con un repositorio git (commit, revert, blame, etc.). Personalmente para la parte de commits, merges, conflictos utilizo la línea de comandos pero para tareas que no causen mucho impacto como el blame este plugin me cae como anillo al dedo
* [**GitGutter**](https://packagecontrol.io/packages/GitGutter) - Plugin que muestra información de modificación (en la barra de número de línea) de un archivo en un repositorio git. Una de las características que me es de mucha utilidad es el deshacer cambios en un bloque específico de código
* [**Go Sublime**](https://packagecontrol.io/packages/GoSublime) - Plugin para el lenguje Golang que permite autocompletado y otras carácteristicas IDE-like
* [**HTML5**](https://packagecontrol.io/packages/HTML5) - Plugin que adiciona snippets y syntaxis para archivos HTML5
* [**Jinja2**](https://packagecontrol.io/packages/Jinja2) - Plugin para dar soporte a la sintaxis de templates jinja2
* [**JSX**](https://packagecontrol.io/packages/JSX) - Plugin que facilita el trabajo con código que usa JSX
* [**Laravel Blade Highlighter**](https://packagecontrol.io/packages/Laravel%20Blade%20Highlighter) - Plugin que da soporte a la sintaxis de templates Blade utilizados en Laravel
* [**Loremipsum**](https://packagecontrol.io/packages/LoremIpsum) - Plugin bastante sencillo que permite insetar cadenas del tipo `LoremIpsum` en el archivo que se esté editando
* [**Markdown Live Preview**](https://packagecontrol.io/packages/MarkdownLivePreview) - Poder editar archivos Markdown y poder ver el preview en otro panel dentro del mismo editor (es bastante chévere)
* [**NASM x86 Assembly**](https://packagecontrol.io/packages/NASM%20x86%20Assembly) - Plugin que da soporte al highlighting de código assembler
* [**nginx**](https://packagecontrol.io/packages/nginx) - Plugin que da soporte al highlighting de archivos de configuración de nginx
* [**Pretty JSON**](https://packagecontrol.io/packages/Pretty%20JSON) - Plugin para verificar y dar formato a texto con formato JSON. Personalmente es uno de los plugins que más utilizo ya que al consumir diferentes REST APIs este me ayuda con responses en un formato de una línea
* [**SCSS**](https://packagecontrol.io/packages/SCSS) - Plugin para dar soporte a archivos SCSS y SASS
* [**SideBarEnhancements**](https://packagecontrol.io/packages/SideBarEnhancements) - Plugin que le da esteroides al sidebar de ST adicionado nuevas opciones para manejo de archivos y directorios
* [**SublimeCodeIntel**](https://packagecontrol.io/packages/SublimeCodeIntel) - Plugin bastante importante que brinda un motor de autocompletado inteligente que soporta distintos lenguajes de programación. Un *must have* en la lista de plugins de todo usuario de ST
* [**SublimeLinter**](https://packagecontrol.io/packages/SublimeLinter) - Plugin que cuenta como framework base para otros linters e.g. pylint, phplint, jslint, etc.
* [**SublimeLinter-eslint**](https://packagecontrol.io/packages/SublimeLinter-eslint) - Plugin que da soporte a eslint en ST
* [**SublimeLinter-php**](https://packagecontrol.io/packages/SublimeLinter-php) - Plugin que da soporte a "linting" (no se como traducirlo a español) para php. Este utiliza el ejecutable `php`
* [**Tag**](https://github.com/titoBouzout/Tag) - Paquete con utilidades para tags XML, HTML, JSX, etc.
* [**TerminalView**](https://packagecontrol.io/packages/TerminalView) - Plugin que da soporte a una terminal unix dentro del mismo editor
* [**Theme - Brogrammer**](https://packagecontrol.io/packages/Theme%20-%20Brogrammer) - Plugin que da soporte al tema "Brogrammer" que lo combino con el tema Agila

El plugin "TerminalView" es algo que he deseado que existiera en ST desde que vaaaaarios años atrás vi que mi amigo [@jhtan](https://twitter.com/jhtan) logró tener embebida una terminal unix en Emacs. Ya con este plugin disponible soy feliz, pero el problema que tengo &mdash;que aún no logré solucionar&mdash; es la compatibilidad de TerminalView + tmux + custom keymap.

![](/img/sublime-terminal.gif)
<center><a href="/img/sublime-terminal.gif" target="_blank">Ver</a></center>

En el caso del plugin "Tag", este no se encuentra disponible en el repositorio de Package Control. 

Para instalar un paquete sin Package Control solo debemos saber el directorio en el cual se instalan paquetes y clonar el repositorio del paquete en este directorio. Para ello vamos al menú `Preferences > Browse Packages`. Ya sabiendo el directorio solo debemos clonar el repositorio de los paquetes que deseemos instalar.

## Las Configuraciones Que Utilizo
Sublime Text cuenta con un conjunto grande de configuraciones que nos permiten cambiar el comportamiento del editor como tal. Además de tener configuraciones que afectan a nivel general, es posible tener configuraciones específicas a nivel de sintaxis.

### Configuraciones Generales
Personalmente la mayoría de las configuraciones por defecto me es suficiente pero tengo un par de configuraciones que permiten tener el editor en el estado que yo deseo.

Para poder cambiar las configuraciones vamos a `Menu Preferences > Settings` lo cual abrirá una nueva ventana dividida en dos paneles: configuraciones por defecto y configuraciones personalizadas.

Tanto configuraciones por defecto o personalizadas son representadas en un documento JSON. Para modificar simplemente copiamos la configuración del panel izquierdo al derecho y establecemos el valor que se desee.

Las configuraciones personalizadas que utilizo son las siguientes:

{{< highlight json >}}
{
    "color_scheme": "Packages/Theme - Brogrammer/brogrammer.tmTheme",
    "ensure_newline_at_eof_on_save": true,
    "font_face": "Noto Mono Regular",
    "font_options":
    [
        "no_bold",
        "subpixel_antialias"
    ],
    "font_size": 11,
    "rulers":
    [
        80
    ],
    "tab_size": 4,
    "theme": "Agila.sublime-theme",
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true
}
{{< /highlight >}}

Básicamente estas configuraciones extras me permiten lo siguiente (en orden):

* Utilizar el esquema de color llamado `brogrammer`
* Siempre crear una nueva linea al final del archivo despues de guardar
* Fuente que reemplaza Droid Sans Mono en Debian Stretch
* Configuraciones de la fuente
* Tamaño de la fuente
* Poner una línea vertical en el editor para saber la cantidad de caracteres que se escribieron &mdash; que en mi caso son 80 caracteres
* Establecer la longitud de una tabulación a 4 espacios
* El tema del editor es `Agila`
* Traducir una tabulación a espacios
* Eliminar los espacios al final de una línea

### Configuraciones Específicas
Como mencioné anteriormente es posible tener configuraciones específicas por sintaxis. Tal vez para algunos se preguntan ¿por qué tener configuraciones específicas por sintaxis?, pues un ejemplo responde esta pregunta: Tal vez en general se desea que la longitud de una tabulación sea de 4 caracteres pero en el caso de archivos javascript esta sea de 2 caracteres.

Para poder establecer configuraciones específicas a una sintaxis es necesario tener un archivo abierto con la sintaxis que se desea personalizar, luego ir a `Menu Preferences > Settings - Syntax Specific`, que abrirá una nueva ventana con dos paneles de la misma forma que las configuraciones generales.

La mayoría de las veces uso esta opción para solamente cambiar la longitud de una tabulación:

{{< highlight json >}}
{
    "tab_size": 2
}

{{< /highlight >}}

Pero un caso donde uso algo diferente a esto es para archivos de tipo Markdown:

{{<highlight json>}}
{
    "word_wrap": true,
    "wrap_width": 80,
}
{{</highlight>}}

El cual me indica que cada linea será cortada cuando se llegue a un límite `wrap_width` que en mi caso es de 80 caracteres.

En esta imagen muestro como luce Sublime Text después de aplicar estas configuraciones que se adecuan a mi gusto y caso de uso además de uno que otro plugin visible:

![](/img/st-custom.png)
<center><a href="/img/st-custom.png" target="_blank">Ver</a></center>

## Comentarios Finales
Respecto a los plugins muchos de los ya mencionados dejaron de subir nuevas versiones ya desde hace un tiempo. Dependiendo de la importancia de algún plugin esto no suele ser un problema grande en mi experiencia que ya son más de 4 años que voy usando Sublime Text desde su versión 2 y ahora la 3.

En esta primera parte relacionada a configuraciones de Sublime Text hice énfasis en los plugins que tengo instalados y configuraciones personales (generales o específicas). En la segunda parte mostraré algunos comandos que utilizo la mayor parte del tiempo y el keymap que hice que es una mezcla del keymap de Emacs más algunas opciones que son mi "contribución" que tal vez para algunos les parezcan incomodas. :)

Espero les haya sido de utilidad.
