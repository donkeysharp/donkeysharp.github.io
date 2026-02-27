---
title: "Connecting an AWS VPC to your Homelab without dying in the process"
url: "connect-vpc-to-homelab"
date: 2025-06-21T11:37:13-04:00
tags: ["aws", "homelab", "linux"]
draft: true
---

Hey there! It's been a while since my last technical post. In this post I will be showing some experiments I was playing with during the weekend in order to connect an AWS VPC to my Homelab.

I want to first thank to Lib, she posted some questions regarding this topic on the AWS User Group Cochabamba Whatsapp group. Although I have a theoritical idea on how to do it, she sparked my curiosity and I started checking documentation with more detail with the idea to implement it.

## My Homelab
The design of my homelab is very straightforward:
- A home router (Router made in Bolivia <3 by [Confiabits](https://www.confiabits.com/mt7981.html)) with OpenWRT 23.05 that supports this model and maintained by [Luis Mita].(https://wiki.hacklab.org.bo/wiki/Confiabits_MT7981)
- Some Raspberry Pis 3 (I will post about this later) and minicomputers.
- The naming of the servers I use are from the Tolkien's universe... yea, I'm a big fan.
- The CIDR range I use for my homelab is the old and trusty `192.168.1.0/24`.

For this experiment we will work mainly with two servers:
- [Palantir](https://tolkiengateway.net/wiki/Palant%C3%ADri) - My entrypoint from the Internet.
- [Galadriel](https://tolkiengateway.net/wiki/Galadriel) - One private server in my homelab.

### Exposing it to the public internet
Having a public IP in Bolivia is a russian-roulette, depending on the ISP your plan, etc, etc, you could have or not the option to have a public ip address. In my case to expose my homelab's resources to the public via a public VPS on Peru that I [rented](https://elastika.pe/). It has a public IP `11.22.33.44` and the latency between this public servers and my homelab is  ~22ms which is good enough for me. This one is named `Palantir`.

### Connecting Palantir to my homelab
In order to connect Palantir with my homelab is using Wireguard. Usually I use the homelab router running Openwrt for this, but for the experiment I will use server `Galadriel` as a bridge between `Palantir` and the rest of my homelab.

- `Galadriel` connects to `Palantir` via wireguard using the `10.0.0.0/24` CIDR range.
- Any traffic to `192.168.1.0/24` inside `Palantir` is routed via `wg0` (the Wireguard interface).






## Notes
- site-to-site connection once it is created, it costs 0.05 USD per hour, and 0.09 USD per GB after the 100GB that are part of the free tier.
