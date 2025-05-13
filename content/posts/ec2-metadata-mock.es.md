---
title: "Simulando servidor de metadata de EC2 localmente"
url: "mock-ec2-metadata"
date: 2023-05-28T21:08:04-04:00
draft: false
---

Hace algún tiempo estaba trabajando en la creación de un entorno de desarrollo local basado en docker para algunos microservicios, para que los desarrolladores puedan tener los componentes de infraestructura necesarios en sus máquinas y eso les ayudará con sus tareas diarias. Inicialmente, la lógica de negocio de algunos microservicios era una caja negra para mí. Después de colocar las aplicaciones en contenedores y crear la configuración de docker-compose, algunas de ellas comenzaron a fallar y, después de verificar los logs, resultó que las aplicaciones usaban el AWS SDK para obtener la metadata de la instancia ec2.

Para aquellos que no están familiarizados con la [metadata de EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html), se trata de un conjunto de endpoints HTTP que están disponibles en la dirección IP `169.254.169.254`. Esto se usa para recuperar metadata como la IP de la instancia, la región de AWS, la zona de disponibilidad, las credenciales de IAM, etc. E internamente, el SDK de AWS usa estos enpodints para el mismo propósito.

Por defecto, cualquier usuario de sus máquinas locales no podrá llegar a `169.254.169.254` porque es parte del [espacio de direcciones local-link](https://www.rfc-editor.org/rfc/rfc3927). Así que tenemos dos problemas:
- Rutear todo el tráfico a esa dirección IP especial a algún lugar conocido.
- Simular todos los endpoints HTTP para la metadata.

## Hacer que `169.254.169.254` esté disponible localmente
Afortunadamente, es posible hacer que el tráfico a `169.254.169.254` funcione localmente o en un entorno local basado en Docker. Linux y MacOS proporcionan herramientas que simplifican este tipo de tareas.

Según el sistema operativo que esté utilizando, existen diferentes formas de enrutar el tráfico `169.254.169.254` a la interfaz local.

En MacOS puedes hacerlo ejecutando el comando:
```
$ sudo ifconfig lo0 alias 169.254.169.254
```

En Linux, hay diferentes opciones:

Usando `ifconfig`:
```sh
$ sudo ifconfig lo:0 169.254.169.254 máscara de red 255.255.255.255
```

Usando `iptabes`:
```sh
$ sudo iptables -t nat -A SALIDA -d 169.254.169.254 -j DNAT --a-destino 127.0.0.1
```

De esta manera, cualquier conexión de red que vaya a `169.254.169.254` irá a nuestra máquina local.

## Simular los endpoints HTTP para la metadata
Debido a que muchos ingenieros pueden tener el mismo problema de acceder al servidor de metadata en un entorno local, AWS ha creado una utilidad que sirve todos los endpoints HTTP para la metadata. El proyecto [amazon-ec2-metadata-mock](https://github.com/aws/amazon-ec2-metadata-mock) nos ayuda con eso.

Solo hay que descargar el binario para su sistema operativo desde su [página de releases](https://github.com/aws/amazon-ec2-metadata-mock/releases) y podrá comenzar a usarlo.

Algunas opciones que tiene son:
![](/img/ec2-metadata-mock.png)

Para que el AWS SDK funcione al intentar hacer request de metadata, un request a `http://169.254.169.254/latest/meta-data` debe funcionar. Afortunadamente, solucionamos el problema de apuntar `169.254.169.254` a localhost en la sección anterior. `ec2-metadata-mock` se expone de forma predeterminada en el puerto `1338`, por lo que para engañar al AWS SDK necesitamos exponer los endpoints falsos en el puerto `80`.

Para eso, solo necesitamos ejecutarlo como:

```sh
$ sudo ec2-metadata-mock -p 80
```

## Juntándolo todo
Ahora que sabemos cómo enrutar el tráfico a `169.254.169.254` donde queramos y tenemos un servidor de metadata EC2 falso, podemos unir todo y tener un entorno de desarrollo completamente basado en Docker.

Para esto, habrá con container para la herramienta `ec2-metadata-mock` y otro que se llamará `debug` que podría representar cualquier aplicación que necesite acceso al servidor de metadata.

El código fuente de este experimento se puede encontrar en este [repositorio](https://github.com/donkeysharp/ec2-metadata-mock-environment).

Entonces, el archivo de Docker compose se verá así:

```yaml
version: '3'
services:

  mock_metadata:
    image: ec2-metadata-mock
    build:
      context: .
      dockerfile: Dockerfile.metadata-mock

  debug:
    image: ec2-metadata-debug
    build:
      context: .
      dockerfile: Dockerfile.debug
    environment:
      MOCK_HOSTNAME: mock_metadata
    command:
      - sleep
      - '3600'
    cap_add:
      - NET_ADMIN
```

Y contiene un contenedor que ejecutará el servidor `ec2-metadata-mock` en el puerto `80` y un contenedor de debugging que simula una aplicación. Recordemos que el objetivo es realizar cualquier request HTTP desde el contenedor de la aplicación (en este caso, el contenedor `debug`) a `http://169.254.169.254/` y que la conexión vaya al contenedor del servidor de metadata.

Para que las aplicaciones enruten el tráfico al servidor de metadata, agregué un script entrypoint que se ejecuta antes de que se inicie la aplicación. Recupera la dirección IP interna utilizada en la red docker para el contenedor del servidor de metadata, luego crea una regla iptable que enruta cualquier tráfico a `169.254.169.254` a la dirección IP del servidor de metadata. Es importante tener en cuenta que debemos agregar el [Linux capability](https://man7.org/linux/man-pages/man7/capabilities.7.html) `NET_ADMIN` para usar iptables dentro de un contenedor.

```sh
#!/bin/bash

if [[ -z $MOCK_HOSTNAME ]]; then
    echo "MOCK_HOSTNAME must be set"
    exit 1
fi

mock_ip_address=$(dig +short $MOCK_HOSTNAME)

echo 'INFO - Make traffic to 169.254.169.254 go through local mock server'
iptables -t nat -A OUTPUT -d 169.254.169.254 -j DNAT --to-destination ${mock_ip_address}

exec $@
```

Entonces, una vez que ejecutamos la solución completa, podemos probar que, de hecho, podemos hacer curl `169.254.169.254` desde el contenedor `debug`.

```sh
$ docker exec -it local-ec2-metadata_debug_1 curl http://169.254.169.254/latest/meta-data/instance-id

i-1234567890abcdef0
```

## Recomendaciones
Aunque esta solución usa iptables y funciona, investigaré y actualizaré este post si es posible definir una red personalizada en docker-compose usando el rango link-local y asignar una dirección IP específica al contenedor ec2-metadata.
