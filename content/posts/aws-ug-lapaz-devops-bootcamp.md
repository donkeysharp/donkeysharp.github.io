---
title: "AWS User Group La Paz - DevOps Bootcamp"
url: "aws-user-group-la-paz-devops-bootcamp"
date: 2026-10-14T20:47:12-04:00
tags: ["aws", "bootcamp", "devops", "ecs", "containers", "observability", "pipelines"]
draft: true
---

![](/img/devops-bootcamp/00.png)

The [AWS User Group La Paz](https://www.meetup.com/aws-user-group-la-paz) organized the first DevOps Bootcamp in Bolivia, which is open and free for the community! The idea of this bootcamp was to reach to professionals and students which are interested in learning more about the DevSecOps culture and its principles, and putting them in practice, 100% hands-on using AWS and other technologies widely used in the industry.

Here are some details about how we organized:

## Planning
The idea started couple years ago when we met with [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/) (and good old friend of mine) and between food and beers, we mentioned that it would be cool to organize something like a DevOps bootcamp.

Yamil Urbina, in my opinion, helped setting the foundations of the DevOps and Cloud Community here in La Paz - Bolivia back in 2016, organizing events regarding Docker, Kubernetes, Hashicorp, and cloud in general where I also had the luck to be part of, then he started the "La Paz Cloud" community which eventually became the AWS User Group La Paz.

This year, he had the chance to spend some months in Bolivia, so we decided to kick this off!

Because this was the first time we were doing something like this, we didn't know what to expect, so with the purpose to teach but also learn from these sessions i.e. which method works better, validate if the content is too basic or too advanced, we decided to create an application form, where the people interested applied to be part of this first DevOps Bootcamp. The form pretty much had two key fields, their experience and their motivations.

We chose 17 people between students and professional, 2 started but didn't finish the bootcamp, but 2 other joined from session 2.

There was a mix of specialities which let us show the DevSecOps culture on the different areas participants work. We had backend engineers, QA engineers, Data engineers, sysadmin mainly with on-premise experience.

### The instructors
![](/img/devops-bootcamp/10.png)

- [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/), Platform Engineer at Cisco, ThousandEyes Project.
- [Alex Flores](https://www.linkedin.com/in/alex-flores-1599a4136/), DevOps Engineer at AssureSoft, AWS Golden Jacket and Community Builder
- [Sergio Guillen](https://www.linkedin.com/in/sergio-guillen-a6392b155), DevOps Engineer at Cloudreams, [AWS User Group La Paz Leader](https://linktr.ee/aws.user.group.lpz).

## The syllabus and the dynamic
We planned to have 6 on-site sessions and 6 virtual sessions.

The goal of the on-site sessions was to teach a new topic from the program, and practice, practice practice. As we were teching a new concept, we gave steps so participants could start having hands-on practices from day one. We met all Saturdays from 9:00AM to 12:00PM. We also left them some assignments that they had to do at home.

On the other hand, the virtual sessions we had on Thursdays nights, were to make a review of what we did on the on-site session, ask questions participants had and help them solve the assignment we left.

Requirements before starting:
- Because we were going to check different technologies and in order to save some time, participants needed to have ready the following:
- An [AWS](https://aws.amazon.com/) account
- An [InfraCost](https://www.infracost.io/) account
- A [Grafana Cloud](https://grafana.com/products/cloud/) account
- A [PagerDuty](https://www.pagerduty.com/) account

The topis per week were the following ones:
- **Week 1**: Intro to the bootcamp, to AWS and creating a more robust AWS Infrastructure
  - Show the [muyu-invoice application](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator), its current architecture (application and database, everything in the same server), some of the challenges with this architecture.
  - Start by designing a stronger base infrastructure that will allows us in the following sessions to work better with the different AWS services we are planning to use.
  - Revisit networking concepts such as CIDR notation, OSI model, etc.
  - Check AWS VPC, Subnets, Routing tables, security groups, all using **manual steps**. All the participants were able to follow the steps, learn some troubleshooting when things didn't work and had the foundations of the infrastructure we were going to use in the following sessions.
- **Week 2**: Infrastructure as Code
  - Show the challenges of using manual steps and why that is not a good idea.
  - Introduce to the participants the concept of infrastructure as code and the Terraform tool and its benefits.
  - Re-create the infrastructure made in the previous session but in Terraform.
  - All participants were able to have a reproducible way to create infrastructure thanks to Terraform.
- **Week 3**: Moving the application to Docker
  - Introduction to Docker and how it helps us to have reproducible builds of our application and its distribution.
  - Run the application locally using docker-compose.
  - See the challenges with big images.
  - Check the benefits of alpine-based images and possible issues (when there are strong dependencies of glibc code that is not present in musl).
  - Introduce to multi-stage builds and the importance of the order of layers.
  - Introduce Trivy to start considering the security and scanning process as part of the software development life cycle.
  - All participants were able to build the Docker image of the muyu-invoice application and push it to its corresponding ECR repository, which was created with Terraform (applying what we learned previously).
- **Week 4**: Introduction to ECS
  - Check the concepts of container orchestration.
  - Check the components of an ECS cluster: Service, TaskDefinition, Load Balancer, Target Groups, etc.
  - Create the ECS components required to deploy the [muyu-invoice](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator) application using Terraform.
  - Create the RDS database cluster using Terraform.
  - Test and deploy the application in the cloud and access it from the public Internet.
- **Week 5**: Asynchronous architectures
  - Refactor the application making the invoice generation to be more cloud native, i.e. store the invoice pdfs on an S3 bucket.
  - Make invoice generation a background task using SQS Queues, using SES to send emails, etc.
  - Check the security part of the terraform code using Checkov.
  - Check an estimates of the cost of our infrastructure using InfraCost.
- **Week 6**: Observability and monitoring
  - Introduce the concepts of sending logs to Grafana Loki.
  - OpenTelemetry and custom metrics.
  - Alerts and sending the alerts to PagerDuty.
  - Generating some chaos, bringing down the invoice generator background job and receiving alerts

As you might have notice, we are not considering pipelines as most DevOps courses do. The way we oriented this was to identify a problematic, and which tools or techniques can help us solve it. We decided not to bring a session for CI/CD pipelines because we thought that the pipeline was going to be a summary of everything we learned in the six sessions, hence, the CI/CD pipeline (we showed some of the usage of Github Actions though), was supposed to be like the final project each participant was recommeded to do.

### Thanks to AWS and Digital Harbor!
![DigitalHarbor Offices!](/img/devops-bootcamp/20.png)
We couldn't have done this without the help of Digital Harbor as they were keen to let us use their offices here in La Paz for this bootcamp, which made the on-site sessions way more attractive and easy for the participants to arrive due to its strategic location. Belive me, their offices are amazing!

AWS Latam Community also helped us with the food and sodas during the Saturday sessions, we couldn't have done a bootcamp without some delicious Salteñas!

![Las Salteñas](/img/devops-bootcamp/30.png)

## Feedback
We really appreciate feedback because it helps us to improve for future iniciatives like this one! We really thank to all the participants, because the same way you were able to learn something from the instructors, we learned a lot from you.

These are the [results for the feedback](https://drive.google.com/file/d/1QijQ5cQMw4j1e3CkV66LHscR1LNN-H_h/view?usp=sharing) form we sent.

We also prepared a video (it's in Spanish) with some opinions of the participants about the DevOps Bootcamp.

{{< instagram Dbqwrprpamk >}}

## Lessons Learned and what's comming in the future
The same way participants were able to learn more about DevOps and DevSecOps, we (as instructors) learned a lot from the feedback and from all the on-site and virtual sessions. Since how to present specific topics, which analogies work better, etc. We also found some knowledge that we assumed participants might had already e.g. familiarity and usage of Unix systems most commonly GNU/Linux, networking, etc. which is great! because now we know which type of material to prepare for future versions of the DevOps Bootcamp!

So expect some set of sessions, with more specific content e.g. Linux + AWS, more about specific services in AWS and DevOps. You can know more about the events the community on [our social networks](https://linktr.ee/aws.user.group.lpz).
