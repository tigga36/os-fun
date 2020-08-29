#Create a list of sources with the wildcard functionality
# New functionality may be implemented with new directories, in which case should be added below to include them in the list generated
C_SRC = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# TODO: The textbook here specifies that all sources must be made to depend on header files.

# Convert C files to object files and create a list
OBJ = $(C_SRC:.c=.o)

# Setting default directive to compile everything into a kernel-image
all : os-image

# Run qemu to boot the OS based on the made file.
# TODO: this command doesn't work, fix it
run : all
	qemu-system-x86_64 -fda os-image

# Concatenating the final binaries into an image
os-image : booty/boot_sect.bin kernel.bin
	cat $^ > os-image

# Compile the kernel binary file
# The $^ variabln denotes all dependency files
kernel.bin : kernel/point2entry.o ${OBJ}
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

# To do the above, we need all object files
# $< denotes the first dependency, and $@ represents the target file
# Below code is updated from compiling just the kernel.c file to a general rule to be applied to all C file to object file
# Ensure object files also depend on header files as well
%.o : %.c ${HEADERS}
	gcc -m32 -ffreestanding -c $< -o $@

# ...and the kernel entry object file
# point2entry.o-specific compilation is replaced with a generic file-type-based rule
%.o : %.asm
	nasm $< -f elf -o $@

# Assembling the boot sector assembly code into raw binaries
# The -I flag sets which directory to read dependencies marked within the assembly from
# Similar to above, replace boot_sect.bin-specific dependencies to generic rule
%.bin : %.asm
	nasm $< -f bin -I './booty/' -o $@

# Cleaner for deleting all generated files
# Expand rm command to other subdiretories as well
clean :
	rm -fr *.bin *.o os-image *.map *.dis
	rm -fr kernel/*.o booty/*.bin drivers/*.o

# Bonus disassembler command to generate disassembled kernel file
kernel.dis : kernel.bin
	ndisasm -b 32 $< > $@
