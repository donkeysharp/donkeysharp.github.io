---
title: "Accessing EC2 instances without exposing SSH port"
# url: "Access Ec2 Instances"
date: 2022-09-04T11:48:18-04:00
draft: true
---

The need to access a remote Linux server is very common be it for debugging purposes, maintenance, etc. The other day I was chatting with my friend Yarel and checking an alternative to SSH that helps accessing EC2 instances (and this can work for non-AWS instances as well).

## Using SSH
The most common approach is to start an Open SSH server and access the server, that implies opening port 22 (SSH port) to the public or use some security group ingress rules to allow accessing port 22 from specific IP addresses. Of course there are other security good practices to follow, but you get the point.

Some issues come up when there are more constraints, for example:
- If the person which is supposed to have access does not have a static IP address and it's constantly changing (very common where I live), that implies updating security group ingress rules everytime a user's ip address change.
- The organization has strict security policies where opening any SSH port is prohibited.

## AWS System Manager
AWS System Manager provides different features that help simplify management of applications and infrastructure. One of those features is Session Manager which provides an easy way to access EC2 instances as well as non-AWS servers.
