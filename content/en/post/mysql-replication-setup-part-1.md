---
title: "Setting Up MySQL Master-Worker - Part 1"
url: "mysql-master-slave-part-1"
date: 2020-05-27T23:00:10-04:00
draft: true
---

## From Independent Instances to a Master-Worker Setup
The idea of this first post is to first bring up three independent MySQL instances that are on the same network but they don't know each other to finally relate them in a [Master-Worker setup](https://dev.mysql.com/doc/refman/5.7/en/replication-setup-slaves.html).

A Master-Worker setup in MySql is a set of servers in which one server is chosen as the Master that can be used to do reads (`SELECT` queries) or writes (`INSERT`, `UPDATE`, `DELETE`, `ALTER`, `CREATE`, etc.). On the other hand the Worker servers will be used to have replicas of the data in the Master server and they are commonly used to execute only reads (`SELECT` queries). The most common scenario for this setup is performance. The Master usually gets all the write actions while the Workers run all the heavy queries with the purpose so multiple servers handle the workload and not just one.

As we are using Docker for this laboratory we are using the official MySql 5.7 image with some extra scripts and configuration files that are in the [Dockerfile](https://github.com/sguillen-proyectos/mysql-replicas/blob/master/Dockerfile). As you can see it is the same image plus some extra scripts and configuration files that I will explain as we move on.


The two configuration files we have are [master.cnf](https://github.com/sguillen-proyectos/mysql-replicas/blob/master/conf/master.cnf) and [slave.cnf](https://github.com/sguillen-proyectos/mysql-replicas/blob/master/conf/slave.cnf)


<!-- TODO: define common  -->

server_id

binlog_do_db
