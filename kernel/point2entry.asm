; Entry guide directive for telling the CPU where the kernel code begins (where to jump to in order to correctly execute the kernel code)

[bits 32] ; PM code, no longer need to code in 16 bits
[extern main] ; Declaration: Referencing the external symbol 'main', which the linker will later replace with the actual physical address of the main function in the kernel code.

call main ; Call that shit
jmp $ ; When we return from the kernel, freeze
