; Boot sector designed to enter 32-bit protected mode

[org 0x7c00]

	mov bp, 0x9000 ; Set stack
	mov sp, bp

	mov bx, MSG_REAL_MODE
	call print_string

	call switch_to_pm ; We don't return from here: To the big wide world of 32-bit we go!

	jmp $

%include "../print/print_string.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switcheroo.asm"

[bits 32]

; We're in PM now buddy
BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	call print_string_pm ; Use shiny print method specifically for PM

	jmp $ ; This is as far as we'll go for now

; Defining Global Variables
MSG_REAL_MODE db "Started in 16-bit Real Mode like the scrub we are", 0
MSG_PROT_MODE db "WHY YES HELLO I AM IN 32-BIT PROTECTED MODE NOW BROTHER", 0

; Bootsector Padding, the usual
times 510-($-$$) db 0
dw 0xaa55
