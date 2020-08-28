; Simple boot sector to print message to screen using BIOS routine

mov ah, 0x0e ; setting interrupt command register to indicate scrolling teletype BIOS routine

mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
mov al, 'l'
int 0x10
mov al, 'o'
int 0x10

jmp $ ; Jump to current address (as in dont move?)

times 510-($-$$) db 0 ; Pad with zeros to make up 512
dw 0xaa55 ; Last 2 bytes to form magic number for BIOS to see as boot sector