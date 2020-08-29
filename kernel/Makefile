# Setting default directive
all: kernel.bin

# Compile the kernel binary file
# The $^ variable denotes all dependency files
kernel.bin : point2entry.o kernel.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 $^ --oformat binary

# To do the above, we need the kernel object file
# $< denotes the first dependency, and $@ represents the target file
kernel.o : kernel.c
	gcc -m32 -ffreestanding -c $< -o $@

# ...and the kernel entry object file
point2entry.o : point2entry.asm
	nasm $< -f elf -o $@

clean:
	rm *.bin *.o
