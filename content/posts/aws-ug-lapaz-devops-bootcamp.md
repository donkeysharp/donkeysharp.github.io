---
title: "AWS User Group La Paz - DevOps Bootcamp"
url: "aws-user-group-la-paz-devops-bootcamp"
date: 2026-10-18T20:47:12-04:00
tags: ["aws", "bootcamp", "devops", "ecs", "containers", "observability", "pipelines"]
draft: true
---

The [AWS User Group La Paz](https://www.meetup.com/aws-user-group-la-paz) organized the first DevOps Bootcamp in Bolivia, which is open and free for the community! The idea of this bootcamp was to reach to professionals and students which are interested in learning more about the DevSecOps culture and its principles, and putting them in practice, 100% hands-on using AWS technologies.

Here are some details about how we organized:

## Planning
The idea started couple years ago when we met with [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/) (and good old friend of mine and the whole community here in Bolivia) and between food and beers, we mentioned that it would be cool to organize something like a DevOps bootcamp.

Yamil Urbina, in my opinion, helped setting the foundations of the DevOps and Cloud Community here in La Paz - Bolivia back in 2016, organizing events regarding Docker, Kubernetes, Hashicorp, and cloud in general where I also had the luck to be part of, then he started the "La Paz Cloud" community which eventually became the AWS User Group La Paz.

This year, he had the chance to spend some months in Bolivia, so we decided to kick this off!

Because this was the first time we were doing something like this, we didn't know what to expect, so with the purpose to teach but also learn from this sessions i.e. which method works better, validate if the content is too basic or too advanced, we decided to create an application form, where the people interested applied to be part of this first DevOps Bootcamp. The form pretty much had two key fields, their experience and their motivations.

We chose 17 people between students and professional, 2 started but didn't finish the bootcamp, but 2 other joined from session 2,

## The sessions
We planned to have 6 on-site sessions and 6 virtual sessions.

The goal of the on-site sessions was to teach a new topic from the program, and practice, practice practice. As we were teching a new concept, we gave steps so participants could start having hands-on practices from day one. We met all Saturdays from 9:00AM to 12:00PM. We also left them some assignments that they had to do at home.

On the other hand, the virtual sessions we had on Thursdays nights, was to make a review of what we did on the on-site session, ask questions participants had and help them solve the assignment we left.

### Thanks to Digital Harbor!
We couldn't have done this without the help of Digital Harbor as they were keen to let us use their offices here in La Paz for this bootcamp, which made the on-site sessions way more attractive and easy for the participants to arrive due to its strategic location. Belive me, their offices look really cool!

## The content and the dynamic

Requirements before first session:
-

The topis per week were the following ones:
- **Week 1**: Intro to the bootcamp, to AWS and creating a more robust AWS Infrastructure
  - Show the muyu-invoice application, its current architecture (application and database, everything in the same server), some of the challenges with this architecture.
  - Start by designing a stronger base infrastructure that will allows us in the following sessions to work better with the different AWS services we are planning to use.
  - Check AWS VPC, Subnets, Routing tables, security groups, all using **manual steps**. All the participants were able to follow the steps, learn some troubleshooting when things didn't work and had the foundations of a infrastructure we were going to use in the following sessions.
- **Week 2**: Infrastructure as Code
  - Show the challenges of using manual steps and why that is not a good idea.
  - Introduce to the participants the concept of infrastructure as code and the Terraform tool and its benefits.
  - Re-create the infrastructure made on week 1 but in Terraform
  - All participants were able to have a reproducible way to create infrastructure thanks to Terraform.
- **Week 3**: Moving the application to Docker
  - Introduction to Docker and how it helps us to have reproducible builds of our application.
  - Run the application locally using docker-compose
  - See the challenges with big images.
  - Check the benefits of alpine-based images and possible issues (when there are strong dependencies of glibc code that is not present in musl).
  - Introduce to multi-stage builds and the importance of the order of layers.
  - Introduce Trivy to start considering the security and scanning process as part of the software development life cycle.
  - All participants were able to build the Docker image of the muyu-invoice application and push it to its corresponding ECR repository, which was created with Terraform (applying what we learned previously).

- **Week 4**: Introduction to ECS
  -
- **Week 5**: Asynchronous architectures
- **Week 6**: Observability and monitoring


<!-- ## The participants -->
## Support from AWS LATAM
## Feedback
## Lessons Learned
