---
title: "Devops Training"
# url: "Devops Training"
date: 2022-03-11T16:49:49-04:00
draft: true
---

Hey there! I hope this post can help people who is interested on getting a job as a DevOps Engineer, Cloud Engineer, Site Reliability Engineer, etc.

> I know there is a lot of discussion regarding the roles and if they would exist or what are their main tasks. To be honest, it really sucks because based on my experience and after applying for any of the roles mentioned about, I ended up doing almost the same and also each organization have their own definition of those roles. Anyways I hope this post can help.

The reason for this post is the next: I have worked and helped other companies that have junior engineers, most of them were accepted as interns then kept working there, but something I observed is that some of them just jumped to the pool, which under certains conditions is good, but noticed something that might cost a lot in the long term: their lack of knowledge of the basics. For instance, they know how to bring up a Kubernetes Cluster using existing Terraform modules, however they have problems with basic Linux administration skills which when troubleshooting a weird issue, bill comes. Or they maintain parts of big infrastructures but when they need to bring something from scratch they simply cannot.

These post will be a series of challenges that I used with people that was assigned to me for training that came with few or zero knowledge of infrastructure. It worked for them so I want to share it with you. Any feedback is welcome!

## First Challenge
Lear to access a remote server using SSH and learn the basics of the command line. For this I recommend to solve the


Work everything based on this [application](https://github.com/sguillen-proyectos/le-challenge-app).



## First steps with automation
- Learn the application:
  - Check what it does and what it is required to run the application, do it on Linux ONLY without containers or something like that (we'll get later so be patient :wink:) and write a manual with the steps.
- Bash scripting challenges:
  - Write a bash script that downloads and install the application on the server.
- Automate the installation of the application using Ansible in one server.
- Start considering scalation and automate using Ansible under the following consideration:
  - Create a server that has the data-storage service.
  - Create three servers running the NodeJS application.
  - Create a server that works as a load balancer so it connects with the NodeJS application.

## First steps with containers
