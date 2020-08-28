; The Global Descriptor Table declaration

gdt_start: ; declaring where gdt starts

gdt_null: ; null descriptor entry at the top of gdt for error catching
	dd 0x0 ; 8 bytes, declaring 4 bytes twice
	dd 0x0

; Below code will set up the explicit byte values. Note that values, such as segment limit, are fragmented across separate parts of the segment (such as limit on the first word of the lines of values, and the last 16-19 bits of it being appended to the second to last byte, after the 2nd set of flags).

gdt_code: ; Segment Descriptor for the code segment
	; Base= 0x0, Limit=0xfffff,
	; 1st set of flags: present=1, priviledge=00, descriptor=1 => 1001b
	; type flags: code=1, conforming=0, readable=1, accessed=0 => 1010b
	; 2nd flags: granularity=1, 32-bit default=1, 64-bit seg=0, AVL=0 => 1100b
	dw 0xffff ; Limit (0-15 bits)
	dw 0x0 ; Base (0-15 bits)
	db 0x0 ; Base (16-23 bits)
	db 10011010b ; 1st set of flags, and type flags
	db 11001111b ; 2nd set of flags, and the Limit (16-19 bits)
	db 0x0 ; Base (24-31 bits)

gdt_data: ; Segment Descriptor for the data segment
	; Mostly will be setting the same bytes except for type flags
	; type flags: code=0, expand down=0, writable=1, accessed=0 => 0010b
	dw 0xffff ; Limit (0-15 bits)
	dw 0x0 ; Base (0-15 bits)
	db 0x0 ; Base (16-23 bits)
	db 10010010b ; 1st set of flags, and type flags
	db 11001111b ; 2nd set of flags, and the Limit (16-19 bits)
	db 0x0 ; Base (24-31 bits)

gdt_end: ; Defining the end of the GDT, so assembler can calculate length of the GDT for the GDT Descriptor defined below.

; GDT descriptor
gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; Define the size of the GDT, define ONE LESS than true size
	dd gdt_start ; Start address for GDT

; Additional constants are defined below that will be useful. They are essentially offsets within the GDT to where the respective segments are. (0x0 points to the null descriptor, 0x08 points to code, and 0x10 points to data)

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_star
