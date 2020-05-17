---
title: "Analyzing a Video Looking for Possible Malware"
url: post/analyzing-evo-video
date: 2019-11-26T13:08:36-04:00
draft: false
---

Hello, during the months of October and November different social and political conflicts occurred in Bolivia, this entry is not so much to discuss the political issue, it will be a 100% technical entry but it is related to those events.

The previous week a large number of clients from a local ISP received an SMS with a link `bit.ly` to an MP4 video in Dropbox that was later deleted.

![](/img/vid-analysis-link-video.png)
<!-- video con el link del video original -->

This video went viral not only by SMS but on social networks and local media, it showed a recorded call in which a [local leader](https://www.eldeber.com.bo/157244_video-que-registra-una-llamada-entre-evo-morales-y-un-dirigente-fue-encontrado-en-el-desbloqueo-en-t) talks to [Evo Morales](https://es.wikipedia.org/wiki/Evo_Morales).

There were rumors that the video was malware or was used to track people who open it. I do not usually pay too much attention to those comments, but this time it interested me because days ago Facebook had reported a Stack Buffer Overflow security flaw that could possibly generate RCE in the WhatsApp application precisely with a malicious MP4 video! This is the [link](https://www.facebook.com/security/advisories/cve-2019-11931) of the security alert.

Well, I was very curious to see if there was indeed something malicious in that video or it was just spam. From the beginning I knew that I would learn several things because I had little idea of ​​how I could analyze whether the video was malicious. The video was sent to a public chat group I'm part of, and my friends [Gonzalo](https://twitter.com/lorddemon) y [Cristhian](https://twitter.com/crhystamil) and [Cristhian](https://twitter.com/crhystamil) told me to put an entry on my blog about my findings and in case thare are not findings I could speak about recording angles of the video. The rest of this entry will be about what I found and learned. Thanks for encouraging me to investigate guys, I had a lot of fun.

## The video
The video was just an mp4 file called evo-telefono.mp4 with this sha512:

```plaintext
a378c367e3c9a4be3ca639822fe79adf75aaa30ba25ca97ff8f6eb3945d36ed9eb160703ed611ecfe5fdc448c6a099e8af3a74a2c7078695db9c258a25800246
```

Firstly I verified that it is indeed an mp4 by viewing the magic numbers of the file. Generally the magic numbers of any file are the first bytes of it.

In the case of an mp4 the bytes should be: `00 00 00 (18 oo 1C) 66 74 79 70 6D 70 34 32and when running`:

```
$ hexdump -C evo-telefono.mp4 | head -n1
00000000  00 00 00 1c 66 74 79 70  6d 70 34 32 00 00 00 01  |....ftypmp42....|
```

It indeed has those magic numbers that identify an mp4 file. A simpler way to verify is using the command `file`:

```
$ file evo-telefono.mp4
evo-telefono.mp4: ISO Media, MP4 v2 [ISO 14496-14]
```

## First ideas
To see if I find something interesting I ran the command `strings` against the video and see if I found any interesting ASCII strings. As the vulnerability explains that the error lies in the metadata of the file, then I imagined that the structure was something internal as "key-value" all using ASCII, I discarded that assumption when I didn't find anything interesting using `strings`.

```
$ strings evo-telefono.mp4
```
The next idea was to use a tool that can view metadata of different formats called `mediainfo` and `mediainfo-gui`. For this first stage of the analysis I used `mediainfo` because I didn't understand very well how it was presented with `mediainfo-gui`, but this gui later was much more useful.

Using `mediainfo` against the video `evo-telefono.mp4` I got the following output, I will put only certain parts but leave this [gist](https://gist.github.com/donkeysharp/ecdfb633e2a75844019985cc61904c3c) with full command output.

```
$ mediainfo evo-telefono.mp4
General
Complete name                            : evo-telefono.mp4
Format                                   : MPEG-4
Format profile                           : Base Media / Version 2
Codec ID                                 : mp42 (isom/mp41/mp42)
File size                                : 6.41 MiB
Duration                                 : 1 min 2 s
Overall bit rate                         : 857 kb/s
Encoded date                             : UTC 2019-11-21 12:31:56
Tagged date                              : UTC 2019-11-21 12:31:59

...
```

Visually that information is key-value but most of those strings were not found when I used `strings` which leads me to the conclusion that the format is mostly binary and that the numbers in this output are not represented as an ASCII string, but in bytes similar to an IP or TCP packet.

> **Note:** An IP packet is binary in the sense that the IP and other flags are not presented as ASCII text, but encapsulated in bytes. For example the ip 10.0.1.11 (9 bytes in ASCII) is represented in 4 bytes as 0A 00 01 0B

At this point I felt like I was going nowhere. The next thing I did is search if there was already an exploit or tutorial on how to exploit this CVE and effectively with the help of Google, I came to this repository in [Github](https://github.com/kasif-dekel/whatsapp-rce-patched).

This repo had an mp4 called `poc.mp4` which in theory exploited this vulnerability and next to this file the WhatsApp dynamic library` libwhatsapp.so` and a C program that invokes this library dynamically using `dlfcn.h` (I hope I can make a post about dlfcn.h in the future, really interesting). The most important thing about this repository is that it has a sample mp4 file that causes this error, it helped me a lot.

The first thing I did was run `mediainfo` again `poc.mp4` and see the differences between `evo-telefono.mp4` and `poc.mp4`, sadly it was more frustrating since the only thing different was a new tag called `com.android.version` with the value of `9` in ASCII and well, I was out of ideas.

At the beginning I thought that next to this tag looking at the hexadecimal, maybe there was a shellcode, looking for common opcodes and that, but I really felt that the strategy I was using was quite "naive" and I was not understanding the MP4 format as such and well, I think that was the next step.

Most files have a specification of how they are structured, either in plain text in a format e.g. json or xml or in binary e.g. MP4. I Googled for the spec files, I gave a super fast read to what I found to see if it mentioned things like bytes and things like that and I didn't find one. I paused this analysis for a day to rest.

## Understanding the MP4 format and vulnerability
Hours after I paused, my friend [Elvin](https://twitter.com/ElvinMollinedo) sent this [link from Hack A Day](https://hackaday.com/2019/11/22/this-week-in-security-more-whatsapp-nextcry-hover-to-crash-and-android-permissions-bypass/) which gives a summary of the vulnerability and how it is being exploited, thank you very much for sharing, it was one of the most important resources for this investigation. To be honest, when I read it I did not understand certain details that were just the most important, I was still not understanding the structure of a mp4 file.

**From this point** all the steps I follow are only with the file `poc.mp4` and in the end I will apply what I learned to `evo-telefono.mp4`.

The first thing I did was try to reproduce the only step he mentions in the Hack A Day post with the `AtomicParsley` tool in `poc.mp4`. When executing it I got a `Segmentation Fault` but the same with `evo-telefono.mp4`, apparently it is more an error of the tool that is already discontinued.

```
$ AtomicParsley poc.mp4 -T

Atom ftyp @ 0 of size: 24, ends @ 24
Atom moov @ 24 of size: 794, ends @ 818
     Atom mvhd @ 32 of size: 108, ends @ 140
     Atom meta @ 140 of size: 117, ends @ 257
         Atom  @ 152 of size: 6943, ends @ 7095					 ~

 ~ denotes an unknown atom
------------------------------------------------------
Total size: 7095 bytes; 4 atoms total.
Media data: 0 bytes; 7095 bytes all other atoms (100.000% atom overhead).
Total free atom space: 0 bytes; 0.000% waste.
------------------------------------------------------
AtomicParsley version: 0.9.6 (utf8)
------------------------------------------------------
Segmentation fault
```

As you can see in the output a lot of info that I did not understand, but something that they did mention in the Hack A Day post is the position in bytes and that MP4 is a hierarchical structure and the basic structure of MP4 is the "Atom" (there are different types of atoms). Later I will talk in more detail about the Atoms.

Each atom has a header that indicates the size of the atom. Being a hierarchical structure an atom can contain other atoms inside. As such, the size of a parent atom is the total of all the bytes of the child atoms and what is highlighted and mentioned in the post is the following:

The `meta` atom has a size of 117 bytes but inside this atom there is an unnamed child atom that has a size of 6943 bytes that is greater than the 117 bytes of the father and well that gives a clue.

```
         Atom  @ 152 of size: 6943, ends @ 7095 				 ~
```

In the Hack A Day post it later refers to 33 bytes and 1.6GB of the size of the atom and then I got lost again and that was effectively the key to understanding the error.

The next thing to do &mdash; I'd already procrastinated it enough &mdash; was to read the specs from an MP4 file. From the files I got, none were at the level I wanted, that is, at the byte level. Luckily, once again the Hack A Day post refers to two documents: the specification on the [Apple Developers site](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/Metadata/Metadata.html) and another [slightly more elaborate specification](http://xhelmboyx.tripod.com/formats/mp4-layout.txt) and this is when this error was fully understood.

## The MP4 format
As a super short summary after reading the specification it can be said that MP4 is hierarchically organized in blocks called Atoms (which I mentioned above) and each Atom has an 8-byte header, 4 bytes define the size of the Atom and the other 4 bytes (generally in ASCII) represent the type of the Atom.

Now there are several types of Atoms but the ones shown in this post are the following:

- `moov` which represents "Movie Data" and may contain other Atoms inside. Basically the content of this atom is information from the movie e.g. when it was created, duration, etc.
- `meta` another atom that encapsulates information of the Metadata.
- `hdlr` an atom that is considered the handler and comes inside the `meta` atom, this atom defines the whole structure that all the metadata will have inside the `meta` atom.

The following image shows a graphic representation of the box-shaped atoms:

![](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/art/metadata_atom.jpg)

But how can this format be understood at a binary level? This part took a bit of time but in the end using `mediainfo-gui` and a hexadecimal editor was much simpler.

An atom has an 8-byte header where the first 4 bytes indicate the size of the atom and the following 4 bytes the type of atom e.g. `moov`,` meta`, `hdlr` among others. Then comes N bytes which are the content of the atom, where N is the size of the atom specified in the first 4 bytes subtracting 8 bytes (the header).

An example:

A 794-byte atom of type `moov` would be represented as:

```
00 00 03 1A 6D 6F 6F 76 XX XX XX ... 786 bytes ... XX XX
```

According to the specification the first 4 bytes are the size, the next 4 bytes are the type of atom and the rest is the body.

The first 4 bytes can be represented as `0x0000031A` or` 0x31A` which in decimal is `794`.

The next 4 bytes indicate the type of atom that is ASCII text, so it is only to convert the following bytes to its character in ASCII and we will have:
```
6D -> m
6F -> o
6F -> o
76 -> v
```

Now the content of this atom (the remaining 786 bytes) can be other atoms identified in the same way and based on the specification of the MP4 format.

> There are special cases of some Atoms that have a special format. An example of these special atoms is that after the header we do not directly define another atom, it is possible that some bytes are reserved for some purpose (flags, etc.) and after these reserved bytes it is then possible to define child atoms. **Remember** this paragraph as you will see is the key to success.

Continuing with examples in `poc.mp4`, there is an atom called `mdta` which is basically the key name in the metadata (this atom has the key `com.android.version` that I mentioned above). Like another atom, it is represented with an 8-byte header and then the content:

```
00 00 00 1B 6D 64 74 61 63 6F 6D 2E 61 6E 64 72 6F 69 64 2E 76 65 72 73 69 6F 6E
```

Where:
- `0x0000001B` represents the size that in decimal is 27 bytes
- `6D 64 74 61` represents in ASCII` mdta` the type of the atom
- `63 6F 6D 2E 61 6E 64 72 6F 69 64 2E 76 65 72 73 69 6F 6E` converting to ASCII represents` com.android.version`

In order not to make this post too long, I have created a video where I show in more detail how to interpret this format at a hexadecimal level using `mediainfo-gui` (it was originally recorded in Spanish).

{{< youtube JbvDRA7RGxs >}}

### Understanding the bug
In the previous video it is shown how to understand and navigate through the different atoms using `mediainfo-gui` atoms viewer and navigating it in a hexadecimal level. In this section, using the knowledge acquired so far, we will see how the bug reported in the CVE can be used.

> Part of [CVE-2019-11931](https://www.facebook.com/security/advisories/cve-2019-11931):
> The issue was present in parsing the elementary stream metadata of an MP4 file and could result in a DoS or RCE

This CVE and the way to cause the overflow just says that it is in the metadata, that is, in the Atom `meta`. In the Hack A Day post, it refers to two specifications of the mp4 format. The Apple Developers link indicates that after defining the `meta` type atom as a child, an `hdlrf` type atom should be defined and if we see in the hexadecimal, that exactly happens. From the `8C` offset as shown in the following images .

![](/img/vid-analysis-mediainfo-gui.png)
<!-- Imagen de mediainfo resaltando el atom meta -->

![](/img/vid-analysis-atom-meta-hex.png)
<!-- imagen de ghex mostrando lo mismo en hexdecimal -->

```
header size   meta type     header size   hdlr type
-----------   -----------   -----------  -----------
00 00 00 75   6d 65 74 61   00 00 00 21  68 64 6c 72 ...
0x00000075    meta          0x00000021   hdlr
0x75 o 117    meta          0x21 o 33    hdlr
```

What you see in `mediainfo-gui` and in the hexadecimal representation makes a lot of sense, but if we remember the output of the `AtomicParsley` application, the `hdlr` atom that is actually defined does not appear at any time and instead shows an error for an *un-named* atom that has 6943 bytes in size (greater than 117 of its parent `meta` atom).
```
$ AtomicParsley poc.mp4 -T

Atom ftyp @ 0 of size: 24, ends @ 24
Atom moov @ 24 of size: 794, ends @ 818
     Atom mvhd @ 32 of size: 108, ends @ 140
     Atom meta @ 140 of size: 117, ends @ 257
         Atom  @ 152 of size: 6943, ends @ 7095	<<<<<< atom without name

 ~ denotes an unknown atom
------------------------------------------------------
Total size: 7095 bytes; 4 atoms total.
Media data: 0 bytes; 7095 bytes all other atoms (100.000% atom overhead).
Total free atom space: 0 bytes; 0.000% waste.
------------------------------------------------------
AtomicParsley version: 0.9.6 (utf8)
------------------------------------------------------
Segmentation fault
```

All the atoms in the output show their type `ftyp`, `moov`, `mvhd`,  `meta` and within `meta` this unknown atom with a size that is basically the rest of the size of `poc.mp4` which it weighs 7095 bytes, since if you count by adding the size of the atom `ftyp` (24), `mvhd` (108), the header of `meta` (8) results in `24 + 108 + 8 = 148` but `7095 - 148 = 6947` which are 4 extra bytes from the 6943 given in the `AtomicParsley` output.

**What are these 4 bytes?**
It is seen that in `mediainfo-gui` everything is shown well, as if nothing had happened and the format is correct. However, in `AtomicParsley` it shows an atom without any type and we have 4 extra bytes.

What happens and I managed to deduce is the following: if we see the file type of `poc.mp4` using the command `file` it is seen to be `ISO Media, MP4 v2 [ISO 14496-14]`. It happens that the mp4 format is based on the `ISO 14496-14` standard, which is the continuation of another standard called `ISO 14496-12` and the most interesting thing comes here: in the Hack A Day post, it mention two specification links: from [Apple Developers](https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/Metadata/Metadata.html) and one [a little more elaborate](http://xhelmboyx.tripod.com/formats/mp4-layout.txt). In the second link it clearly indicates that it is the specification of the `ISO / IEC 14496-12` standard and this is exactly where it indicates that the atom `meta` after the 8 byte header has 4 bytes reserved (3 for flags and 1 for version) and after these 4 bytes you can just define other child atoms.

If so, and re-analyzing the hexadecimal, we have the following:

```
                            4 bytes
header size   meta type     reservados   header size  type inválido
-----------   -----------   -----------  -----------  -----------
00 00 00 75   6d 65 74 61   00 00 00 21  68 64 6c 72  00 00 00 00 ...
```

Knowing that, the parser confuses those 4 bytes and makes the definition of the child atom header to be `68 64 6c 72 00 00 00 00` where `0x68646c72` is the size and `00 00 00 00` is the type that in ASCII is is not valid name for MP4 and that is exactly why the `AtomicParsley` application failed. Now if you convert `0x68646c72` to decimal, you get the value of 1751411826, that is, the size of that unknown atom will be 1.6GB (same as in the Hack A Day post).

I was now able to confidently reproduce the `evo-telefono.mp4` file.

What I deduce is this: the `libwhatsapp.so` library ([repo](https://github.com/kasif-dekel/whatsapp-rce-patched)) was possibly complying with the `ISO 14496-12` standard and not the `ISO 14496-14` or it was simply a development error as in the current WhatsApp update it does not happen. Now related to the `AtomicParsley` application, it is very likely that the same will happen since this one had problems with that unknown atom.

## Analyzing the file `evo-telefono.mp4`
Up to this point I was happy because of how much I had learned, but the main objective was to analyze if this file had something malicious specifically by this CVE.

Finally I can say that **NO**, it does not have something malicius (at least not for this CVE).

The reasons are as follows: in order to cause this error, you need to have defined the `meta` atom, which is not defined within any atom in the `evo-telefono.mp4` video. Anyway it is the first time that I analyze a file at this level and well, in some chat groups they mentioned Pegasus and that, it would be worth to give it a check.

## Final comments
Seriously it was a good experience when it came to learning and seeing these type of attack vectors that take advantage of this kind of details.

Another thing learned that for this type of analysis, just like when analyzing network protocols it is necessary to read the RFC, in the case of formats it is necessary to read the specification of the format of some file. There is an ezine called `Paged Out` which in one of its sections talks about techniques of reversing file formats, I recommend it. [Link] (https://pagedout.institute/download/PagedOut_001_beta1.pdf).

Finally I thank Elvin again for sharing that Hack A Day post that was key to this analysis and Gonzalo and Cris for encouraging me to do it.
