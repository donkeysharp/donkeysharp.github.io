---
title: "Mocking EC2 metadata server locally"
url: "mock-ec2-metadata"
date: 2023-05-28T21:08:04-04:00
draft: false
---

Some time ago I was working on creating a local docker-based development environment for some microservices at work so developers can have the necessary infra components on their machines and that will help them with their daily tasks. Initially, the business logic of some microservices were a black box to me. After containerizing the applications and creating the docker-compose setup, some of them started failing and after checking the logs it turns out that the applications were using AWS SDK to get ec2 instance metadata.

For those who are not familiar with [EC2 metadata](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html), it is a set of HTTP endpoints that are served in the `169.254.169.254` IP address. This is used to retrieve metadata such as instance ip, AWS region, availability zone, IAM credentials, etc. And internally the AWS SDK uses these enpodints for the same purpose.

By default, any user from their local machines won't be able to reach `169.254.169.254` because it is part of the [IPv4 Link-Local Address space](https://www.rfc-editor.org/rfc/rfc3927). So we have two problems:
- Route all traffic to that special IP address somewhere that is known.
- Simulate all the HTTP metadata endpoints.

## Making `169.254.169.254` available locally
Fortunately, it is possible to make traffic to `169.254.169.254` to work locally or in a docker-based local environment. Linux and MacOS provide tools that make these kinds of tasks simple.

Depending on the operating system you are using, there are different ways to route traffic `169.254.169.254` to the local interface.

In MacOS you can do it by running the command:
```sh
$ sudo ifconfig lo0 alias 169.254.169.254
```

In Linux, there are different options:

Using `ifconfig`:
```sh
$ sudo ifconfig lo:0 169.254.169.254 netmask 255.255.255.255
```

Using `iptabes`:
```sh
$ sudo iptables -t nat -A OUTPUT -d 169.254.169.254 -j DNAT --to-destination 127.0.0.1
```

This way any network connection going to `169.254.169.254` will go to our local machine under the hood.

## Simulate all the HTTP metadata endpoints
Because a lot of engineers might have the same issue which is accessing the metadata server in a local environment, AWS decide to create a mock server that serves all the HTTP endpoints. The project [amazon-ec2-metadata-mock](https://github.com/aws/amazon-ec2-metadata-mock) helps us with that.

Just download the binary for your operating system from its [releases page](https://github.com/aws/amazon-ec2-metadata-mock/releases) and you can start using it.

Some options that it has are:
![](/img/ec2-metadata-mock.png)

For the AWS SDK to work when trying to request metadata, a request to `http://169.254.169.254/latest/meta-data` must work. Fortunately, we solved the issue of pointing `169.254.169.254` to localhost in the previous section. `ec2-metadata-mock` by default exposes itself in port `1338`, so to trick AWS SDK we need to expose the fake endpoints in port `80`.

For that, we only need to run it as:

```sh
$ sudo ec2-metadata-mock -p 80
```
## Putting it all together!
Now that we know how to route traffic to `169.254.169.254` wherever we want and we have a fake EC2 metadata server, we can join everything and have a fully docker-based development environment.

For this, I am going to have a container for the `ec2-metadata-mock` tool and another which will be named `debug` that might represent any application that will need access to the EC2 metadata mock server.

The source code for this experiment can be found in this [repository](https://github.com/donkeysharp/ec2-metadata-mock-environment).

So the Docker compose file will look like this:

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

And it contains a container that will run the `ec2-metadata-mock` server in port `80` and a debug container that simulates an application. Remember the goal is to make any HTTP request from within the application container (in this case the `debug` container) to `http://169.254.169.254/` and the connection goes to the metadata server container under the hood.

For applications to route traffic to metadata server, I added an entry point script that runs before the application starts. It retrieves the internal IP address used in the docker network for the metadata server container, then it creates an iptable rule that routes any traffic to `169.254.169.254` to the metadata server ip address. It is important to note that we need to add the `NET_ADMIN` [Linux capability](https://man7.org/linux/man-pages/man7/capabilities.7.html) in order to use iptables inside a container.

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

So once running the whole solution, we can test that indeed we can curl `169.254.169.254` from within the `debug` container.

```sh
$ docker exec -it local-ec2-metadata_debug_1 curl http://169.254.169.254/latest/meta-data/instance-id

i-1234567890abcdef0
```

## Recommendations
Although this solution uses iptables and works, I will investigate and make an update to this post if it is possible to define a custom network in docker-compose using the link-local range and assign a specific ip address to the ec2-metadata container.
