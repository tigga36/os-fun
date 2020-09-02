# What Cross Compilers are and Why you Need them in OS Development

In OS development, there are machines that use the OS (target), and machines that the OS was compiled in (host). The second, host machine could really be anything depending on preference. If you were to develop and compile files for an OS within that OS (ex: developing Mac OSX with a Mac OSX machine, otherwise known as bootstrapping), there wouldn't be any problems. Problems arrive if the host machine and target machine are different (such as developing linux on a mac, which is what I'm doing right now, despite using Vagrant to emulate an Ubuntu machine), causing unnecessary bugs and incompatibility issues.

This is where cross compilers come in. They are known as the first step to building an OS, as you essentially need the compiler to get any work done in the kernel. Cross compiling ensures that no characteristics of the host machine 'contaminates' the compiled binary, which is perhaps intended to be used for another type of machine.

## General Step for Creating a Cross Compiler

- Choose a target platform
- Install dependencies
- Download source code for compiler
- Builderino

## Choosing a Target Platflorm

For the time being, I'll choose i686-elf as the target platform

## Installing Dependencies

Directly install with sudo-apt (This is done in an Ubuntu-Xenial VM spun up by Vagrant, so they go directly into the Vagrantfile)

## Downloading Source Code for Compiler and Binutil

Both will be installed directly from the GNU distribution website.

### Versions

Apparently as long as GCC isn't older than 4.5 ish, there shouldn't be a huge problem. My VM's system GCC is 5.4, binutil 2.26, (apparently these are 2015 releases), so by hopefully these work as intended. In which case, GCC should match the major release, but be the newest minor release. As for binutils, the newest release would be best, but some GCC versions don't work well with some binutil versions. The safest option sounds like getting a binutils released around the same time. So, binutil 2.26 sounds like the solid option here. Now, we just download the appropriate verions from the distribution and load them into the codebase. Apparently in the case of linux, some verions ship GCCs and Binutils customized for linux. In my case,

## NOW WE BILD

With the required installations out of the way, we build the compiler. As for directory, we'll be building the compiler non-globally (for ourselves, for a lack of a better term). So it'll be a secondary compiler built inside a virtual machine. May feel convoluted, but this is probably the ring of permission I deserve at this point in time. The location will be in /vagrant/opt/gcc-5.4.0.

As for building, the build should be mainly done from the source tree folder, as in, the location where we placed our downloaded files, /vagrant/src/. Apparently the build can build can take a long time, and we should make use of cores. Does vagrant even let us do that? Idk so for the time being I'll just set it to 2, as the machine is dual core (macbook air, I know its a weak machine get off my back aight).

(After 2 full days of wrestling with bad memory and make: I went through crashing the computer, crashing the vm because of overusage of RAM. I raised the RAM and memory capacity of my vagrant VM just enough so that it doesn't crash the computer, and it also has enough memoery to actually build GCC. After building GCC for no apparent reason once (probalby for updating GCC to the newest version, which I didn't do, since they said the current 2015 versions for GCC and binutils suffice))
