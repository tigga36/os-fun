# Setting default directive to compile everything into a kernel-image
all : os-image

# Run qemu to boot the OS based on the made file.
run : all

# Concatenating the final binaries into an image
os-image : boot_sect.bin kernel.bin
	cat $^ > os-image

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

# Assembling the boot sector assembly code into raw binaries
# The -I flag sets which directory to read dependencies marked within the assembly from
boot_sect.bin : boot_sect.asm
	nasm $< -f bin -I './' -o $@

# Cleaner for deleting all generated files
clean :
	rm *.bin *.o

# Bonus disassembler command to generate disassembled kernel file
kernel.dis : kernel.bin
	ndisasm -b 32 $< > $@
