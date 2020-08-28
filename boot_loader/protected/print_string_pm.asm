[bits 32]

; constant declaration:
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

; printing null-terminated string pointed to by EDX

print_string_pm:
	pusha
	mov edx, VIDEO_MEMORY ; set EDX to where video memory is stored

print_string_pm_loop:
	mov al, [ebx] ; Store the character stored in EBX in AL
	mov ah, WHITE_ON_BLACK ; Store attributes to AH

	cmp al, 0 ; check for end of string
	je done

	mov [edx], ax ; store char and attribute at current character cell

	add ebx, 1 ; increment EBX to next character of string
	add edx, 2 ; move attention to the next character cell in the video memory

	jmp print_string_pm_loop

print_string_pm_done:
	popa
	ret