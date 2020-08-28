; Boot sector booting with a C kernel 32-bit protected mode

[org 0x7c00]

KERNEL_OFFSET equ 0x1000 ; Memory offset to where to load the kernel

	mov [BOOT_DRIVE], dl ; According to CHS addressing scheme, dl specifies which drive to read. Other than that this line of code seems pretty confusing TODO: Research this part

	mov bp, 0x9000 ; Set up stack
	mov sp, bp

	mov bx, MSG_REAL_MODE ; Beginning on boot on 16 bit mode
	call print_string ; Let the world know about it

	call load_kernel ; Load kernel as specified below

	call switch_to_pm ; Switch to PM, no longer will return from here

	jmp $ ; Obligatory stuck here

; Call previously-created routines
%include "../boot_loader/print/print_string.asm"
%include "../boot_loader/drive_reader/drive_reader.asm"
%include "../boot_loader/protected/gdt.asm"
%include "../boot_loader/protected/print_string_pm.asm"
%include "../boot_loader/protected/switcheroo.asm"
