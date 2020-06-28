print_string:
	pusha
	mov ah, 0x0e ; tele-type output
	Next:
		mov al, [bx]
		cmp al, 0
		je End
		int 0x10
		add bx, 1
		jmp Next

End:
	popa
	ret