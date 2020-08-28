# Switching to 32-bit Protected Mode

The switch will make use of the GDT and GDT descriptor code.

First, disable all interrupts with the `cli` (clear interrupt) instruction. With this, any future interrupts will be ignored, until once again reenabled. This is because interrupt handling is dealt with differently between 16-bit real mode and 32-bit protected mode. In 32-bit protected mode, BIOS interruption routines are useless, as it would be executing 16-bit code, incompatible with the 32-bit segments we have defined, leading to the CPU crashing.

We then tell the CPU about the GDT. the `ldgt [<GDT_LOCATION>]` command will do this.

The final switch begins by first setting the first bit of a CPU control register, `cr0`. One can't directly change the values on that register, so we load the value into the general purpose register first, and store it back to cr0, as follows:

> mov eax, cr0 ; Copy current value of cr0 into gen purpose register eax
> or eax, 0x1 ; Using the or instruction, change the first bit to 1 without disturbing the other values
> mov cr0, eax ; Return the new value into the cr0 register

With that update to the control register, the CPU should be in 32-bit protected mode. Actually that's not completely true. Because pipelining is a thing, immediately executing 32 bit instructions may screw with any piplined instructions that were scheduled in 16-bit mode. While pipelining and the likes should be mainly abstracted from what we do here and thus not really discussed, this is one of those risky areas we need to be aware of. By not being completely 32-bit protected mode yet, I mean we need to now tell the CPU to finish any jobs in the current pipeline, so we don't accidnetally run any instructions in the wrong mode. How do we do that? By issuing a big-ass jump. Instruction-level-parallelism hates far jumps, because the CPU doesn't know what instructions to expect following that jump. So, lets make it jump to another segment, just like as follows:

> jmp <segment>:<address offset>

But where do we land? Say for instance if we jump to where 32-bit code for protected mode explicitly begins, it may be closer than one would image to the current position, not warranting a flush of pipeline. Furthermore, what we're currently executing is 16-bit code. So we are kind of in the border between the two modes, with our current code segments based on 16-bits. The `cs` register, one of the special registers appointed to be the segment registers to help 16-bit mode CPU compute absolute addresses for code segment instructions, won't be valid anymore in protected mode. With our current state, the CPU will automatically calculate the absolute address of a 16-bit address specified for code segments with the standards of 16-bit mode. The point of the GDT is to replace the segmentation address style used in 16-bits, so it should be replacing the contents of the `cs` register as well. So, update `cs` register value to the offset of the code segment in the GDT.

While physically, this may seem like a jump to a close proximity from where we were, the method of jump apparently is significant enough to flush the rest of the pipeline. Beyond this point, [bits 32] should be placed to encode all instructions beyond this point in 32-bits. Note we can still use 32-bit instructions in 16-bit real mode, albeit requiring some adjustments to how it is encoded. 

That should place us well inside 32-bit protected mode. From here, we should update all other segment registers to point to 32-bit data segments, which in prior they pointed to respective segment positions relevant to 16-bit mode. The position of the stack should also be updated.
