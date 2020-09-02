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


