# Writing Kernels in C

Should one manage to load a kernel binary file through a boot drive, they can leave explicitly instructing the CPU via assembly (for now), and enjoy a whole new plethera of complciations to worry about in higher-level languages.

## How C Compiles

By explicitly instructing the CPU to jump into the area in the kernel image to begin executing kernel instructions, one can see that kernel code is executed. From this point on, we should be careful about *how* the CPU actually executes the kernel instructions. Sure, if the C kernel code jumps right into the main() function, the compiled binary may begin their set of instructions from that. C code, however, includes a whole set of headers and supplementary functions in their code which C may compile so that they come before the main() function in the binary file. (For example, imagine a C kernel code where a random function precedes the main() function. Directly translating that into binary would mean that instructions of that random function comes before the main() function instructions. Should a boot driver instruct kernel code to be naively run from the beginning, it would run the arbitrary function and read the `ret` instruction, inevitably returning to the boot driver code!)

The way the final kernel binary instructions are aligned vary greatly among the way code is aligned, and by the whims of the compiler. Instead of accomodating those, we should make the kernel reader more robust. To achieve this, most operating systems append machine code in the beginning of kernel code, explicitly pointing the CPU to the entry function of the kernel. This instruction should be written in assembly to ensure that we know exactly the ouput machine code. This behaviour is close to what goes on under the hood in **linkers**, as they essentially chain object files together into a physical address, and once all functions have an absolute address to reside in, all references to that function (say from other object files being linked together) will be replaced with the absolute address of it.

The assembly file to code essentially consists of a jump to main. That's all it is. `[extern main]` is a directive used in this file, which labels the assembly code to tell the CPU that it expects some other external object file to contain a function called main. This ensures that we can simply write `main` in this code as if it is something in this file (actually not), and be resolved as a physical address at the point of linking.

While we said that this file would be a raw binary file, it can't stand on it's own, and need its fellow bretheren containing the main function to be corretly compiled. We leave that to the linker, and for now use `nasm` to compile the file into an object file, as follows:

> nasm point2entry.asm -f elf -o point2entry.o
