---
title: "Automating post-installation setup in my personal Debian machines"
url: post/debian-post-installation-automated-setup
date: 2019-05-13T21:45:39-04:00
draft: false
---

Hi, some time ago I [posted about my initial setup]({{< ref "post/my-computer-setup.md" >}}) in my Debian personal machines that use for work or personal projects. Some of the things I setup are: applications, desktop look and feel, etc. The last months I installed and re-installed my Debian machines so many times in different computers that I use (new computers, new hard drives, etc.) and this taks was repetitive.

Basically what I was doing was to review my previous blog post and repeat those steps. So far it has worked for me, but as it's becoming repetitive, I was encouraged to automate this whole process, both installation and configuration of certain applications and the configuration of the look and feel of the desktop (with the setup that I always use).


## The idea
While I could have done this project using a simple Bash script, I was encouraged to use Bash + [Ansible] (https://docs.ansible.com/) for fun and practice :smile:.

What I had in mind when I started this project was that as soon as the installation of the operating system was finished (in my case the Debian distribution), I would only have to execute a command and "magically" all the applications, configurations, etc. on my [personal setup]({{< ref "post/my-computer-setup.md" >}}) would be applied.

## Analyzing the Project
I posted this project on [Github](https://github.com/sguillen-proyectos/fresh-install-setup/) if you want to see the source code.

As this is a project that uses Ansible, there is a certain convention regarding the directory tree, file names, etc. I decided to use the following structure:

```
├── init-setup.sh
├── inventory
├── README.md
├── roles
│   ├── chrome
│   ├── common
│   ├── docker
│   ├── dotenvs
│   │   ├── tasks
│   │   └── templates
│   ├── games
│   │   └── tasks
│   │       └── main.yml
│   ├── mysql
│   │   ├── files
│   │   └── tasks
│   ├── node
│   ├── php7
│   ├── virtualbox
│   ├── vscode
│   └── xfce4
├── setup-playbook.yml
└── update-desktop-layout.sh
```

In Ansible what would be called the main program is the `playbook` which is responsible for executing different tasks against one or more servers, in this case, the main program for Ansible would be the file` setup-playbook.yml`. As you can see this file has a section called `roles`.

> **Note:** In Ansible what is called a `role` references to a reusable piece of code (like a module). This allows us to have the project better organized and has an internal directory structure as seen in the directory tree above.

I divided the project into different roles, each for a different purpose such as: a specific application or a group of applications including their settings. For example, in the role `common` install all the desktop utilities and command line utilities that I use every day. And in general there are roles for specific things that I use, Docker, software development tools, technologies and others. If you are more curious you can check the repo :smile:.

Continuing with the explanation, within Ansible there is a fairly important concept which is the `inventory`, which indicates all the servers where the tasks specified in the roles will be applied. This project has a file called `inventory` with particular options, since all the tasks will not be executed against several servers, but against one and it is the same local machine.

```
[local]
localhost ansible_connection=local
```

`[local]` is the group of servers, I named it `local` but it could be called anything, the important thing is that if you change its name, this name should also be reflected in` setup-playbook.yml` in `hosts: local`. Then the following lines indicate the hostname which in this case is `localhost` and` ansible_connection=local` which indicates that it will be a local execution and thus avoid the SSH authentication process that Ansible performs on each execution towards the same machine.

Finally the `init-setup.sh` script is a wizard which asks for certain options before going through the entire installation and configuration process. This would become the "magic" command that takes care of everything:

```
bash <(wget -q -O- https://raw.githubusercontent.com/sguillen-proyectos/fresh-install-setup/master/init-setup.sh)
```

## What do I gain with this?
Well, first I learned a couple of things that I didn't know about Ansible, I had fun and the most important thing for me (besides that was the objective of this project) is that now I save all the time of manual configuration that I carried out in a newly operating system installation.

Although I already had my [guide]({{< ref "post/my-computer-setup.md" >}}) of what packages to install and what configurations to perform, that took me between one and two hours, now all this time The setup is mainly conditioned to the speed of the internet.

Something in this project that is quite useful for me is that I managed to standardize my desktop settings (in this case Xfce4), since in many occasions "stylizing" my desktop is what I wasted the most time on.

## Final Comments
Although this project is supposed to be for my personal setup, I decided to share it in case the idea of automating the environment serves any of the people who read this blog post.

During the time I invested to carry out this project, several fun things happened that made me deny that I learned something new. I'll write about that series of unfortunate events in a next post.

Happy Hacking!
