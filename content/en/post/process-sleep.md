---
title: "What Happens When A Linux Process Goes To Sleep?"
url: post/what-happens-when-a-process-goes-to-sleep
date: 2021-06-15T17:43:00-04:00
draft: true
---

No matter the programming language (be it compiled or interpreted), calling the `sleep(NUMBER_OF_SECONDS)` function might be required depending on the problem. Have you ever wondered what happens to a process when it goes to sleep? In this post I will share what I learned so far while investigating the internals of this simple function.

Let's begin by defining some examples on how `sleep` is used in different programming languages. The examples will start a process that will sleep for one second:

Bash
```sh
#!/bin/bash

sleep 1
```

Python
```py
import time

time.sleep(1)
```

Golang
```go
package main

import "time"

func main() {
  time.Sleep(1 * time.Second)
}
```

C
```c
#include <unistd.h>

int main() {
  sleep(1);
  return 0;
}
```

### First Ideas?
One of the first ideas I had about what does `sleep` really do, was that the sleep function had some sort of a `while(true)` loop, however we all know that a `while(true)` loop is CPU expensive. Hence if we would like to implement a custom `sleep` function with a while-true-like loop, it will definitely be a nightmare for the CPU:

```c
#include <stdio.h>

#define SOME_MAGIC_NUMBER 365000000

void nightmare_sleep(int seconds) {
  int i;
  for (i = 0; i < seconds * SOME_MAGIC_NUMBER; i++);
  printf("Finished\n");
}

int main() {
  nightmare_sleep(1);
  return 0;
}
```

The previous example "pauses" the process for ~1 second (tested on my machine only), however one core is 100% during that time, so definitely this is not the way sleep works under the hood.

### Going Deeper


## References
- https://elixir.bootlin.com/linux/latest/source/fs/select.c#L700
- https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1887
- https://elixir.bootlin.com/linux/v5.12.11/source/include/linux/hrtimer.h#L252
- https://www.humblec.com/proccess-states-in-linux-kernel/
- https://bencane.com/2012/07/02/when-zombies-invade-linux-what-are-zombie-processes-and-what-to-do-about-them
- https://jaxenter.com/linux-process-states-173858.html
- https://man7.org/linux/man-pages/man5/proc.5.html
- https://access.redhat.com/sites/default/files/attachments/processstates_20120831.pdf
- https://lwn.net/Articles/167897/
- https://lwn.net/Articles/152436/
