# OS development project

A beginner project on building an OS from scratch to familiarize myself with binary concepts. The hope is it'll help with binary exploitation in CTF.

Progression steps and code are heavily influenced, if not basically completely taken from *Writing a Simple Operating System from Scratch*, by Nick Blundell (or, as far as it was written before being publically released). Almost all of the code are mostly copied from the contents of the textbook, as are the CLI tools used throughout, up to the point of getting a simple toy kernel to run via a self-made boot loader.

From then on, development of drivers and kernels mostly will be based off of online textbooks and resources (courtesy of OSDev Wiki)

## Deadline/Goals

Early March/April: Familiarize myself with assembly, code boot disk and code up general purpose methods (printing, etc.)  
=> COMPLETED

August: Boot into 32-bit protected mode, load a toy kernel system to ensure successful kernel-loading  
=> COMPLETED

Mid-September: Fill out kernel to create a bare-bone but functioning file system and driver. This is bound to be a bite far larger than I can chew, so I am willing to extend the deadline to the full extent of September. This goal is split into the following chunks:

- Build a cross-compiler for kernel development
- Build a display driver
- Build a interrupt handler
- Build a Keyboard driver
- Build a HD driver
- Build a File System

Post October: Lay out final goals for my definition of a 'functioning OS'. Set a realistic goal to get my OS to become, taking into consideration what I would learn along the way and the work/time needed to be allocated.

Beyond: Beyond this point, I am planning on extending various features to the OS, such as memory protection. While up to the extent of the textbook I'm reading will be a short-term project to familiarize myself with basic OS concepts and the necessary engineering, the hope is that beyond that point this project can develop into a long-term sandbox where I can use as a foundation for future OS-related security projects.

## Reference

Compiling assembly files with nasm

> nasm foo.asm -f bin -o foo.bin

Compiling C code into object files, linking them into a binary file (specify flags to output elf-32 files), and disassembling them

> gcc -m32 -ffreestanding -c foo.c -o foo.o
> ld -m elf_i386 -o foo.bin -Ttext 0xabcd foo.o --oformat binary
> ndisasm -b 32 foo.bin > foo.dis

Compiling multiple object files (offset all local address references from origin address 0xabcd)

> ld -m elf_i386 -o foobar.bin -Ttext 0xabcd foo.o bar.o --oformat binary

Compile a assembly file into object file

> nasm foo.asm -f elf -o foo.o

Emulate created image on virtual machine

> qemu-system-x86_64 -fda foo
