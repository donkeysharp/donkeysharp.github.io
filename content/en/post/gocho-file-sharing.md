---
title: "Gocho, Sharing files in a local network"
date: 2018-03-29T22:22:46-04:00
draft: false
---

Hey,during my free time I was working a side project called [Gocho](https://github.com/donkeysharp/gocho). This application allows the user to share files in a local network e.g. home network, work, etc. with the difference that it will auto-discover other nodes. In this post I will explain what this application is all about, why I wrote it and some challenges that came up duting the development.

![](/img/gocho-dashboard.gif)
<center><a href="/img/gocho-dashboard.gif" target="_blank">View</a></center>

## Why I wrote this app?
First I wanted to share a directory in a local network without the need of others having to ask for my local ip address or the port where I published the files. Also I wanted something that is simple to execute in most common operating systems (Windows, OSX and GNU/Linux) without the need to install some dependencies.

When I start a project like this I always want to learn something new. In this case I wanted to learn [Go](https://golang.org/) since last year (2017). Although I did one thing or another with this language they were just small experiments. I wrote a small project called [Golondrina](https://github.com/donkeysharp/golondrina); [EazyPanel](https://github.com/donkeysharp/eazy-panel)), and this idea seemed to be a good use case to use this programming language (I will elaborate on that below).

## Why Go?
<!-- Si alguien ya ejecutó la aplicación es fácil notar que no es algo de otro mundo. Gocho podría haber sido desarrollado en otros lenguajes como: C/C++, Python, Ruby, Java, CSharp, etc. pero tenía algunas observaciones preliminares: -->

If some of you already tested the application it's easy to see that it's not something from another world. Gocho could have been developed in other programming laguages such as C/C++, Python, Ruby, Java, CSharp, etc. but I had some some observations of those otions:

* Python/Ruby - It's important to have the installer installed by default and Windows does not have it.
* Java/CSharp - it's important to have the virtual machines already installed in the operating system (JVM or NetCore). It will not always be the case that those are installed by default.
* C/C++ - It would be the obvious choice, but found some observations: first is that by default these programming languages are dynamically linked, which could cause in some cases the need to install the libraries required  (unless I use the static flag during compilation of course) and the second problem is that even I can read C/C++ I don't feel ready enough to start writing something like this.
* Go - It is compiled statically by default (everything in a single binary) and the final result does not require an interpreter, virtual machine or similar to be installed previously.

With that list &mdash;a little bit biased :wink:&mdash; Go matches with the needs I have.

Something else about Go is the simplicity I have to create binaries for different platforms. For instance Gocho is available for different platforms without extra complications. [Releases Gocho](https://github.com/donkeysharp/gocho/releases)

## Some issues I found

### Issue #1: Sharing files
In the company where I work there a big diversity in terms of operating systems. Some use Windows, OSX and others GNU/Linux. In order to share files, there is a "Shared folder" that I couldn't make it to work same as others (I use GNU/Linux). When I tried to accessI got some errors to instert domain and credentials; even if I input the correct values &mdash;that were supposed to be the correct ones&mdash; I wasn't able to access shared files.

Some guys share information such as videos, courses, etc. by setting up a web server `httpd` in their local machines or in my case I just started `python -m SimpleHTTPServer` in the directory that I wanted to share. I found an issue with `SimpleHTTPServer`, with few people trying to download the same file, this server only could handle one download at a time.

My next try was to bring up something better that `SimpleHTTPServer` without the need to setup something big such as `httpd`. I had the luck to see a code snippet in Go's documentation for the `net/http` module that starts a file sharing server that could support multiple downloads at the same time. Lucky me!

{{< highlight go >}}
package main

import (
    "log"
    "net/http"
)

func main() {
    // Simple static webserver:
    directory := "some/directory"
    log.Fatal(http.ListenAndServe(":8080", http.FileServer(http.Dir("/home/myuser/some/directory"))))
}
{{< /highlight >}}

I just had to compile this code; move the final binary to some directory in the `PATH` and voila! I had a simple solution that could handle more concurrent download without the need to mount a complex service.

So far I just have a small binary that allows me to share a directory and that it can handle multiple concurrent downloads &mdash;something simpler to setup compared to a service such as `httpd` or `nginx` but better than `SimpleHTTPServer`.

If we make numbers, just compiling this binary for different operating systems would have been enough. But I wanted to go further.

### Issue #2: Where are the shared files?
Another thing I noticedis that everytime a user shares something in the local network, user must communicate (somehow) other users how to access the resources this user is sharing. The most common way is by sending to a chat the IP address and the port where shared files are.

Since the beginning I'm thinking this application will only work on a local network and something that quickly came up to my mind was these old LAN games such as StarCraft. When you played StarCraft a user created a game and other players could join the game without knowing the IP address of the machine that created the game. The game automatically shows all the games available in the network and a user can connect to it automatically.

Doing some research about how this games could detect all avaialable games in a network without the need to specify an IP address, took me to the concept of [multicast](https://en.wikipedia.org/wiki/Multicast).

In small words, Multicast is a network feature that allows a computer sending information to the network so other nodes in the network can receive these information.

For instance, if I want to send a "Hello world" to other computers that are interested in receiving thismessage and wihtout me having to know which computers, the idea is the next:

* *My Computer*: Send an UDP datagram with a "Hello world" mesage to  the [reserved Multicast IP range](https://en.wikipedia.org/wiki/Multicast_address#IPv4) e.g. 239.6.6.6:1234
* *Interested computer 1*: Listen for UDP datagrams in 239.6.6.6:1234
* *Interested computer 2*: Listen for UDP datagrams in 239.6.6.6:1234
* *Interested computer N*: Listen for UDP datagrams in 239.6.6.6:1234

This way Multicast allows whoever computer that wants to share something, it only needs its own information (identifier, IP address, port, etc) via Multicast and interested machines will be able to get this information.

Knowing this, Gocho in addition to  just sharing a directory, it will be able to meet other Gocho nodes that are currently sharing something.

Now regarding implementation, we can check some code snippets I used for Gocho.

[pkg/node/net.go](https://github.com/donkeysharp/gocho/blob/master/pkg/node/net.go)

The `announceNode` function sends a Multicast packet.

{{< highlight go >}}
func announceNode(nodeInfo *NodeInfo) {
    address, err := net.ResolveUDPAddr("udp", MULTICAST_ADDRESS)
    // error handling

    conn, err := net.DialUDP("udp", nil, address)
    // error handling

    for {
        ...
        conn.Write([]byte(message))
        time.Sleep(ANNOUNCE_INTERVAL_SEC * time.Second)
    }
}
{{< /highlight >}}

The `listenForNodes` function will listen for Multicast messages.

{{< highlight go >}}
func listenForNodes(nodeList *list.List) {
    address, err := net.ResolveUDPAddr("udp", MULTICAST_ADDRESS)
    // error handling
    conn, err := net.ListenMulticastUDP("udp", nil, address)
    // error handling

    conn.SetReadBuffer(MULTICAST_BUFFER_SIZE)

    for {
        packet := make([]byte, MULTICAST_BUFFER_SIZE)
        size, udpAddr, err := conn.ReadFromUDP(packet)
        ...
    }
}
{{< /highlight >}}

Therefore most of the "magic" that Gocho has relies on Multicast. With Multicast a computer can announce itself and at the same time discover other nodes.

### Issue #3: Message format
Now that we can communicate between nodes, I knew that was convenient to identify the packets that Gocho sends to other nodes. Basically the packet (this initial version) must follow next format:

1. The first 4 bytes must be `0x60`, `0x0d`, `0xf0`, `0x0d` or `0x600df00d` (Good Food), which is the header tha identifies a Gocho message.
2. The next byte specifies the command, currently there is only one command which is `0x01` that specifies that a node is announcing. The information of the node is in the payload.
3. Finally the rest of the content is the payload. For this purpose I decided to use the JSON format.

This is the hexadecimal representation of a message from a node that is announcing itself:

```
00000000  60 0d f0 0d 01 7b 22 6e  6f 64 65 49 64 22 3a 22  |`....{"nodeId":"|
00000010  6e 6f 64 6f 2d 73 65 72  67 69 6f 22 2c 22 69 70  |nodo-sergio","ip|
00000020  41 64 64 72 65 73 73 22  3a 22 22 2c 22 77 65 62  |Address":"","web|
00000030  50 6f 72 74 22 3a 22 35  30 30 30 22 7d           |Port":"5000"}|
```

I decided to use this kind of format to reduce the usage of bytes as much as possible. In fact, if it wouldn't use JSON format more bytes would be saved.

In the future it is possible that more commands exists other than the announce node command (`0x01`). That's the reason one byte is reserved for that.

## Application design
<!-- Esta sección habla un poco más de la implementación ya habiendo conocido los problemas mencionados arriba. Para poder seguir esta sección hago referencia al [código fuente](https://github.com/donkeysharp/gocho) de la aplicación. -->

Now that we now the issues and solutions that were given, this section describes a bit more some implementation details.

### Code structure
The code structure of this project is based on this [article](https://peter.bourgon.org/go-best-practices-2016/#repository-structure) that shows a nice code structure for Go projects. This structure is used in different projects such as [Kubernetes](https://github.com/kubernetes/kubernetes) or [Docker](https://github.com/moby/moby).

This project includes a `Makefile` that has all the required steps to build and develop the project and also the multi-architecture binary build process.

### Service components
In the previous section I mentioned the code structure that was used. This section I will focus on the components inside the directory `pkg`, specially in `pkg/node`.

Component  | Description
--- | ---
`pkg/info` | Application information such as name and versoin.
`pkg/cmds` | All the CLI logic, flags, options, etc e.g. `gocho start [options]` or `gocho configure`.
`pkg/config` | All the configuration logic such as default values or loading setings from `.gocho.conf` file are defined in this component.
<!-- `pkg/node` | La lógica principal de la aplicación radica en este directorio. El cómo se tiene un dashboard web embebido; el formato de los paquetes; el mecanismo de auto-discovery (multicast) y el índice de archivos que muestra el contenido del directorio compartido. -->
`pkg/node` | Application's main logic is here. Things such as the embeded dashboard; the packet's format; the auto-discovery feature using Multicast and the index of files in the shared directory.

### A bit about some data structure and logic used
Application needs to store the information of other nodes, for this purpose I decided to use a linked list due to its simplicity to delete or add elements.

As more nodes are getting announced in a network, it is possible that some parts of the code (from any node) will execute some parts of the code at the same time. In order to avoid concurrency problems: mainly in the linked list that stores nodes' information, I used a [Mutex](https://golang.org/pkg/sync/#Mutex) that will help us manage this kind of behaviors that could lead us to unexpected results.

Something important here is that there are timeouts set by default that constantly check the linked list. Basically these timeouts allow us to free resources when a node stops announcing itself after some time.

### The Dashboard
For the dashboar ddevelopment I only used [React](https://reactjs.org/). Maybe some of you will make question about why I didn't use Redux or React-Router? The answer is simple, as the final bundle with the required static files will be embedded in the binary, it will be better to have it as reduced and simple as possible.

All the components and code for the UI are in `ui` directory. The structure used for this project is the one that is created by default using [Create React App](https://github.com/facebook/create-react-app).

The same for styles, I could have used some CSS processor such as SASS, but I decided to keep things simple. All styles are in this [file](https://github.com/donkeysharp/gocho/blob/master/ui/src/App.css) which is ~184 lines of code.

To generate the javascript bundle just run the next command

```bash
$ make dist
```

The previous command uses the Creat React App scripts to generate the final bundle and embed it into the binary. I make use of [Go Generate](https://blog.golang.org/generate).

[This files](https://github.com/donkeysharp/gocho/blob/master/cmd/gocho/gocho.go) has a comment:

{{< highlight go >}}
package main

//go:generate go-bindata -o ../../assets/assets_gen.go -pkg assets ../../ui/build/...

import (
    "github.com/donkeysharp/gocho/pkg/cmds"
    "os"
)
...
{{< /highlight >}}

That specifies where the bundle is and that will be embedded in to binary.

### The shared files web index
This is one of the features where I got more fund. As I mentioned on *Issye #1*, Go shows an example to share a directory via web. The problem with that web index does not have any styles, cannot be extended and the `..` directory does not exist.

In order to customize this existing code I used the [Interceptor Pattern](https://en.wikipedia.org/wiki/Interceptor_pattern) and a custom middleware that adds the icons, custom HTML code and the `..` directory to go up one level.

All the logic used to customize `net/http.FileServer` is in this file [index.go](https://github.com/donkeysharp/gocho/blob/master/pkg/node/index.go).


## Final comments
There are some many things that I wish to improve in [Gocho](https://github.com/donkeysharp/gocho). Because it is an Open Source project feel free to open an issue or contribute some bug fix or feature.
