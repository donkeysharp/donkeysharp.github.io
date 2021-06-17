---
title: "Setting Up MySQL master-worker"
url: "mysql-master-worker-part-0"
date: 2020-05-26T22:07:10-04:00
draft: true
---


## The Motivation
When I started learning software development I used Microsoft technologies. I remember that with two clicks Visual Studio made everything for you, practically you had a complete project with persistence, a lot of lines of code that were generated automatically.

The thing is that I never felt thursty of that big scaffolding that VS generated and also didn't feel I was learning something so I went further and learned the foundations behind all that fancy stuff (then I really felt like I learned something). In the end I never used those scaffolding tools when I was learning. Don't get me wrong, I use scaffolding tools for certain things, it saves a lot of time, but I need to understand first what's going on under the hood, so when something fails I have a better understanding in order to diagnose and fix.

When I got my first job and started working with these technologies, some developers started projects with that "magical" setup, guess what, when something broke or a new feature needed to be implemented, the lack of knowledge on the foundations of that technology led to more bugs and patches that didn't fix the real issue.

The other day I was chatting with a friend about different things related with cybersecurity and infrastructure. At some point we were talking about different setups and how AWS (or any other cloud provider) makes things easier for you in terms of infrastructure. One of the things we talked about was read replicas in databases. Having a master-worker setup in MySQL using [AWS RDS](https://aws.amazon.com/rds/) is very straigthforward and even no prior knowledge of how replication works is required. A user only needs to follow the steps in the docs and that's it, magic!.

For some services I have an idea of what's going on under the hood based on curiosity or previous experiences of similar things I did on-prem environments so that gives me a better understanding.

So I made a comparison and although I know how to create and manage these infrastructures in AWS, I don't fully understand what's going on behind these read replicas. I know that AWS is a black-box but a lot of its services are based on open source projects and if AWS or any cloud provider offers a managed service for an open source project with some cool features, it's more likely that those cool features can be achieved without AWS (of course more effort will be required).

> **Note:** In general if I would need to implement this kind of setup in production, I would do it using the cloud provider's managed services instead of mounting everything by myself without doubt.

So with this posts I want to share what I learned and some experiments I did in order to have a better understanding in how to setup a read replication environment manually (partially).

## Before we begin
> **Important:** This laboratory has the objective to show the basics behind MySQL read replication and it should be used for learning purposes **only**. Of course you can extend what you learn here for a production ready setup. **This is just a learning exercise**

The laboratory for this exercise is implemented in [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/) so it can be replicated easily if you want to test in your machine. The whole project is available in this Github [repository](https://github.com/sguillen-proyectos/mysql-replicas).

The software requirements to run this project are:
- Docker
- Docker Compose
- GNU Make
- ApacheBench (for some GNU/Linux distros it is available in the `apache2-utils` package)


I hope you can learn something new and enjoy the next articles.
