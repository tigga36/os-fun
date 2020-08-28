[bits 32]

; Make the switch to Protected Mode (32-bit)
switch_to_pm:
	cli ; Command to disable interrupts, as they will be useless, and get in the way when the protected mode interrupt vector wants to move
	
	lgdt [gdt_descriptor] ; Load GDT descriptor table
	
	mov eax, cr0 ; Make switch to protected mode: Intermediate gen. purpose register because we can't directly write in contorl register
	or eax, 0x1 ; Use of or instruction to just change the first bit without disturbing the rest
	mov cr0, eax ; Finalize change

	jmp CODE_SEG:init_pm ; Making a 'far jump' (basically a jump to a new segment) to the 32-bit code. This jump apparently is significant enough that it forces the CPU to flush its cache of pre-fetched and real-mode decoded instructions which will cause difficulties when trying to run in 32-bit protected mode.

[bits 32]

; Initializing registers and the stack after entering Protected Mode.
init_pm:
	mov ax, DATA_SEG ; Update all old segment registers. Change segment register values to data segment descriptor in the GDT
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000 ; Update stack position to top of the free space. Not sure how this got here so TODO: understand this code
	mov esp, ebp ; Initialize

	call BEGIN_PM ; Call directive to begin the protected mode.
