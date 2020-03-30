Donkeysharp Blog
================

Markdown based blog for my personal thoughts about things I find interesting and want to share. This blog uses [Hugo](https://gohugo.io/) static site generator, which makes things easier for me to maintain and publish.

Most of the info used here was obtained by reading Hugo's documentation or some internet blog posts. This is more a cheatsheet for me to do things faster
in case I forgot something :smile:.

## Cloning
This repository uses [Beautiful Hugo theme](https://github.com/halogenica/beautifulhugo) as a git sub-module. In order to fully clone this repository make sure to use the recursive option of cloning, choose one of the next depending on your version of Git.

```
$ git clone --recurse-submodules https://github.com/donkeysharp/donkeysharp.github.io.git
# For older versions of Git
$ git clone --recursive https://github.com/donkeysharp/donkeysharp.github.io.git
```

After cloning make sure to create a directory `public` referencing the `master` branch for publishing to Github Pages.

```
$ git worktree add -B master public origin/master
```


## Development
Hugo includes a development server, to start it run:

```
$ hugo server --watch -D
```

Which makes the blog available at `http://localhost:1313` and when a change is done it will be reflected instantly on the already mentioned URL.

## Create A New Post
It's possible to create a new post by just adding the markdown file on `content/{en|es}/post/` directory with the next format:

```
---
title: "Post Name"
date: 2018-01-05T13:04:24-04:00
draft: true | false
---
Post body
...
```

Or just simply use Hugo's command for this

```
$ hugo new content/{en|es}/post/some-new-post.md
```

## Configuring Site
All settings are in the `config.toml` file. Depending the chosen theme there will be different settings. For example most of the settings here came from [Beautiful Hugo Theme documentation](https://github.com/halogenica/beautifulhugo/blob/master/exampleSite/config.toml)


## Publish Site
Before starting with publish method, Make sure that the new blog posts have the `draft` header set to `false`.

If everything is good, just run:

```
$ ./deploy.sh "Some publish message"
```

This deployment script is from official Hugo's [documentation](https://gohugo.io/hosting-and-deployment/hosting-on-github/#github-user-or-organization-pages),
