---
title: "Booting Raspberry Pi 3 Model B from SSD"
url: "boot-rpi-3-model-b-from-ssd"
date: 2026-01-18T08:11:13-04:00
tags: ["rpi", "homelab", "linux"]
draft: false
---

![alt text](/img/rpi-homelab.jpeg)

Hey everyone! In this post I'm going to share my experience of USB booting the Raspberry Pi 3 Model B from an SSD. Although it is something I did almost one year ago, I wanted to share it... sorry for the 1 year delay xD!

> Probably there might be something I missed on my solution, so any feedback is really appreciated!

Before the pandemic started, a friend of mine sold me 4 Raspberry Pi 3 Model B and one Raspberry Pi 3 Model B+. I used them for an electronics + home automation project I no longer need anymore, so I decided to repurpose them to something new, a new project I started working on for which I will make another blog entry.

This time, as I was not going to use the RPIs for electronics, instead something that will require more disk usage, I wanted to try something I personally hadn't tried before. I wanted to boot the RPIs from an SSD. Instead of spending money on new reliable, fast SD cards, I decided to use some spare SSDs I had instead. This is definitely something that was done before, but in my case there were some nuances that took me some days to realize how to fix them, and I wanted to share that experience with you.

### What I used
For this experiment I used:

- 4 RPI 3 Model B
- 1 RPI 3 Model B+
- 5 Power supplies with the proper voltage and amps
- 5 Solid State Drives
- 5 USB to Sata adapters

## Booting from SSD
There are multiple blog posts, forum entries and now LLMs that explain how to boot a RPI from an SSD (I added references I used in the references section below). In summary the steps required for RPI 3 Model B to USB boot from SSD are the next:

- Using an SD card with RaspberryPI OS installed, run a full upgrade:
  ```sh
  sudo apt update -y && sudo apt full-upgrade -y
  ```
- The following command will give two possible results depending on whether USB boot is enabled or not:
  ```sh
  vcgencmd otp_dump | grep 17
  17:1020000a <<<< it means USB boot is disabled
  17:3020000a <<<< it means USB boot is enabled
  ```
- In case it is disabled, the way to enable it is by adding the following lines to the `/boot/firmware/config.txt`. Some tutorials mention the `/boot/config.txt` but those are outdated.
  ```sh
  program_usb_boot_mode=1
  program_usb_boot_timeout=1
  ```
- Finally, clone the content of the SD card that has RaspberryPI OS to the SSD, you can do that with dd:
  ```sh
  # /dev/mmcblk0 is the SD card in my case
  # /dev/sdb is the SSD connected via USB
  dd if=/dev/mmcblk0 of=/dev/sdb status=progress
  ```
- Then remove the SD card from the RPI, connect the SSD via USB and reboot.
- Congrats! You booted your RPI from USB and an SSD. Now you can resize and stuff.

That's the result I wished I had, but no, it didn't work for 4 of my 5 RaspberryPIs. Let me tell you how I fixed-ish it.

## The difference between RPI3 model B and RPI3 model B+
I executed the previous steps first (by coincidence on the RPI 3 **Model B+**). And it worked like a charm. Then for the next RPIs 3 Model B (not B+) it didn't work, I tried all of the 4 RPIs with the same result. I made sure I added the `program_usb_boot_timeout=1` setting to the `/boot/firmware/config.txt` file to increase the wait for RPI to detect the disk, even with that verification it didn't work. No USB boot for the RPIs 3 Model B.

At that point, I got to the conclusion that at least in terms of booting, the RPI 3 Model B and RPI 3 Model B+ have differences.

### My Solution (a fluke)
After trying multiple combinations that didn't work, it booted! I checked in the terminal and indeed, it booted from SSD. I executed some IO speed tests to make sure it was indeed using the SSD. It finally worked!

The new problem was I didn't add any new configuration change xD, so I was very confused on why it worked. And I noticed that this time I forgot to remove the SD card. Both SD and USB SSD were connected.

My hypothesis was that for RPI 3 Model B, an SD card is still required to boot, no matter if the operating system is installed on a USB SSD.

To finally verify that hypothesis, I formatted the SD card and just copied the content of the `/boot/` directory from the SSD, actually they **must** be the same.

Voila! It booted again!

With that test, I was sure that the **RPI 3 Model B requires an SD card to boot no matter where the OS is located**.

I used the SD cards from my old project, formatted them and copied the content of `/boot/firmware` from each SSD and it worked fine.

It is important **not** to copy the content of the `/boot/firmware` directory from **one SSD to all the SD cards**, as each SSD has a different UUID specified in the `/boot/firmware/cmdline.txt` file. Copy from each SSD or make sure the `/boot/firmware/cmdline.txt` has the proper values for the disk UUID.

One example of the `cmdline.txt`
```
console=serial0,115200 console=tty1 root=PARTUUID=e000a75d-02 rootfstype=ext4 fsck.repair=yes rootwait cfg80211.ieee80211_regdom=US cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```

### Upgrading the operating system
All the steps that I mentioned before happened when the latest RaspberryPI OS was based on Debian 12. Now the latest version of the RaspberryPI OS was released based on Debian 13, I decided that instead of formatting and doing the same process from scratch, I will follow the steps to do a RaspberryPI OS major upgrade.

These are the steps I follow for this matter:

- Edit `/etc/apt/sources.list` and `/etc/apt/sources.list.d/raspi.list` and change from `bookworm` to `trixie`.
- Run `apt update` to refresh the package indexes
- Run `apt install -y apt dpkg` to install the latest version of the package manager.
- Run `apt upgrade --without-new-pkgs` to install latest version without installing new dependencies. Make sure everything is fine.
- Finally `apt full-upgrade`
- Reboot

That would be enough on any setup (it works on the **RPI 3 Model B+**), but in this case as we boot from the SD card first and not the SSD, we will need to follow some extra steps.

Let's recall some Linux theory: The Linux kernel image is located at the `/boot` directory, but in our case the RPI boots from SD. We still have the boot content from the previous installation. After the upgrade when I rebooted, the kernel was still `6.1` and not `6.12` which is the one that comes with Debian 13.

In order to have the upgrade 100% ready, I had to repeat the previous steps I did to make the RPI boot from SSD.
- Mount the SD card `mount /dev/mmcblk0p1 /mnt/sdboot/`,
- Copy `/boot/firmware` from SSD to the SD card: `cp -r /boot/firmware/* /mnt/sdboot/`
- Reboot

After I followed those steps, I was able to have the upgrade 100% functional.

### If you want to use containers
In case you want to use containers or a container orchestrator such as K3S, make sure that the fields `cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory` are set in the `/boot/firmware/cmdline.txt`

## References
- [https://forums.raspberrypi.com/viewtopic.php?t=359795](https://forums.raspberrypi.com/viewtopic.php?t=359795)
- [https://www.makeuseof.com/how-to-boot-raspberry-pi-ssd-permanent-storage/](https://www.makeuseof.com/how-to-boot-raspberry-pi-ssd-permanent-storage/)
- [https://pysselilivet.blogspot.com/2020/10/raspberry-pi-1-2-3-4-usb-ssd-boot.html](https://pysselilivet.blogspot.com/2020/10/raspberry-pi-1-2-3-4-usb-ssd-boot.html)
