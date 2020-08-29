# Automating Linking and Compiling with Make

Commands like `nasm`, `ld`, `gcc`, are consulted every time to implement the smallest changes in a file making up a kernel-image. Kinda dumb retyping commands with a lot of flags right? Let's authomate that with the `make` command. It's a classic command as the predecessor to many of modern building/setup commands. Syntax is simple enough, say you want to compile C code into an object file. You need a `Makefile` with the following code:

> foo.o : foo.c
>	gcc -ffreestanding -c foo.c -o foo.o

Now, just type `make foo.o`, and whenever foo.o doesn't exist in that directory, make will do the compiling for you with the command you specified it with. Things will get really convenient once you set up a Makefile that automates consecutive interdependent commands to achieve a final product. 

Assert your dominance by using `$<`, `$@`, `$^` which are special makefile variables. 

- `$<`: Represents the first dependency
- `$@`: Represents the target file
- `$^`: Substitutes all of the target's dependency files

Furthermore, make use of the `clean` target. When running `make clean`, it will run the directive, and by design you can make it delete any output files that you would like to get rid of to reduce clutter or making sure the file builds correctly from scratch.

Also, when running `make` without anything after, it will run the first directive in the Makefile. To prevent unintended directives from running, often dummy targets are set up on top of makefiles to force execution of an intended directive. The name can be anything, but often names such as `all` is set.
