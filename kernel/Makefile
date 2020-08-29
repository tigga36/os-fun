# Compile the kernel binary file
kernel.bin : point2entry.o kernel.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 point2entry.o kernel.o --oformat binary

# To do the above, we need the kernel object file
kernel.o : kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o

# ...and the kernel entry object file
point2entry.o : point2entry.asm
	nasm point2entry.asm -f elf -o point2entry.o
