---
title: "What Happens When A Linux Process Goes To Sleep?"
url: post/what-happens-when-a-process-goes-to-sleep
date: 2021-06-28T17:43:00-04:00
draft: true
---

It is possible when you are writing code, at some point you might need to pause the execution of a process by calling the `sleep(NUMBER_OF_SECONDS)` function depending on the problem you are solving. In this post, I will share what I learned so far while investigating the internal kernel mechanisms that make the `sleep` function work the way it does.

> **I appreciate your feedback.** I am not an expert on this topic as the Linux Kernel's internals are new for me, it was just my curiosity that drove me to get into the Kernel source code, and wanted to share what I learned. If you find something incorrect in this post, let me know by opening an issue in this blog's [Github repository](https://github.com/donkeysharp/donkeysharp.github.io). I will really appreciate it!.

## Process State
One of the first concepts that we need to review is the process state. A Linux process has a state associated which represents the execution state for the operating system. A process can be on one of the next states:

- Running
- Sleeping (interruptible and uninterruptible)
- Stopped
- Zombie

When a process is executing instructions in the CPU it is in `Running` state and when the process is waiting for something to happen i.e. waiting for network or disk I/O, etc. it will change to a `Sleeping` state.

We can verify it with a simple C example program:

```C
// states.c
// gcc states.c -o states
#include <stdio.h>
#include <unistd.h>

#define SOME_MAGIC_NUMBER 365000000l

void start_processing() {
  long i;
  printf("Starting Loop\n");
  for (i = 0; i < (long)(10 * SOME_MAGIC_NUMBER); i++);
  printf("Loop Finished\n");
}

int main() {
  pid_t pid = getpid();
  printf("PID: %d\n", pid);
  start_processing();
  printf("Sleep process\n");
  sleep(5);
  printf("Sleep finished\n");
  start_processing();
  return 0;
}
```

The code above will run a loop for some seconds, then it will sleep for 5 seconds, and finally loop for another number of seconds. Hence we expect the process state to be `Running -> Sleeping -> Running`.

While the program is being executed we can check the process state with the [Htop](https://htop.dev/) tool, which will usually show a letter on the 8th column that represents the process state e.g. `R` (Running), `S` (Sleeping), `T` (Stopped), etc.

![](/img/sleep-post/process-state.gif)

As expected the states the process had while executing were: `Running (R) -> Sleeping (S) -> Running (R)`.

### TL;DR
When a program calls the `sleep(NUMBER_OF_SECONDS)` function, it might call the `nanosleep` system call. Other syscalls can also send a process to sleep for some seconds e.g. `select` syscall.

The Linux Kernel implementation of the `nanosleep` system call will do the next:
- Initialize a High Resolution sleep timer.
- Change the process state to `TASK_INTERRUPTIBLE (Sleeping)`.
- Start the High Resolution sleep timer.
- Indicate to the scheduler that it can schedule another process and pause the execution of the process.

How the Linux kernel process High Resolution timers:
- The hardware CPU Timer will generate interruptions periodically, making the kernel handle them by calling the `hrtimer_interrupt` function.
- The `hrtimer_interrupt` function will process the existing timers and see if a timer expired. Once the High Resolution sleep timer expires, the kernel will call the `hrtimer_wakeup` function which will wake up the process associated with the timer, and that will change the state from `TASK_INTERRUPTIBLE (Sleeping)` to `TASK_RUNNING (Running)`.
- Finally some CPU cycles later the scheduler will continue the execution of the process where it was paused.

Continue reading if you are interested in more details.

## Going Deeper
As software engineers most of the time we may write applications that run in [user space or user mode](https://en.wikipedia.org/wiki/User_space) such as servers (any kind) or server-side applications, web, mobile or desktop applications, automation scripts, etc.

No matter the programming language, framework, or technology, internally a program running in user mode will always interact one way or another with the operating system (for this post Linux) via [System Calls or syscalls](https://en.wikipedia.org/wiki/System_call). For example, when we read a file, our code might indirectly communicate with the Linux Kernel via the `read` system call, then the kernel will ask the physical hard drive for the contents of the file we want based on the filesystem and finally return the requested content to our program.

There is a tool called [Strace](https://man7.org/linux/man-pages/man1/strace.1.html) that monitors all the system calls a process executes.

If we execute the previous C example but with Strace, we can see the following output:

```
$ strace ./states

... syscalls for process loading (they won't be useful right now) ...

write(1, "PID: 26846\n", 11PID: 26846
)            = 11
write(1, "Starting Loop\n", 14Starting Loop
)         = 14
write(1, "Loop Finished\n", 14Loop Finished
)         = 14
write(1, "Sleep process\n", 14Sleep process
)         = 14
nanosleep({tv_sec=5, tv_nsec=0}, 0x7ffefc933be0) = 0
write(1, "Sleep finished\n", 15Sleep finished
)        = 15
write(1, "Starting Loop\n", 14Starting Loop
)         = 14
write(1, "Loop Finished\n", 14Loop Finished
)         = 14
exit_group(0)                           = ?
+++ exited with 0 +++
```

The real output is longer than the one showed above but most of the first syscalls are always executed when a process starts (to load the C Standard Library, etc), but the ones that we want to check are the last.

The `write` syscall tells the Kernel that the program wants to display a string on the [standard output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)) (in this case the terminal). With that information, we can have an idea that the `printf` function communicates with the operating system by calling the `write` syscall.

Then the `nanosleep` syscall is called, which will indicate the Linux kernel to move the process from a Running state to a Sleeping state.

Before checking the Linux implementation of the `nanosleep` syscall, we have to check two concepts first to have a better understanding of what's coming.

### High Resolution Timers
Inside the Linux Kernel, different components need to wait for some time before executing something, this is where the Timers concept comes in. A timer is a struct in which we define its expiration time (the time to wait) and what function will be called once the timer expires.

The Linux Kernel has two types of timers: Low Resolution timers and High Resolution timers. What I learned is that Low Resolution timers have a limit in which the expiration time cannot be less than 100 milliseconds, on the other hand with High Resolution Timers it is possible to specify the expiration time in nanoseconds.

The High Resolution Timers framework is a set of structs and functions that optimally process the timers. Its implementation uses a linked list ordered by the expiration time of a timer which means that the head of the list will be the next timer to expire. In addition, to optimize the insertion and removal of timers in logarithmic time a [Red Black Tree data structure is used](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree).

This framework is very interesting by itself, in this article I will only check how it is used and some specific parts of its implementation. For more information regarding implementation details read [0], [1] and [2].

> Time management inside the Linux Kernel is a very interesting topic and the talk given by [Stephen Boyd](https://www.linkedin.com/in/stephen-w-boyd/) titled **"Timekeeping In The Linux Kernel"** [4] gave me a better understanding of how the Linux Kernel handles time-related tasks as well as its complexity. This talk helped me a lot. Thanks!

### Hardware Timer
The CPU (physically) has a clock and internally it has a programmable timer. In simple words, the main purpose of this timer is to generate [interruptions](https://en.wikipedia.org/wiki/Interrupt#Hardware_interrupts) periodically so the kernel can handle them. The frequency of these interruptions will depend on the architecture which is specified in the Linux Kernel during its compilation. The Linux Kernel abstracts this as [Clock Event Devices](https://www.kernel.org/doc/html/latest/timers/timekeeping.html#clock-events) and there is one Clock Event device per CPU. A Clock Event Device is used to schedule the next event interrupt [3].

When a timer interruption happens, the Linux Kernel will handle it by calling a function. [4] mentions that for High Resolution Timers the `hrtimer_interrupt` function is the handler for Timer interruptions (we will check its code later).

Another way to check which handler will be used is the `/proc/timer_list` read-only file that contains the list of pending timers and the Clock Event devices.

In my case, I validated that the handler for these devices in my machine is indeed the `hrtimer_interrup` function.

```
# /proc/timer_list
....

Tick Device: mode:     1
Per CPU device: 0
Clock Event Device: lapic-deadline
 max_delta_ns:   1916620707137
 min_delta_ns:   1000
 mult:           9624619
 shift:          25
 mode:           3
 next_event:     14403083615478 nsecs
 set_next_event: lapic_next_deadline
 shutdown: lapic_timer_shutdown
 periodic: lapic_timer_set_periodic
 oneshot:  lapic_timer_set_oneshot
 oneshot stopped: lapic_timer_shutdown
 event_handler:  hrtimer_interrupt              <<<<<<< the interrupt handler
 retries:        1316

Tick Device: mode:     1
Per CPU device: 1
Clock Event Device: lapic-deadline
 max_delta_ns:   1916620707137
 min_delta_ns:   1000
 mult:           9624619
 shift:          25
 mode:           3
 next_event:     14403083615478 nsecs
 set_next_event: lapic_next_deadline
 shutdown: lapic_timer_shutdown
 periodic: lapic_timer_set_periodic
 oneshot:  lapic_timer_set_oneshot
 oneshot stopped: lapic_timer_shutdown
 event_handler:  hrtimer_interrupt              <<<<<<< the interrupt handler
 retries:        484
.... The rest of devices per CPU of my machine
```

Now we have an idea of High Resolution Timers and that the CPU has a hardware timer that periodically sends interruptions to the Kernel, we can continue with the `nanosleep` syscall.

### Linux Kernel Implementation of `nanosleep`
> The Linux Kernel is a big project, thousands of files and millions of lines of code, navigating through them can be challenging. There is an online tool called LXR that helps navigate the Linux Kernel source code in a friendly way. The URL of the site is [https://elixir.bootlin.com/linux/latest/source](https://elixir.bootlin.com/linux).

So far we know that `nanosleep` syscall does all the magic to move the process state from Running to Sleeping for a given number of seconds, then to Running state again. Now we will explore the Linux Kernel source code and review what are the internal mechanisms behind that simple behavior.

First, we have to check where the `nanosleep` syscall is defined. After googleing a little bit, I found a document that specifies how [syscalls are defined](https://www.kernel.org/doc/html/latest/process/adding-syscalls.html#generic-system-call-implementation) in the Linux Kernel. Hence we have to search for `SYSCALL_DEFINE2(nanosleep, ....)`, the `2` in `SYSCALL_DEFINE2` indicates the number of arguments of the syscall. I know `nanosleep` has two arguments after checking its [man page](https://man7.org/linux/man-pages/man2/nanosleep.2.html) (all syscalls have a man page(2)).

After searching for the term `nanosleep` in LXR, I found that the syscall is defined in the [kernel/time/hrtimer.c](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1970) file.

```C
SYSCALL_DEFINE2(nanosleep, struct __kernel_timespec __user *, rqtp,
    struct __kernel_timespec __user *, rmtp)
{
  struct timespec64 tu;

  if (get_timespec64(&tu, rqtp))
    return -EFAULT;

  if (!timespec64_valid(&tu))
    return -EINVAL;

  current->restart_block.nanosleep.type = rmtp ? TT_NATIVE : TT_NONE;
  current->restart_block.nanosleep.rmtp = rmtp;
  return hrtimer_nanosleep(timespec64_to_ktime(tu), HRTIMER_MODE_REL,
         CLOCK_MONOTONIC);
}
```

Of course, every line of code has its reason to be, but I will highlight the call to `timespec64_to_ktime` which converts the input arguments of the syscall to the `ktime` struct that is used by the High Resolution Timers framework. Finally, it calls the `hrtimer_nanosleep` where all fun starts.

I will go function by function in the order they are called and explain the parts I consider relevant:

[hrtimer_nanosleep](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1935) function:

```c
long hrtimer_nanosleep(ktime_t rqtp, const enum hrtimer_mode mode, const clockid_t clockid)
{
  ...
  hrtimer_init_sleeper_on_stack(&t, clockid, mode);
  hrtimer_set_expires_range_ns(&t.timer, rqtp, slack);
  ret = do_nanosleep(&t, mode);
  ...
}
```

There are three relevant parts here:
- The HR Sleep timer initialization (we will check this with more detail)
- The expiration time for the initialized timer. Although that seems a simple task, there is a lot of logic under the hood. Because the Linux Kernel works at the hardware level. To convert human time to computer time it has to use some formulas that are based on the HZ constant that varies depending on the architecture. Also, the concept of [Jiffies](https://en.wikipedia.org/wiki/Jiffy_(time)) comes up. I will not go into more details, however [4] explains this part very well.
- Finally, it calls the `do_nanosleep` function that has the logic that sends a process to sleep.

The [`hrtimer_init_sleeper_on_stack`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L442) function (which in the end calls the [`__hrtimer_init_sleeper`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1821) function) allocates and initializes an HR sleep timer associated with the current process that is being executed.

The `function` attribute of the HR sleep timer is the callback function, which means that this `function` will be called after the HR sleep timer expires. In this case, the `function` attribute of the sleep timer is set to `hrtimer_wakeup` which we will see later.

```c
static void __hrtimer_init_sleeper(struct hrtimer_sleeper *sl,
          clockid_t clock_id, enum hrtimer_mode mode)
{
  ...
  __hrtimer_init(&scicil->timer, clock_id, mode);
  sl->timer.function = hrtimer_wakeup; // <<<<<< This function will be called after the timer expires
  sl->task = current;                  // <<<<<< Associates the timer with the current process
}
```

> In the Linux Kernel, the `current` variable is a pointer to the current process being executed (in our case the program that calls the `sleep` function).

Before continuing with the `do_nanosleep` function, I will make a parenthesis about the [`__hrtimer_init`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1393) function.

```c
static void __hrtimer_init(struct hrtimer *timer, clockid_t clock_id,
        enum hrtimer_mode mode)
{
  ...
  timerqueue_init(&timer->node);
}
```
I mentioned that HR Timers under the hood are implemented with a linked list and Red Black Tree. The call to [`timerqueue_init`](https://elixir.bootlin.com/linux/latest/source/include/linux/timerqueue.h#L43) functions is only allocating and initializing a Red-Black Tree Node, but not adding it to the tree yet.

Now let's see what happens inside the [`do_nanosleep`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1887) function.

I initially thought that the do/while loop iterated until the HR sleep timer expired, things happen in a differently.

```c
static int __sched do_nanosleep(struct hrtimer_sleeper *t, enum hrtimer_mode mode)
{
  struct restart_block *restart;

  do {
    set_current_state(TASK_INTERRUPTIBLE);   // <<<< This causes the process to go to a Sleeping state
    hrtimer_sleeper_start_expires(t, mode);

    if (likely(t->task))
      freezable_schedule();

    hrtimer_cancel(&t->timer);
    mode = HRTIMER_MODE_ABS;

  } while (t->task && !signal_pending(current));

  __set_current_state(TASK_RUNNING);

  if (!t->task)
    return 0;

  restart = &current->restart_block;
  if (restart->nanosleep.type != TT_NONE) {
    ktime_t rem = hrtimer_expires_remaining(&t->timer);
    struct timespec64 rmt;

    if (rem <= 0)
      return 0;
    rmt = ktime_to_timespec64(rem);

    return nanosleep_copyout(restart, &rmt);
  }
  return -ERESTART_RESTARTBLOCK;
}
```

As mentioned before, when the `sleep` function is called, it will go to a `Sleeping` state. We can see that happening in the line that calls the `set_current_state` function that changes the state of the `current` process to `TASK_INTERRUPTIBLE` (Sleeping).

The call to the [`hrtimer_sleeper_start_expires`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1804) function will call other functions until it calls the [`__hrtimer_start_range_ns`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1101) function which in turn will call the `enqueue_hrtimer`, it is in this part where the timer we initialized before is added to the Red-Black Tree structure so the timer can be processed later.

Finally, the `freezable_schedule` function indicates the process scheduler to schedule another process because the `current` process went to sleep and the execution of the process pauses here.

#### Waking Up The Process
So far we checked that the `nanosleep` implementation changes the state of the process to `TASK_INTERRUPTIBLE` and pauses the process execution.

Now that the process state is in `TASK_INTERRUPTIBLE` state, the scheduler will not consider the process for execution in the future, until the state of the process is set back to `TASK_RUNNING`.

We mentioned that the [Hardware Timer](#hardware-timer) will generate periodic interrupts so the Linux Kernel can handle them by calling the [`hrtimer_interrupt`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1633) function on each interruption (multiple times in a second). It is in this function where High Resolution Timers are processed by calling the [`__hrtimer_run_queues`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1569) function.

```c
static void __hrtimer_run_queues(struct hrtimer_cpu_base *cpu_base, ktime_t now,
         unsigned long flags, unsigned int active_mask)
{
  struct hrtimer_clock_base *base;
  unsigned int active = cpu_base->active_bases & active_mask;

  for_each_active_base(base, cpu_base, active) {
    struct timerqueue_node *node;
    ktime_t basenow;

    basenow = ktime_add(now, base->offset);

    while ((node = timerqueue_getnext(&base->active))) {
      struct hrtimer *timer;

      timer = container_of(node, struct hrtimer, node);
      if (basenow < hrtimer_get_softexpires_tv64(timer))
        break;

      __run_hrtimer(cpu_base, base, timer, &basenow, flags);
      if (active_mask == HRTIMER_ACTIVE_SOFT)
        hrtimer_sync_wait_running(cpu_base, flags);
    }
  }
}
```

The `__hrtimer_run_queues` function will iterate the timers in the Red Black Tree, something to note here is that it will break the while loop if the timer didn't expire yet (why do unnecessary iterations if the head of the linked list is the timer that will expire sooner?). But when a timer expires, it will call the [`__run_hrtimer`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1494) function, its implementation will call the callback function we set during HR sleep timer initialization.

```c
static void __run_hrtimer(struct hrtimer_cpu_base *cpu_base,
        struct hrtimer_clock_base *base,
        struct hrtimer *timer, ktime_t *now,
        unsigned long flags) __must_hold(&cpu_base->lock)
{
  ...
  fn = timer->function; // <<<<< This fn function is pointing to the hrtimer_wakeup function
  ...
  restart = fn(timer);
  ...
}
```

 The function that was set as the callback function during HR sleep timer initialization was the [`hrtimer_wakeup`](https://elixir.bootlin.com/linux/latest/source/kernel/time/hrtimer.c#L1783) function.

```c
static enum hrtimer_restart hrtimer_wakeup(struct hrtimer *timer)
{
  struct hrtimer_sleeper *t =
    container_of(timer, struct hrtimer_sleeper, timer);
  struct task_struct *task = t->task;

  t->task = NULL;
  if (task)
    wake_up_process(task);    // <<<<<< Wake up the process!!

  return HRTIMER_NORESTART;
}
```

As we can see this function will call the `wake_up_process` function sending the process (task) associated with the HR timer that was executed, that function among other things will set the process state to `TASK_RUNNING`.

Some CPU cycles later, the process scheduler will resume the execution of this process where it stopped (after the call to the `freezable_schedule` function). Then the rest of the `do_nanosleep` function will free memory, remove the timer from the Red Black Tree and continue with the execution.

### There are other alternatives to `nanosleep`
The `nanosleep` syscall is not the only syscall that can be used to sleep a process. For example Python's `time.sleep` function uses the `select` syscall under the hood, however, if you check the implementation of the [`do_select`](https://elixir.bootlin.com/linux/latest/source/fs/select.c#L476) function which in turn calls the [`schedule_hrtimeout_ran`](https://elixir.bootlin.com/linux/latest/source/fs/select.c#L236) function, you will notice that it calls the `schedule_hrtimeout_range` function which initializes, starts a High Resolution sleep timer, and tells the process scheduler to schedule another process (same logic as with `nanosleep`).

Python's sleep is one example, but other languages might be using different syscalls.

### Last Comments
Although calling the `sleep` function in our programs might be something trivial, all the mechanisms that live behind that simple behavior are amazing. When I started digging to understand what happens when you call a `sleep` function, I wouldn't have imagined how much I was going to learn.

In case there are parts of this post that you find incorrect, let me know by opening an issue in this blog's [Github repository](https://github.com/donkeysharp/donkeysharp.github.io). I will really appreciate it!.

## References
- [0] https://lwn.net/Articles/167897/
- [1] https://lwn.net/Articles/152436/
- [2] https://www.kernel.org/doc/html/latest/timers/hrtimers.html
- [3] https://www.kernel.org/doc/html/latest/timers/highres.html
- [4] https://www.youtube.com/watch?v=Puv4mW55bF8
