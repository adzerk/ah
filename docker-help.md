# Docker 2021

To build `ah` using these tools have a recent version of docker. I have the following version.

```
Docker version 20.10.1, build 831ebea
```

### Notes

Currently this only works on linux, Ubuntu 20.04. An alternative is to modify the `FROM` line of the dockerfile to build for a different version of linux. This has not been tested.

If you are on MAC you could modify this to build, and then link volumes as necessary.


### Steps

```
1. chmod +x docker-run
1. chmod +x docker-build
1. ./docker-build
1. ./docker-run
1. docker $ cp ah_build.zip local/
1. <<quit the container>>
```

At this point `ah_build.zip` is sitting in your current directory. This file contains the output of having run `make PREFIX=/workdir/installed install` inside the container.

You can `unzip` this file and then place the results in each of the specified directories on your local machine, or operate it in a more suitable fashion.



