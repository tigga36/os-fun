[org 0x7c00]

mov ah, 0x0e ; setting part of ax to indicate scrolling teletype BIOS routine

; type 1
	mov al, the_secret
	int 0x10

; type 2
	mov al, [the_secret]
	int 0x10

; type 3
	mov bx, the_secret
	add bx, 0x7c00
	mov al, [bx]
	int 0x10

; type 4
	mov al, [0x7c1e] ; the square bracket represents the data at the address indicated by the content of the bracket
	int 0x10

jmp $

the_secret:
	db "X" ; btw, db stands for define byte

; pad
	times 510-($-$$) db 0
	dw 0xaa55 