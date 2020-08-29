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

[bits 16]

; Method to load kernel
load_kernel:
	mov bx, MSG_LOAD_KERNEL ; Let the world know
	call print_string
	
	mov bx, KERNEL_OFFSET ; Setting up arguments in registers to get ready for drive_reader
	mov dh, 15 ; The 15 here means that basically we read the first 15 sectors of the boot disk 
	; But why read so many sectors? The kernel image is supposedly a lot smaller than this. Because we can. Even if it were to be empty, it doesn't hurt to allocate this much for now, as we may need more space as the kernel grows. Insufficient space allocated for kernels could force the process to keel over and die without any warning, which could be very nasty to debug.
	mov dl, [BOOT_DRIVE]
	call disk_load

	ret

[bits 32]
; Arrived to protected mode, and begin setup of PM environment

BEGIN_PM:
	mov ebx, MSG_PROT_MODE ; Let the world know we are in business
	call print_string_pm

	call KERNEL_OFFSET ; Jump to address of where the kernel code should be loaded

	jmp $

; Global Variables
BOOT_DRIVE db 0
MSG_REAL_MODE db "We are in 16-bit mode like the scrubs we are", 0
MSG_PROT_MODE db "WHY YES HELLO IT IS I THE CPU IN THE 32-BIT SYSTEM", 0
MSG_LOAD_KERNEL db "GOOD EVENING AND THIS IS MY KERNEL", 0

; Bootsector usual padding
times 510-($-$$) db 0
dw 0xaa55
