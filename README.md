# Dockerd rootless example

An example setup for running `dockerd` in ["rootless mode"](https://docs.docker.com/engine/security/rootless/).

## Prerequisites

For running this inside a Linux VM you need to have the following tools installed:

- [Vagrant](https://www.vagrantup.com/) >= 2.2.19
- [Virtualbox](https://www.virtualbox.org/) >= 6.1.26

## Setup

The following command provisions the Linux VM:

```console
$ vagrant up
```

It'll download the "box" (the VM image the script is executed in) and then start provisioning the VM using the `install-rootless.sh` script.

Once it is done you can access the VM using the `vagrant` command:

```console
$ vagrant ssh
```

The user which has access to the rootless `dockerd` daemon is called `test`. You can switch to it using `sudo` and `su` _inside the VM_:

```console
$ sudo su - test
```

You should now be able to "see" the Docker daemon and run `docker` commands:

```console
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:97a379f4f88575512824f3b352bc03cd75e239179eea0fecc38e597b2209f49a
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
