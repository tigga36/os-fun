; Multiboot loader variables declaration: Constants for header
; I don't know what any of these headers do, but they help with loading kernels I guess
MBALIGN equ 1 << 0 ; aligning loaded modules on page boundary
MEMINFO equ 1 << 1 ; providing memory map
FLAGS equ MBALIGN | MEMINFO ; multiboot 'flag' field
MAGIC equ 0x1BADB002 ; magic number that lets the bootloader find the header
CHECKSUM equ -(MAGIC + FLAGS) ; checksum value of above value to prove that we are multiboot

; Now, declare the actual multiboot header
; magic values are documented in the multiboot standard
; bootloader finds this signature in first 8KB of kernel file, aligned at 32-bit boundary
; signature has a section dedicated to it so header is forced to be within first 8KB of kernel file
section .multiboot
align 4
	dd MAGIC
	dd FLAGS
	dd CHECKSUM

; Some bootloaders may initialize the stack, but multiboot doesn't.
; Kernel should thus provide values for the stack pointer register.
; To initialize the stack:
; Create symbol at bottom, and allocate 16384 bytes for it, topping it with a symbol on top
; Stack grows downwards on x86, but doesn't that mean stack_top should be getting initialized first? Curious, TODO: figure out how this works
; Anyways, Stack is also aligned in 16 bytes according to the standard, otherwise it will throw errors

section .bss
align 16
stack_bottom: ; Why? We must be setting the stack_bottom in an earlier address than stack_top here, so why wuold the stack be growing backwards? If they mean backwards wrt the mental image of stack, they may be correct, but idk...
resb 16384 ; = 16KB, resb command essentially allocates bytes
stack_top:

; _start is considdered as the entry point to the kernel. Boot loader will jump to this position once kernel is loaded.
; Also, the computer doesn't assume to return to this function beyond the kernel.
section .text
global _start:function (_start.end - _start) ; declare _start as function symbol with given size
_start:
	; Bootloader will automatically load into x32 protected mode
	; Interrupts are disabled
	; Paging is disabled
	; Processor state: multiboot standard
	; Kernel has full control
	; Kernel only uses hardware and code
	; No libraries, no nothing, unless the kernel provides its own library
	; Nothing related to security, no debugging. Only what the kernel has.

	; This is where we actually set the stack up where we initialized earlier
	; esp register points to top of stack
	; (We do this here because C can't function without a stack)
	mov esp, stack_top

	; Now, set initial processor state before loading the kernel
	; Things like floating point and instruction set extensions don't exist here.
	; GDT, paging, support for langugages like C++ should be done here.

	; Enter kernel. At this point stack should be 16-byte aligned
	extern kernel_main
	call kernel_main

	; Beyond this point, computer goes on infinite loop.
	; 1) disable interrupts with cli
	; 2) By waiting for next interrupt with hlt (halt instruction. Also, interrupts are disabled so it will never come) we freeze the execution
	; 3) Jump to hl3 instruction just in case 
	cli
.hang 	hlt
	jmp .hang
.end:
