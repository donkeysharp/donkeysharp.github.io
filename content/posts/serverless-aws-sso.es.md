---
title: "Usando Serverless Framework con AWS SSO"
url: "post/serverless-aws-sso"
date: 2023-10-22T17:51:02-04:00
draft: false
---

En este post, mostraré una solución (que personalmente encuentro bastante limpia) a un problema que encontré con AWS SSO y Serverless Framework.


[Serverless Framework](https://www.serverless.com/framework/docs) es una de mis herramientas preferidas al trabajar con AWS Lambda y otros servicios serverless. Es una alternativa a [AWS SAM](https://aws.amazon.com/serverless/sam/), pero personalmente prefiero Serverless Framework debido a su compatibilidad con diversos cloud providers y plugins. Ya he usado Serverless Framework antes para acceder a las API de AWS configurando el archivo `~/.aws/credentials`. Sin embargo, esta vez me tocó utilizar [AWS Single Sign-On](https://aws.amazon.com/what-is/sso/) para acceder a las API de AWS desde mi computadora local. Lamentablemente, al intentar hacer deploy de funciones Lambda con la CLI de `sls` tuve algunos errores. Mostró un mensaje de error que indicaba que el AWS profile que estaba utilizando no estaba configurado, a pesar de haber iniciado sesión con éxito hace unos minutos.

```sh
$ export AWS_PROFILE='some-aws-sso-profile'
$ aws sso login
# Logs in successfully
$ sls deploy --stage dev
DOTENV: Loading environment variables from .env:
Deploying some-random-lambda to stage dev (us-east-1)

✖ Stack some-random-lambda failed to deploy (64s)
Environment: linux, node 18.16.0, framework 3.33.0 (local) 3.33.0v (global), plugin 6.2.3, SDK 4.3.2
Docs:        docs.serverless.com
Support:     forum.serverless.com
Bugs:        github.com/serverless/serverless/issues

Error:
AWS profile "some-aws-sso-profile" doesn't seem to be configured
```

Después de investigar un poco, descubrí que Serverless [no es compatible](https://github.com/serverless/serverless/issues/7567) con AWS SSO. Parece que `sls` espera que el archivo `~/.aws/credentials` esté configurado, pero AWS SSO no requiere almacenar credenciales localmente, ya que genera credenciales temporales cada vez que inicias sesión.

También aprendí que podía instalar un plugin de Serverless llamado [Better Credentials](https://www.npmjs.com/package/serverless-better-credentials). Sin embargo, personalmente prefiero evitar instalar y versionar un plugin que solo es útil para el desarrollo local.

## Cómo AWS SSO almacena las credenciales
Tras iniciar sesión con éxito, un access token se guarda en un archivo JSON en `~/.aws/sso/cache`. Afortunadamente, este token de acceso se puede utilizar para obtener la ACCESS KEY y SECRET ACCESS KEY reales, que luego se pueden agregar al archivo `~/.aws/credentials`, que la CLI `sls` espera que este configurado. El contenido de este archivo JSON se ve así:

```json
{
  "startUrl": "https://<some-id>.awsapps.com/start#/",
  "region": "us-east-1",
  "accessToken": "<access-token>",
  "expiresAt": "2023-10-20T05:58:17Z"
}
```

Además, mi archivo `~/.aws/config` incluye la siguiente configuración de SSO:

```
[profile some-aws-sso-profile]
sso_start_url = https://<some-id>.awsapps.com/start#/
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = MyRoleName
region = us-east-1
```

Para obtener ACCESS KEY y SECRET ACCESS KEY, se debe ejecutar el siguiente comando:

```sh
$ export SSO_TOKEN='token-del-archivo-json'
$ aws sso get-role-credentials --access-token $SSO_TOKEN --role-name MyRoleName --account-id 123456789012

{
    "roleCredentials": {
        "accessKeyId": "una-clave-de-acceso",
        "secretAccessKey": "una-clave-de-acceso-secreta",
        "sessionToken": "un-token-de-sesión",
        "expiration": 1698038986000
    }
}
```

Esta información se puede agregar al archivo `~/.aws/credentials` utilizando el mismo nombre de perfil de AWS, lo que permite que `sls` funcione.

## Presentando `aws-sso-creds-helper`
Aunque la solución mencionada anteriormente funciona, implica varios pasos manuales. Afortunadamente, existe una utilidad que automatiza este proceso. Se trata de una utilidad JavaScript conocida como [aws-sso-creds-helper](https://www.npmjs.com/package/aws-sso-creds-helper).

```sh
$ npm install -g aws-sso-creds-helper
```

## Poniéndolo todo junto
El paso final es integrar todos estos elementos. Para que la solución funcione en su totalidad, todo lo que debes hacer es ejecutar el comando `ssocreds` inmediatamente después de iniciar sesión con AWS SSO.

```sh
$ export AWS_PROFILE='some-aws-sso-profile'
$ aws sso login
# Inicio de sesión exitoso
$ ssocreds -p $AWS_PROFILE
# Agrega las credenciales temporales al archivo ~/.aws/credentials
$ sls deploy --stage dev
# deployment exitoso
```

## Pensamientos finales
A pesar de la introducción de una herramienta adicional para trabajar con AWS SSO, considero que esta solución es elegante, ya que elimina la necesidad de modificar o agregar dependencias adicionales al proyecto solo con el fin de utilizarlo en desarrollo local.
