---
title: "Utilizando AWS Nuke para limpiar tus cuentas de AWS"
url: "intro-to-aws-nuke"
date: 2025-07-13T18:20:13-04:00
tags: ["AWS"]
draft: false
---
![alt text](/img/aws-nuke.png)

## ¡Presentando AWS Nuke!
En este post daré una introducción rápida a [AWS Nuke](https://aws-nuke.ekristen.dev/), una herramienta desarrollada en Golang que tiene como objetivo eliminar todos los recursos en una cuenta de AWS. Esta herramienta me ayudó muchísimo.

## Casos de Uso
### Limpiar una Cuenta AWS Free Tier
Este fue más un caso de uso personal. Creé una cuenta de AWS Free Tier hace algunos meses y la he estado utilizando para diferentes propósitos. Algunos de los recursos que creé fueron mediante Terraform, lo que hizo más sencillo eliminarlos luego de usarlos. Por otro lado, creé otros recursos manualmente, y algunos de ellos me estaban generando costos! Así que preferí eliminar todo en esta cuenta ya que la uso solo con fines de aprendizaje. AWS Nuke es una excelente herramienta para esta tarea.

> **Nota sobre las nuevas cuentas free plan:** [AWS anunció sus nuevos planes del free tie](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html)r. En lugar de ofrecerte el uso gratuito de algunos servicios durante el período de free-tier, te dan cuentas con 100 USD de créditos durante seis meses, lo cual personalmente creo que es mejor para las personas que son nuevas en AWS, ya que el nivel gratuito anterior no incluía algunos recursos y utilizarlos costaba dinero, por ejemplo, los NAT Gateway. Así que, si no quieres matar rápidamente tus 100 USD, ¡AWS Nuke puede ayudarte!

### Limpiar Cuentas de Investigación
Es muy común que algunas empresas tengan cuentas utilizadas para investigación, donde los ingenieros pueden probar nuevos servicios, conceptos, etc. Dependiendo de cómo fueron creados los recursos, puede ser simple o no hacer seguimiento y eliminarlos. Lo bueno es que estas cuentas de investigación no deberían tener infraestructura de producción en ejecución, por lo tanto, eliminar los recursos para ahorrar dinero es un caso perfecto para usar AWS Nuke.

> **Advertencia:** Los dos casos de uso para AWS Nuke que mencioné consideran únicamente cuentas temporales o efímeras. Es importante destacar que usar herramientas de Infraestructura como Código o al menos tener una buena convención de etiquetado (para poder identificar fácilmente qué recursos existen) puede evitar la necesidad de usar esta herramienta, que en mi opinión es similar a usar `kill -9` en sistemas Unix, es decir, úsala como último recurso.

## Usando AWS Nuke
### Requisitos
Antes de continuar, asegúrate de que tu cuenta de AWS tenga un alias asociado, esto es **OBLIGATORIO**. Para configurarlo, inicia sesión en tu cuenta, ve al servicio IAM y en la sección derecha verás una sección llamada "Cuenta" donde puedes editar el alias.

![](/img/iam-account-alias.png)

Dado que esta herramienta puede ser muy destructiva, es importante que sepas lo que estás haciendo y, sobre todo, qué recursos estás a punto de eliminar. De todas modos, la herramienta se ejecuta en modo de prueba (dry-run) por defecto, es decir, no aplicará ningún cambio hasta que añadas un flag específico y hagas confirmaciones adicionales. Por suerte, puedes ser tan específico como desees sobre qué quieres eliminar: desde recursos concretos de un tipo específico hasta todos los recursos de uno o varios tipos.

Algo que me encantó de cómo está programada es que fallará si el alias de tu cuenta AWS contiene la palabra `prod`, lo cual me parece una validación muy importante para evitar ejecuciones por error.

Para descargarla e instalarla, sigue su [página de documentación](https://aws-nuke.ekristen.dev/installation/). Una vez instalada, puedes continuar con los siguientes pasos.

Además de la herramienta, se espera que ya tengas acceso a AWS mediante la CLI.

### Configurando tu archivo YAML
AWS Nuke necesita un archivo de configuración donde puedes especificar qué cuentas se verán afectadas, qué recursos se incluirán o excluirán, etc. Este archivo está en formato YAML.

En mi caso, lo que quería hacer era eliminar todos los recursos de mi cuenta AWS, excepto la VPC predeterminada, el usuario IAM que uso para administración, sus claves de acceso y la configuración MFA.

Este es el archivo de configuración que usé.

```yml
# aws-nuke-config.yml
regions:
- us-east-1 # only delete in us-east-1
- global

resource-types:
  excludes:
    # Some optimizations, for instance do not delete each S3 Object
    # or DynamoDBTable record, internally aws nuke will empty the bucket anyway
    - OSPackage
    - S3Object
    - DynamoDBTableItem
    # Keep for default VPC
    - EC2DefaultSecurityGroupRule
    # Do not remove IAM User and its dependencies
    - IAMUser
    - IAMLoginProfile
    - IAMUserAccessKey
    - IAMVirtualMFADevice
    - IAMUserPolicyAttachment

blocklist:
- "999999999999" # aws nuke always requires to have an account blocklist

accounts:
  "123456789777": # my account
    filters:
      # Exclude all resources that have the DefaultVPC or the IsDefault properties
      EC2DHCPOption:
      - property: DefaultVPC
        value: "true"
      EC2InternetGateway:
      - property: DefaultVPC
        value: "true"
      EC2InternetGatewayAttachment:
      - property: DefaultVPC
        value: "true"
      EC2RouteTable:
      - property: DefaultVPC
        value: "true"
      EC2Subnet:
      - property: DefaultVPC
        value: "true"
      EC2VPC:
      - property: IsDefault
        value: "true"
      # END: Filter all default VPC resources
```

## ¡Ejecutando AWS Nuke!
Ejecutarlo es muy sencillo, una vez que AWS Nuke está instalado solo necesitas correr el siguiente comando para tener un plan en modo de prueba de lo que está por eliminarse:

```
$ aws-nuke nuke --config ./aws-nuke-config.yml
```

Esto generará un plan, y como se ve en el screenshot, los registros que serán eliminados contienen el texto `would be removed`.

![aws nuke plan](/img/aws-nuke-plan.png)

### Anímate a probar
Intenta eliminar o modificar tu archivo de configuración YAML y observa qué cambia en el plan.

### El Último Paso, ¡Núkelos a Todos!
Una vez que estés conforme con el plan de eliminación, puedes ejecutar:

```sh
$ aws-nuke nuke --config ./aws-nuke-config.yml --no-dry-run-mode
```

Lo cual te pedirá el alias y confirmará que realmente deseas eliminar los recursos de esa cuenta.

## Comentarios Finales
Espero que este post te sea útil. AWS Nuke me ayudó mucho con cuesntas personales que uso para aprendizaje, así puedo ahorrar algunos dólares. Pero nunca olvides que esta es una herramienta destructiva, debes tener **MUCHO** cuidado al usarla.
