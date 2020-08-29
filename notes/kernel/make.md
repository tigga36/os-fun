# Automating Linking and Compiling with Make

Commands like `nasm`, `ld`, `gcc`, are consulted every time to implement the smallest changes in a file making up a kernel-image. Kinda dumb retyping commands with a lot of flags right? Let's authomate that with the `make` command. It's a classic command as the predecessor to many of modern building/setup commands. Syntax is simple enough, say you want to compile C code into an object file. You need a `Makefile` with the following code:

> foo.o : foo.c
>	gcc -ffreestanding -c foo.c -o foo.o

Now, just type `make foo.o`, and whenever foo.o doesn't exist in that directory, make will do the compiling for you with the command you specified it with. Things will get really convenient once you set up a Makefile that automates consecutive interdependent commands to achieve a final product. 

## Variables

Assert your dominance by using `$<`, `$@`, `$^` which are special makefile variables. 

- `$<`: Represents the first dependency
- `$@`: Represents the target file
- `$^`: Substitutes all of the target's dependency files

## Clean

Furthermore, make use of the `clean` target. When running `make clean`, it will run the directive, and by design you can make it delete any output files that you would like to get rid of to reduce clutter or making sure the file builds correctly from scratch.

## Default Make

Also, when running `make` without anything after, it will run the first directive in the Makefile. To prevent unintended directives from running, often dummy targets are set up on top of makefiles to force execution of an intended directive. The name can be anything, but often names such as `all` is set.

## Wildcard Delcaration

As a project develops, there will be more and more C files and their corresponding object files to worry about, which is inevitable with increased functionality of the OS. The `wildcard` statement will allow us to manage all of that in our makefile without having to specify each and every single new file that pops up with each feature.

One can expand to a list of existing files with pattern matching as follows:

> FOOS = $(wildcard kernel/*c drivers/*c)

The list we just created can be converted into object filenames with a new make directive:

> FOOOBJS = ${FOOS:.c=.o}

The lists of C file and object files can now be used as follows:

> kernel.bin : kernel/point2entry.o ${OBJ}
>	ld -o $@ -Ttext 0x1000 $^ --oformat binary

## Pattern Rules

**Pattern rules** tells the makefilw how to build a tpye of file from another type of file with pattern machine of the filename. Say if you want to set a rule to build 'foo.o' from 'foo.c':

> %.o : %.c
>	gcc -ffreestanding -c $< -o $@

The above 2 lines of code replaces the otherwise many lines of code resulting from needing 2 lines of code for each directory/name of the file. 
