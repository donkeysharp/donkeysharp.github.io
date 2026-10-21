---
title: "AWS User Group La Paz - DevOps Bootcamp"
url: "aws-user-group-la-paz-bootcamp-devops"
date: 2026-10-28T20:47:12-04:00
tags: ["aws", "bootcamp", "devops", "ecs", "containers", "observability", "pipelines"]
draft: false
---

![](/img/devops-bootcamp/00.png)

> Traducido del artículo original en Inglés

Durante junio y julio de este 2026, el [AWS User Group La Paz](https://www.meetup.com/aws-user-group-la-paz) organizó el primer DevOps Bootcamp en Bolivia, abierto y gratuito para la comunidad! La idea de este bootcamp era llegar a profesionales y estudiantes interesados en aprender más sobre la cultura DevSecOps y sus principios, y ponerlos en práctica, 100% hands-on usando AWS y otras tecnologías utilizadas en la industria.

En este post les daré algunos detalles de cómo lo organizamos:

## Planificación
La idea empezó hace un par de años cuando me reuní con [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/) (un buen amigo de hace años) y entre comida y chelsa (cervezas) comentamos que estaría cool organizar algo como un bootcamp DevOps.

Yamil Urbina, en mi opinión, ayudó a sentar las bases de la comunidad DevOps y Cloud acá en La Paz - Bolivia allá por el 2016, organizando eventos sobre Docker, Kubernetes, HashiCorp y cloud en general, de los cuales también tuve la suerte de ser parte. Después inició la comunidad "La Paz Cloud", que con el tiempo se convirtió en el AWS User Group La Paz.

Este año él tuvo la oportunidad de pasar algunos meses en Bolivia, así que decidimos arrancar con esto!

Como era la primera vez que hacíamos algo así, no sabíamos qué esperar, así que con el propósito de enseñar pero también aprender de estas sesiones, como ser qué método funciona mejor, o si el contenido es muy básico o muy avanzado, decidimos crear un formulario de postulación donde las personas interesadas aplicaron para ser parte de este primer DevOps Bootcamp. El formulario básicamente tenía dos campos clave: su experiencia y sus motivaciones.

Elegimos a 17 personas entre estudiantes y profesionales. 2 empezaron pero no terminaron el bootcamp, pero otras 2 se unieron a partir de la sesión 2.

Hubo una mezcla de especialidades, lo que nos permitió mostrar la cultura DevSecOps aplicada a las diferentes áreas en las que trabajan los participantes. Tuvimos backend engineers, QA engineers, data engineers y sysadmins principalmente con experiencia on-premise.

### Los instructores
![](/img/devops-bootcamp/10.png)

- [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/), Platform Engineer en Cisco, proyecto ThousandEyes.
- [Alex Flores](https://www.linkedin.com/in/alex-flores-1599a4136/), DevOps Engineer en AssureSoft, AWS Golden Jacket y Community Builder
- [Sergio Guillen](https://www.linkedin.com/in/sergio-guillen-a6392b155), DevOps Engineer en Cloudreams, [Líder AWS User Group La Paz](https://linktr.ee/aws.user.group.lpz).

## El contenido y la dinámica
Planificamos tener 6 sesiones presenciales y 6 sesiones virtuales.

El objetivo de las sesiones presenciales era enseñar un nuevo tema del programa, y practicar, practicar y practicar. A medida que enseñábamos un nuevo concepto, dábamos los pasos para que los participantes puedan tener práctica hands-on desde el primer día. Nos reuníamos todos los sábados de 9:00AM a 12:00PM. También les dejábamos algunas tareas que tenían que hacer en casa.

Por otro lado, las sesiones virtuales, que teníamos los jueves por la noche, eran para repasar lo que hicimos en la sesión presencial, responder las preguntas de los participantes y ayudarlos a resolver las tareas que les dejamos.

Requisitos antes de empezar: como íbamos a ver diferentes tecnologías y para ahorrar algo de tiempo, los participantes debían tener listo lo siguiente:
- Una cuenta de [AWS](https://aws.amazon.com/)
- Una cuenta de [InfraCost](https://www.infracost.io/)
- Una cuenta de [Grafana Cloud](https://grafana.com/products/cloud/)
- Una cuenta de [PagerDuty](https://www.pagerduty.com/)

Los temas por semana fueron los siguientes:
- **Semana 1**: Intro al bootcamp, a AWS y creación de una infraestructura de AWS más robusta
  - Mostrar la [aplicación muyu-invoice](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator), su arquitectura actual (aplicación y base de datos, todo en el mismo servidor) y algunos de los desafíos de esta arquitectura.
  - Empezar diseñando una infraestructura base más sólida que nos permita en las siguientes sesiones trabajar mejor con los diferentes servicios de AWS que planeábamos usar.
  - Repasar conceptos de redes como ser notación CIDR, modelo OSI, etc.
  - Ver VPC, Subnets, Routing tables y security groups de AWS, todo con **pasos manuales**. Todos los participantes pudieron seguir los pasos, aprender algo de troubleshooting cuando las cosas no funcionaban y tener las bases de la infraestructura que íbamos a usar en las siguientes sesiones.
- **Semana 2**: Infraestructura como Código
  - Mostrar los desafíos de usar pasos manuales y por qué no es una buena idea.
  - Presentar a los participantes el concepto de infraestructura como código, la herramienta Terraform y sus beneficios.
  - Recrear la infraestructura hecha en la sesión anterior pero en Terraform.
  - Todos los participantes lograron tener una forma reproducible de crear infraestructura gracias a Terraform.
- **Semana 3**: Llevando la aplicación a Docker
  - Introducción a Docker y cómo nos ayuda a tener builds reproducibles de nuestra aplicación y su distribución.
  - Correr la aplicación localmente usando docker-compose.
  - Ver los problemas con imágenes grandes.
  - Ver los beneficios de las imágenes basadas en alpine y sus posibles problemas (cuando hay fuertes dependencias de funcionalidades de glibc que no están presentes en musl).
  - Introducción a multi-stage builds y la importancia del orden de los layers.
  - Presentar Trivy para empezar a considerar la seguridad y el proceso de escaneo como parte del ciclo de vida de desarrollo de software.
  - Todos los participantes lograron hacer build de la imagen Docker de la aplicación muyu-invoice y subirla a su repositorio de ECR correspondiente, que fue creado con Terraform (aplicando lo que aprendimos antes).
- **Semana 4**: Introducción a ECS
  - Ver los conceptos de orquestación de contenedores.
  - Ver los componentes de un cluster ECS: Service, TaskDefinition, Load Balancer, Target Groups, etc.
  - Crear los componentes de ECS necesarios para hacer deploy de la aplicación [muyu-invoice](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator) usando Terraform.
  - Crear el cluster de base de datos RDS usando Terraform.
  - Probar y hacer deploy de la aplicación en la nube y acceder a ella desde Internet.
- **Semana 5**: Arquitecturas asíncronas
  - Refactorizar la aplicación para que la generación de facturas sea más cloud native, como ser guardar los PDFs de las facturas en un bucket de S3.
  - Hacer que la generación de facturas sea una tarea en background usando colas de SQS, usar SES para enviar emails, etc.
  - Revisar la seguridad del código Terraform usando Checkov.
  - Obtener un estimado del costo de nuestra infraestructura usando InfraCost.
- **Semana 6**: Observabilidad y monitoreo
  - Presentar los conceptos de envío de logs a Grafana Loki.
  - OpenTelemetry y métricas personalizadas.
  - Alertas y envío de alertas a PagerDuty.
  - Generar algo de caos, tumbando el background job generador de facturas y recibiendo alertas.

Como habrán notado, no incluimos una sesión sobre pipelines como hacen la mayoría de los cursos de DevOps. La forma en que orientamos este bootcamp fue identificar un problema y luego qué herramientas o técnicas nos pueden ayudar a resolverlo. Decidimos no tener una sesión de pipelines de CI/CD porque pensamos que el pipeline iba a ser un resumen de todo lo que aprendimos en las seis sesiones, por lo que el pipeline de CI/CD (aunque sí mostramos algo de uso de GitHub Actions) estaba pensado como el proyecto final que le recomendamos hacer a cada participante.

### Gracias a AWS y Digital Harbor!
![DigitalHarbor Oficinas!](/img/devops-bootcamp/20.png)
No hubiéramos podido hacer esto sin la ayuda de Digital Harbor, que muy amablemente nos prestó sus oficinas acá en La Paz para este bootcamp, lo que hizo que las sesiones presenciales sean mucho más atractivas y que a los participantes les sea más fácil llegar, gracias a su ubicación estratégica. Créanme, sus oficinas son increíbles!

AWS Latam Community también nos ayudó con la comida y los refrescos durante las sesiones de los sábados, no podíamos hacer un bootcamp sin unas deliciosas salteñas!

![Las Salteñas](/img/devops-bootcamp/30.png)

## Feedback
Apreciamos un montón el feedback porque nos ayuda a mejorar futuras iniciativas como esta! Queremos agradecer a todos los participantes, porque así como ustedes pudieron aprender algo de los instructores, nosotros aprendimos un montón de ustedes.

Estos son los [resultados del formulario de feedback](https://drive.google.com/file/d/1QijQ5cQMw4j1e3CkV66LHscR1LNN-H_h/view?usp=sharing) que enviamos.

También preparamos un video con algunas opiniones de los participantes sobre el DevOps Bootcamp.

{{< instagram Dbqwrprpamk >}}

## Lecciones aprendidas y lo que viene en el futuro
Así como los participantes pudieron aprender más sobre DevOps y DevSecOps, nosotros (como instructores) aprendimos un montón del feedback y de todas las sesiones presenciales y virtuales: desde cómo presentar temas específicos hasta qué analogías funcionan mejor, etc. También encontramos algunos vacíos en conocimientos que asumíamos que los participantes ya tenían, como ser familiaridad con sistemas Unix (más comúnmente GNU/Linux), redes, etc. Y bueno, eso es genial! Porque ahora sabemos qué tipo de material preparar para futuras versiones del DevOps Bootcamp!

Así que esperen un nuevo set de sesiones con contenido más específico, como ser Linux + AWS, y más sobre servicios específicos de AWS y DevOps. Pueden enterarse de más eventos de la comunidad en [nuestras redes sociales](https://linktr.ee/aws.user.group.lpz).

Happy Hacking! 👾
