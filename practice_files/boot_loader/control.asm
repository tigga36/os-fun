mov bx, 300

cmp bx, 4
jle then_block
cmp bx, 40
jl elif_block
mov al, 'C'
jmp the_end

elif_block:
	mov al, 'B'
	jmp the_end

then_block:
	mov al, 'A' 
	jmp the_end

the_end:
	mov ah, 0x0e
	int 0x10
	jmp $

times 510-($-$$) db 0
dw 0xaa55