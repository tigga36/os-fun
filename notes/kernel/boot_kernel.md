# Writing a Kernel

WOWEEE, LETS WRITE A KERNEL. The step goes as follows:

- Write/compile kernel code
- Write/assemble boot sector code
- Create kernel image including a boot sector and the compiled kernel code
- Load kernel code into memory
- Switch to 32-bit protected mode from 16-bit
- Begin executing kernel code

## Writing the Kernel

Just write a simple program that let's us know that we were even able to load the kernel.

When linking the compiled object file into a binary file, we set the offset of the beginning to 0x1000. This is essentially telling the computer that the origin of the code once loaded will be at 0x1000. Local address reference will be made with respect to this origin address. (Similar to how [org 0x7c00] in assembly set the relative address of all other variables, because BIOS loads there an begins to execute code there)

## Boot Sector Revisited

The Boot Sector will be responsible for loading and executing (bootstrapping is the cool term for it) the kernel from the disk. The kernel was coded and compiled in 32-bit instructions, so we have to switch to 32-bit mode before executing the kernel. 

### Recap

It's been roughly 2 months since I last touched assembly so I mostly forgot about what I coded (well, followed along and practically copied from the textbook) for the boot sector. Here are a couple fundamental points to recall:

- BIOS only loads the boot sector (the first 512 bytes of the disk) 
- But, disk routines lets us read more sectors
- After switching to 32-bit, BIOS will no longer be with us, making it difficult to use the disk directly: requires us to write our own driver

So, back to kernels. W\We need to figure out which disk/sector to load the kernel. First, about **kernel images**. Kernel images are the idea that the boot sector and kernel of an OS can be grafted together into something called a kernel images. The image can then be written on the initial sectors of the boot disk, so the boot sector code goes before the kernel image always. By grafting, I mean literally concatenating the compiled boot sector and kernel binaries together as so:

> cat boot_sect.bin kernel.bin > os-image

Now, use that image to boot your virtual OS emulator of choice (qemu for me)
