---
title: "AWS User Group La Paz - DevOps Bootcamp"
url: "aws-user-group-la-paz-devops-bootcamp"
date: 2026-10-18T20:47:12-04:00
tags: ["aws", "bootcamp", "devops", "ecs", "containers", "observability", "pipelines"]
draft: true
---

![](/img/devops-bootcamp/00.png)

The [AWS User Group La Paz](https://www.meetup.com/aws-user-group-la-paz) during June and July of 2026, organized the first DevOps Bootcamp in Bolivia, which is open and free for the community! The idea of this bootcamp was to reach professionals and students who are interested in learning more about the DevSecOps culture and its principles, and to put them into practice, 100% hands-on using AWS and other technologies widely used in the industry.

Here are some details about how we organized it:

## Planning
The idea started a couple of years ago when I met with [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/) (a good old friend of mine) and between food and beers, we mentioned that it would be cool to organize something like a DevOps bootcamp.

Yamil Urbina, in my opinion, helped set the foundations of the DevOps and Cloud Community here in La Paz - Bolivia back in 2016, organizing events about Docker, Kubernetes, HashiCorp, and cloud in general, which I was also lucky to be part of. Then he started the "La Paz Cloud" community which eventually became the AWS User Group La Paz.

This year, he had the chance to spend some months in Bolivia, so we decided to kick this off!

Because this was the first time we were doing something like this, we didn't know what to expect, so with the purpose of teaching but also learning from these sessions, e.g. which method works better, or whether the content is too basic or too advanced, we decided to create an application form where interested people applied to be part of this first DevOps Bootcamp. The form pretty much had two key fields: their experience and their motivations.

We chose 17 people among students and professionals. 2 started but didn't finish the bootcamp, but 2 others joined starting from session 2.

There was a mix of specialties, which let us show the DevSecOps culture applied to the different areas participants work in. We had backend engineers, QA engineers, data engineers, and sysadmins mainly with on-premise experience.

### The instructors
![](/img/devops-bootcamp/10.png)

- [Yamil Urbina](https://www.linkedin.com/in/yamilurbina/), Platform Engineer at Cisco, ThousandEyes Project.
- [Alex Flores](https://www.linkedin.com/in/alex-flores-1599a4136/), DevOps Engineer at AssureSoft, AWS Golden Jacket and Community Builder
- [Sergio Guillen](https://www.linkedin.com/in/sergio-guillen-a6392b155), DevOps Engineer at Cloudreams, [AWS User Group La Paz Leader](https://linktr.ee/aws.user.group.lpz).

## The syllabus and the dynamic
We planned to have 6 on-site sessions and 6 virtual sessions.

The goal of the on-site sessions was to teach a new topic from the program, and practice, practice, practice. As we were teaching a new concept, we gave steps so participants could start having hands-on practice from day one. We met every Saturday from 9:00AM to 12:00PM. We also left them some assignments that they had to do at home.

On the other hand, the virtual sessions, which we had on Thursday nights, were for reviewing what we did in the on-site session, answering participants' questions and helping them solve the assignments we left.

Requirements before starting: because we were going to check different technologies and in order to save some time, participants needed to have the following ready:
- An [AWS](https://aws.amazon.com/) account
- An [InfraCost](https://www.infracost.io/) account
- A [Grafana Cloud](https://grafana.com/products/cloud/) account
- A [PagerDuty](https://www.pagerduty.com/) account

The topis per week were the following ones:
- **Week 1**: Intro to the bootcamp, to AWS and creating a more robust AWS Infrastructure
  - Show the [muyu-invoice application](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator), its current architecture (application and database, everything in the same server), and some of the challenges with this architecture.
  - Start by designing a stronger base infrastructure that would allow us in the following sessions to work better with the different AWS services we are planning to use.
  - Revisit networking concepts such as CIDR notation, OSI model, etc.
  - Check AWS VPC, Subnets, Routing tables, security groups, all using **manual steps**. All the participants were able to follow the steps, learn some troubleshooting when things didn't work and had the foundations of the infrastructure we were going to use in the following sessions.
- **Week 2**: Infrastructure as Code
  - Show the challenges of using manual steps and why that is not a good idea.
  - Introduce the participants to the concept of infrastructure as code, the Terraform tool and its benefits.
  - Re-create the infrastructure made in the previous session but in Terraform.
  - All participants were able to have a reproducible way to create infrastructure thanks to Terraform.
- **Week 3**: Moving the application to Docker
  - Introduction to Docker and how it helps us to have reproducible builds of our application and its distribution.
  - Run the application locally using docker-compose.
  - See the challenges with big images.
  - Check the benefits of alpine-based images and possible issues (when there are strong dependencies on glibc features that are not present in musl).
  - Introduction to multi-stage builds and the importance of the order of layers.
  - Introduce Trivy to start considering the security and scanning process as part of the software development life cycle.
  - All participants were able to build the Docker image of the muyu-invoice application and push it to its corresponding ECR repository, which was created with Terraform (applying what we learned previously).
- **Week 4**: Introduction to ECS
  - Check the concepts of container orchestration.
  - Check the components of an ECS cluster: Service, TaskDefinition, Load Balancer, Target Groups, etc.
  - Create the ECS components required to deploy the [muyu-invoice](https://github.com/AWS-User-Group-La-Paz/muyu-invoice-generator) application using Terraform.
  - Create the RDS database cluster using Terraform.
  - Test and deploy the application in the cloud and access it from the public Internet.
- **Week 5**: Asynchronous architectures
  - Refactor the application to make the invoice generation more cloud native, e.g. store the invoice PDFs in an S3 bucket.
  - Make invoice generation a background task using SQS queues, use SES to send emails, etc.
  - Check the security of the Terraform code using Checkov.
  - Get an estimate of the cost of our infrastructure using InfraCost.
- **Week 6**: Observability and monitoring
  - Introduce the concepts of sending logs to Grafana Loki.
  - OpenTelemetry and custom metrics.
  - Alerts and sending the alerts to PagerDuty.
  - Generating some chaos, bringing down the invoice generator background job and receiving alerts.

As you might have noticed, we didn't include a session about pipelines as most DevOps courses do. The way we oriented this was to identify a problem, and then which tools or techniques can help us solve it. We decided not to have a session for CI/CD pipelines because we thought that the pipeline was going to be a summary of everything we learned in the six sessions, hence, the CI/CD pipeline (we did show some usage of GitHub Actions though) was meant to be the final project each participant was recommended to do.

### Thanks to AWS and Digital Harbor!
![DigitalHarbor Offices!](/img/devops-bootcamp/20.png)
We couldn't have done this without the help of Digital Harbor as they were keen to let us use their offices here in La Paz for this bootcamp, which made the on-site sessions way more attractive and easier for the participants to get to, thanks to their strategic location. Believe me, their offices are amazing!

AWS Latam Community also helped us with the food and sodas during the Saturday sessions, we couldn't have done a bootcamp without some delicious Salteñas!

![Las Salteñas](/img/devops-bootcamp/30.png)

## Feedback
We really appreciate feedback because it helps us to improve future initiatives like this one! We really want to thank all the participants, because in the same way you were able to learn something from the instructors, we learned a lot from you.

These are the [results of the feedback](https://drive.google.com/file/d/1QijQ5cQMw4j1e3CkV66LHscR1LNN-H_h/view?usp=sharing) form we sent.

We also prepared a video (it's in Spanish) with some opinions of the participants about the DevOps Bootcamp.

{{< instagram Dbqwrprpamk >}}

## Lessons Learned and what's coming in the future
In the same way participants were able to learn more about DevOps and DevSecOps, we (as instructors) learned a lot from the feedback and from all the on-site and virtual sessions: from how to present specific topics to which analogies work better, etc. We also found some knowledge gaps in things we assumed participants already had, e.g. familiarity with Unix systems (most commonly GNU/Linux), networking, etc. Which is great! Because now we know which type of material to prepare for future versions of the DevOps Bootcamp!

So expect a new set of sessions with more specific content, e.g. Linux + AWS, and more about specific AWS services and DevOps. You can learn more about the community's events on [our social networks](https://linktr.ee/aws.user.group.lpz).

Happy Hacking! 👾
