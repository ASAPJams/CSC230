; a test program to help with assignment 4
.cseg

	
;	Ldi r18, 0x80
;	add r18, r18
;	adc r18, r18
	
	ldi r16, 0x66
	sts 0x00F0, R16
	
	;Lds R2, 0x0F00



done: rjmp done

.dseg
.org 0x200

