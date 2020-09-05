/* This is a linker script specifically designed to compile and assemble kernel and bootloader. While default scripts in user space allows us to put these together, they are unsuitable for kernel development, and it's apparently better to provide an own customized linker script. */

/* While understanding how to code linker scripts are not on top of my priorities right now, it's probably good to at least understand what goes on throughout the linking process */

/* Bootloader will look at this "image" (which I'm assuming is this file), and begin execution at the symbol designated as the entry point */
ENTRY(_start)

/* Now, tell the bootloader where the sections of object files will be placed in the final kernel image. */
SECTIONS
{
	/* Begin putting sections at 1 MiB (mebibyte btw, is basically teh same as MB, except while MB is explicitly a number based on powers of 10, MiB is a power of two, which makes it suitable for binary machines. 1MiB equals approx 1.04858..MB), which is the conventional spot to place kernels, wjich are loaded by the bootloader. */
	. = 1M;
	/* Put multiboot header, which you specified in the bootloader code */
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)
		*(.text)
	}
	/* Read-only data set here */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}
	/* Read-write data (initialized) */
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}
	/* Read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
	/* Compiler may produce other sections and will by default put them in a segment with the same name. Add here as needed from here */
}
