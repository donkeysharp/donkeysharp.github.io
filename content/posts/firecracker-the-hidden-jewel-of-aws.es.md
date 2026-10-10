---
title: "Redescubriendo AWS Firecracker, la joya open-source escondida de AWS"
url: "redescubriendo-firecracker-la-joya-escondida-de-aws"
date: 2026-10-10T10:00:03-04:00
tags: ["aws", "firecracker", "containers", "kubernetes"]
draft: false
---

> Traducido del artículo original en Inglés

> Este post probablemente es uno de los más largos que tengo en mi blog, pero créanme, está 100% escrito por mí, nada de AI slop, libre de gluten XD (la versión original está en Inglés)

Hola a tod@s! En este post les voy a hablar sobre Firecracker y las MicroVMs y su importancia en esta nueva era de la IA que estamos viviendo. Es más como un resumen de las charlas que presenté en el AWS Community Day Colombia 2026 y el AWS Community Day Bolivia 2026. Recibí algunos mensajes de amigos interesados en el tema, así que feliz de compartirlo acá!

Preparé una charla y la postulé al AWS Community Day [Colombia](https://awscommunitydaycolombia.com/home) y [Bolivia](https://day.awscommunity.org.bo/es/speakers), donde tuve el gusto de compartir este tema! Tengo que admitirlo, se siente genial ver tu nombre en la agenda junto a otras personas que admiro.

![](/img/firecracker/02-cd-1.png)

## Por qué propuse esta charla?
Descubrí Firecracker por primera vez por el 2021 (más sobre eso abajo). Un par de años después, cuando tuve un caso de uso para esto, me di cuenta que no podía usarlo en un entorno real de AWS ya que requería instancias EC2 metal (las que tienen KVM habilitado). Lastimosamente, antes de febrero de 2026, solo podías tener virtualización anidada (nested virtualization) en instancias `metal`, que tenían muchísimas más specs de las que necesitaba para hacer PoCs, y claro, eran más caras.

![](/img/firecracker/00-prices-metal.png)

En febrero de este año (2026), [AWS anunció Nested Virtualization](https://aws.amazon.com/about-aws/whats-new/2026/02/amazon-ec2-nested-virtualization-on-virtual/) en sus familias de instancias `c8`, `m8` y `r8`, y esta vez ya no se requerían instancias `metal`, podías empezar a usar virtualización anidada en instancias `c8i.large`, que son mucho más accesibles que una instancia `metal`.

![](/img/firecracker/01-prices-c8.png)

Cuando leí ese anuncio, Firecracker fue lo primero que se me vino a la mente! Así que empecé a jugar con él nuevamente, pero esta vez enfocado en lo importante que es el sandboxing desde el punto de vista de seguridad en esta era de la IA que estamos viviendo. Con todos los incidentes de seguridad que vienen pasando desde el año pasado, considero que el sandboxing juega un rol importante en cómo hacemos deploy de las cosas hoy en día, podríamos estar haciendo deploy de código malicioso, no porque nos hayan comprometido a nosotros, sino porque comprometieron una librería que estamos usando.

Durante los últimos meses tuvimos:
- Supply chain attacks (algunos exitosos, otros que pudieron haberlo sido) e.g. Axios, TanStack, xz
- Exploits de kernel, solo en 2026 tuvimos CopyFail, DirtyFrag
- El ataque de OpenAI a Hugging Face
- Y en general, threat actors + IA es algo cada día más común

Enfoqué la mayor parte de mi presentación en seguridad y contenedores, y en cómo Firecracker y las MicroVMs pueden ayudar. Sabemos que los contenedores son poderosos, podemos hacer deploy de múltiples contenedores aislados con nuestros servicios en un solo host (ECS + EC2, Kubernetes, Docker Compose). Tenemos la ventaja de usar solo los recursos que nuestro servicio requiere y aislamiento mediante namespaces, sin embargo, una de las posibles desventajas en términos de seguridad es que los contenedores comparten el mismo kernel con el host. Si uno de nuestros servicios resulta tener una vulnerabilidad de RCE, y existe un nuevo exploit de kernel que nos permite escapar del contenedor, la máquina host más los otros servicios que corren en ese mismo host, técnicamente también están comprometidos.

![](/img/firecracker/04-container-escaping.png)

Claro que existen diferentes prácticas que pueden reducir o prevenir estos riesgos durante la fase de desarrollo, como ser: análisis estático de código, parchar constantemente nuestros servidores, etc. Pero cuando algo es nuevo y recién fue revelado, hay una ventana de tiempo donde el riesgo es mayor.

Del otro lado de los contenedores, tenemos las Máquinas Virtuales, que tienen una estructura de seguridad "más robusta" en términos de aislamiento (vean la sección "actualización octubre 2026" al final sobre una vulnerabilidad reciente descubierta en KVM). La desventaja de las máquinas virtuales como las conocemos (KVM, Hyper-V, VMware, etc) es que consumen más recursos y su tiempo de arranque es más largo comparado con los contenedores.

Así que por un lado tenemos los contenedores, eficientes en recursos y con un arranque rápido, con la condición de que comparten un kernel que podría ser un riesgo. Por el otro lado, tenemos las máquinas virtuales, que tienen un aislamiento de seguridad más robusto aprovechando la virtualización por hardware, pero con la condición de que suelen ser pesadas en términos de recursos y su tiempo de arranque es más largo.

Entonces, en base a eso, no podemos tener lo mejor de ambos mundos?

![](/img/firecracker/both-worlds.png)

## Les presento Firecracker, la joya open-source escondida de AWS
La primera vez que leí sobre [Firecracker](https://firecracker-microvm.github.io/) fue en 2021 gracias a Julia Evans (soy súper fan de todo el trabajo que publica en internet) y su post ["Firecracker: start a VM in less than a second"](https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second/). La verdad ese título me llamó mucho la atención, levantar una VM en menos de un segundo, tenía que ser algo interesante. Para mi sorpresa descubrí que Firecracker era un proyecto open source de Amazon Web Services, mi cloud provider favorito que vengo usando desde el 2016.

Seguí las instrucciones de ese post y voilà! Yo también tenía mi primera microVM corriendo en menos de un segundo, me sorprendió full!

Firecracker es una tecnología de virtualización que permite crear micro máquinas virtuales (microVMs) con la velocidad y eficiencia de recursos de los contenedores, lo cual en mi opinión tiene sentido. Está construido con Rust, lo que le da a Firecracker los beneficios de seguridad que tiene Rust.

> En sus inicios Firecracker fue un fork de [CrosVM](https://chromium.googlesource.com/chromiumos/platform/crosvm), luego tomó su propia forma

Es importante notar que Firecracker requiere [KVM](https://linux-kvm.org/page/Main_Page) por debajo, que está disponible en la mayoría de los servidores Linux físicos, y en AWS en instancias metal e instancias estándar de las familias: `c8`, `r8`, `m8` (gracias a la virtualización anidada).

Actualmente Firecracker se usa para dar una capa extra de seguridad y sandboxing a diferentes servicios: AWS Lambda, AWS Bedrock AgentCore, AWS Lambda MicroVMs, siendo AWS Lambda el servicio que lo viene usando [desde al menos 2018](https://aws.amazon.com/blogs/opensource/firecracker-open-source-secure-fast-microvm-serverless/)! Antes de saber que Firecracker existía, pensaba que AWS Lambda usaba algún tipo de tecnología de contenedores, no docker como tal, pero algo similar que usa seccomp, cgroups y namespaces. Pero sabiendo que puedes levantar máquinas virtuales en milisegundos, con requerimientos de recursos reducidos (aparte de los recursos que requiere la aplicación que se va a ejecutar), tiene totalmente sentido que AWS Lambda use este tipo de tecnología para la ejecución de millones y millones de funciones Lambda que podrían contener código no confiable, una forma muy inteligente de protegerse y ofrecer un gran servicio!

Con eso en mente, podemos responder la pregunta que hicimos antes, Firecracker combina lo mejor de ambos mundos, tiene su propio kernel con un bajo consumo de recursos y un tiempo de arranque rápido!

La documentación de Firecracker no es tan "fancy" como la de otros proyectos como Docker, sin embargo si leen la [documentación](https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md) en markdown con cuidado, van a poder correr sus propias VMs sin complicaciones!

### Limitaciones de Firecracker
- Necesitas [construir una imagen personalizada del kernel de Linux](https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md), no es una tarea imposible, pero necesitas estar familiarizado con lo básico de compilar un kernel.
- Como el tiempo de arranque de Firecracker es de solo milisegundos, las microVMs de Firecracker solo soportan 4 dispositivos:
  - `virtio-net`: soporte de red
  - `virtio-block`: soporte de almacenamiento en bloque (raw)
  - `virtio-vsock`: para comunicación host-a-microvm
  - Un teclado con una sola tecla (la tecla de reinicio)
- Firecracker no soporta USB, BIOS, ACPI o PCI/GPU
  - El soporte para PCI estaba en desarrollo y fue agregado en [agosto de 2025](https://github.com/firecracker-microvm/firecracker/pull/5364)


### Sin vendor lock-in
Como mencioné antes, si están usando AWS Lambda, AWS Bedrock AgentCore, AWS Lambda MicroVMs, ya están usando Firecracker por debajo, así que no hay necesidad de implementar nada nuevo. Sin embargo, no todos usan esos servicios, o ni siquiera usan AWS. Lo que me gusta de Firecracker es que es open-source y no un servicio de AWS como tal. Así que es posible usarlo donde quieras (on-prem, otros cloud providers), siempre y cuando tengas KVM habilitado, es decir, que puedas ver el dispositivo `/dev/kvm`.

Es más, existen empresas como [Fly.io](https://fly.io/machines/) que usan Firecracker para todos sus [servicios de cómputo](https://docs.fly.io/reference/architecture).

Sin embargo, si quieres usar Firecracker a escala, lo más probable es que necesites crear una abstracción encima para su orquestación. En la siguiente sección (Orquestación de MicroVMs con Kata Containers) veremos justamente eso.

### Firecracker y su influencia
Después de que Firecracker fue lanzado y abierto al público, nacieron otros proyectos con el mismo objetivo, MicroVMs rápidas a partir de las lecciones aprendidas de Firecracker.

- [Cloud Hypervisor](https://www.cloudhypervisor.org/): Es el runtime recomendado para Kata Containers (lo veremos en la siguiente sección). Diseñado [en base a las lecciones aprendidas](https://github.com/cloud-hypervisor/cloud-hypervisor#differences-with-firecracker-and-crosvm) de Firecracker.
- [Docker Sandboxes](https://www.docker.com/blog/why-microvms-the-architecture-behind-docker-sandboxes/). Aunque no tiene ninguna relación directa con Firecracker, siguen la misma idea de crear contenedores (sandboxes) con su propio aislamiento de kernel.

### Primera demo
Preparé diferentes demos, la primera es crear una máquina virtual de ejemplo en una instancia EC2 con virtualización anidada habilitada. El código de terraform para esta demo lo pueden encontrar [acá](https://github.com/sguillen-proyectos/cd2026-rediscovering-firecracker/blob/main/example-ec2/main.tf).

Y este es un video corto (sin audio), corriendo la misma demo.

{{< youtube RRu3NNZ_0aA >}}


En la siguiente sección les mostraré cómo orquestar MicroVMs en un entorno de Kubernetes usando Kata Containers.

## Orquestación de MicroVMs con Kata Containers
Cuando corremos un cluster de Kubernetes, lo más probable es que tengamos múltiples nodos corriendo diferentes servicios en diferentes contenedores. Como mencioné arriba, una de las desventajas de seguridad es el hecho de que todos esos contenedores comparten el kernel del host. Esto abre un vector de ataque para un escenario como este:

- Uno de los servicios tiene una vulnerabilidad de RCE
- Hay un exploit de kernel circulando para Local Privilege Escalation, similar a los que salieron hace algunos meses, como ser: [CopyFail](https://copy.fail/), [Dirty Frag](https://www.dirtyfrag.tech/)
- Se escapa del contenedor
- Se toma el control del host
- El resto de contenedores corriendo en el mismo nodo quedan comprometidos

Como mencionamos, Firecracker nos permite combinar lo mejor del mundo de los contenedores y del mundo de las VMs en términos de seguridad y velocidad.

Y eso es justamente [Kata Containers](https://katacontainers.io/), un container runtime que nos permite crear micro VMs livianas que van a correr el contenedor dentro de ellas, así nuestros servicios arrancan con su propio aislamiento de kernel y solo se agregan algunos milisegundos a su tiempo de arranque.

Algo que me gusta de Kata Containers es que si ya tienes Kubernetes corriendo, no necesitas hacer grandes cambios para empezar a usar Kata Containers en algunos de tus servicios y empezar a probar. Lo único que necesitas es especificar el campo `runtimeClassName` en la especificación del Pod/Deployment.

Kata Containers soporta diferentes runtimes:
- Cloud Hypervisor (**recomendado**)
- Firecracker
- QEMU
- Dragonball (no ese Dragonball xD)

### Demo - Instalación
Instalar Kata Containers en un cluster existente es bastante simple, yo usé un cluster de EKS que ya tenía:

{{< youtube 3KdC3COpArc >}}

Los comandos y pasos usados están documentados en el [repositorio](https://github.com/sguillen-proyectos/cd2026-rediscovering-firecracker#install-kata-containers-helm-chart) de Github donde están publicadas todas las demos.

### Demo - Cloud Hypervisor
Cambiar un Deployment existente para que use Kata Containers y su propio aislamiento de kernel es solo cuestión de agregar el `runtimeClassName` a las specs del Pod/Deployment. Funciona out-of-the-box sin configuraciones extra.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kata-clh-smoketest
spec:
  runtimeClassName: kata-clh # <<<<<< This will make the pod to have its own kernel
  restartPolicy: Never
  containers:
    - name: shell
      image: public.ecr.aws/docker/library/alpine:latest
      command: ["sleep", "infinity"]
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "250m"
          memory: "256Mi"
```

{{< youtube OkEA29qgcXA >}}

### Demo - Firecracker
Correr Firecracker con Kata Containers tiene algunos desafíos extra, y después de que salió `containerd` v2 hay algunos problemas.

Primero, necesitamos hacer que `containerd` pueda usar device-mapper, que se usará para descargar y desempaquetar las capas de la imagen docker dentro de nuestra microVM. Las configuraciones y los pasos requeridos para eso están en el [repositorio de la demo](https://github.com/sguillen-proyectos/cd2026-rediscovering-firecracker/blob/main/scripts/kata/containerd-devmapper.toml).


Sin embargo, como podemos ver en el siguiente video, la creación del contenedor falla al intentar extraer las capas de la imagen Docker de nuestro pod, a pesar de que tenemos las configuraciones de device mapper adecuadas, que son las recomendadas para correr Firecracker con Kata containers.

{{< youtube cT_4CMDi3-c >}}

La razón es que después de que `containerd` se actualizó a v2, hubo algunos cambios que rompieron el desempaquetado de capas de una imagen Docker al usar device-mapper. Todavía hay dos issues abiertos en Github, existen algunos workarounds como el flag `--local`, pero en general eso hace que Firecracker, lastimosamente, no sea una buena opción para Kata Containers.

- https://github.com/containerd/containerd/issues/11390
- https://github.com/containerd/containerd/issues/11606

### Demo - Conectividad de red entre servicios
Esta última demo muestra (con Cloud Hypervisor) que nuestros Deployments se pueden conectar entre sí como pods sin problemas, a pesar de que tienen su propio kernel.

{{< youtube kEhczwk1-sc >}}

## Los siguientes años van a ser una locura! (actualización octubre 2026)
Nada es 100%, como dice una frase muy conocida en la industria:

> si crees que tu red es segura porque tienes un firewall, recuerda que hay un adolescente en algún lugar del mundo tratando de entrar ahora mismo solo por diversión.

En nuestro caso, alguien podría decir que agregar un kernel propio a cada pod lo hará 100% seguro. ERROR! Solo estamos agregando una capa extra de seguridad, que le pondrá más barreras a un atacante en caso de que un Pod sea comprometido. Sin embargo, hace algunos días, Vercel confirmó que encontraron una vulnerabilidad zero-day en KVM, una locura! Claro que no será revelada hasta que sea parchada (responsible disclosure). [Link](https://x.com/rauchg/status/2106402024804020657).

{{< x user="rauchg" id="2106402024804020657" >}}

Durante los últimos 10 años trabajando como DevOps Engineer, la seguridad se volvió un ciudadano de primera clase en la mayoría de las organizaciones en las que trabajé, lo cual es importante y me alegra un montón, sin embargo con el auge de la IA y los agentes, los siguientes años van a ser una locura! Si están a cargo de infraestructura crítica, hoy más que nunca, parchar constantemente y hacer sandboxing lo más posible va a ser mucho más importante.

## Pensamientos finales
Hoy en día las amenazas de ciberseguridad son cada vez más grandes, y si estamos haciendo deploy, operando y exponiendo servicios a clientes, es importante tomarse la seguridad mucho más en serio que nunca, el sandboxing es una forma de hacerlo. Pero en general, se trata de abrazar la seguridad desde el primer commit hasta que ese mismo commit llega a producción. Abracen la cultura DevSecOps!

Si les interesa todo el ecosistema de MicroVMs en general, les recomiendo darle una mirada a este [repositorio](https://github.com/infracloudio/awesome-microvm).
