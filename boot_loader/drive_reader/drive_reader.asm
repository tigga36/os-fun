; Loading a sector to main memory address:
; ES(General purpose segment) with BX offset
; Drive DL

; CHS addressing scheme:
; dl - specifying which drive to read (0 to n)
; dh - secifying track to read (0 to n)
; cl - specifying sector on track to read (1 to n)
; ch - specifying cylinder to read (1 to n)
; NOTE: c specifiers begin counting from 1, while d from 0

disk_load:
	push dx ; Push to preserve previous dx value

	mov ah, 0x02 ; BIOS read sector config
	mov al, dh ; specify track (group of sectors) to read
	mov ch, 0x00 ; specify first cylinder
	mov dh, 0x00 ; specifying first track, head 0
	mov cl, 0x02 ; read from second sector, after the boot sector

	int 0x13 ; BIOS interrupt to execute read

	jc disk_error ; Jump if the carrying flag is set, indicating error

	pop dx ; restore dx after use

	; Error checking:
	; if AL (sectors read) != DH (sectors expected)
	; then trhow error
	cmp dh, al
	jne disk_error
	ret

disk_error:
	mov bx, DISK_ERROR_MSG
	call print_string
	jmp $

; Vars
DISK_ERROR_MSG db "Disk read error!", 0

MES db "wow", 0
