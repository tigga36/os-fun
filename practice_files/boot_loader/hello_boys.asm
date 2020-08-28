; Prints strings using a self-contained function

[org 0x7c00] ; code will be loaded here

	mov bx, HELLO_MSG
	call print_string

	mov bx, GOODBYE_MSG
	call print_string

	jmp $

%include "./print/print_string.asm"

HELLO_MSG:
	db 'Hello, boys', 0 ; zero to denote end of string

GOODBYE_MSG:
	db 'Goodbye, boys', 0

	times 510-($-$$) db 0
	dw 0xaa55