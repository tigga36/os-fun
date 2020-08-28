; Program to read sectors from boot disk using drive reader function
; This program spits out errors without the -fda flag on qemu execute, which sets dl to 0x00 apparently.

[org 0x7c00]

	mov [BOOT_DRIVE], dl ; The dl register stores the boot drive, which is appointed by BIOS.

	mov bp, 0x8000 ; Save the stack pointer far away from the commotion of memory about to happen
	mov sp, bp

	mov bx, 0x9000 ; Load 5 sectors of data into 0x0000 (of general purpose segment ES) to 0x9000
	mov dh, 5 ; set parameter of function to 5
	mov dl, [BOOT_DRIVE] ; set parameter to where the boot drive is
	call disk_load

	mov dx, [0x9000] ; Load content of first loaded word into dx to print
	call print_hex

	mov dx, [0x9000 + 512] ; add 512 to reference the next sector that was loaded
	call print_hex

	jmp $

%include "./print/print_string.asm"
%include "./print/print_hex.asm"
%include "./drive_reader/drive_reader.asm"

; Global variables
BOOT_DRIVE: db 0

; Bootsector padding
times 510-($-$$) db 0
dw 0xaa55

; The BIOS loads only the first 512 bytes on boot.
; By adding more sectors, reading the next sectors (like this program does) should print expected hex values, as specified below
times 256 dw 0xdada
times 256 dw 0xface
