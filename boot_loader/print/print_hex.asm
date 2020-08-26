print_hex:
pusha

; Single out each 4 bytes in dx, and convert them each to ascii.

; Implement a counter
mov cx, 0

Loopy:
	; Stop the loop once we have iterated 4 times (hex word is 4 * 4 bits long)
	cmp cx, 4
	je end

	; Load word into ax, where it will be processed
	mov ax, dx
	and ax, 0x000f ; By using and like this, we mask sentence to only contain the last hex symbol.

	; Now add 0x30 (48 in decimals) to the number to a hex number into an ascii version of it.
	add ax, 0x30

	; In the case we are dealing with an alphabet ascii symbol (bigger than 0x39 (57 in decimals) we must add 0x07 to it to skip through other symbols to get to the upper case alphabets)
	cmp ax, 0x39
	jle Skip
	add ax, 0x07

Skip:
	; Specify the location in which the converted symbol is to go
	; bx should point to the location of HEX_OUT, and from there relatively how many bits from there. (0th bit is the greatest bit, and 5th bit being the last 0 null value.)

	mov bx, HEX_OUT + 5
	sub bx, cx
	mov [bx], al ; Paste lower bit of ax (converted symbol) onto where bx points to.
	shr dx, 4 ; Shift bit by 4, bringing next least-sig. bit of dx
	add cx, 1 ; increment
	jmp Loopy

end:
	mov bx, HEX_OUT
	call print_string
	popa
	ret

HEX_OUT: db '0x0000', 0