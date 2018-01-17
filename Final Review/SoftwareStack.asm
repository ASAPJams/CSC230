; A review project: imliment a software stack in the 'middle' of data memory
; Will have it begin at data memory address 0x16AA (2 thirds of the way up dseg)
; We dedicate the Y registers to be our software stack pointer
.include "m2560def.inc"
.cseg

.MACRO pops
	inc r28
	ld @0, Y
.ENDMACRO

.MACRO pushs
	st Y, @0
	dec r28
.ENDMACRO

.MACRO addWide
	; AL,AH <-- BL,BH
	add @0, @2
	adc @1, @3
.ENDMACRO

	;Set up hardware stack
	ldi r16, 0xFF
	out spl, r16
	ldi r16, 0x21
	out sph, r16

	;Set up software stack
	ldi r28, 0xAA
	ldi r29, 0x16

	ldi r18, 5
	ldi r19, 6
	pushs r18
	pushs r19
	rcall multiply

	pops r16
	pops r17

done: rjmp done

multiply:
	push r16
	push r17
	push r18
	push r19
	push r20
	
	ldi r18, 0
	ldi r19, 0
	ldi r20, 0

	;get params
	pops r16
	pops r17
	
	;now need to multiply: AxB= A+A+A+...+A (B times)
	;for(r17 times) ADD 18, r16
loop:
	cpi r17, 0
	breq doneLoop
	dec r17
	addWide r18, r19, r16, r20
	rjmp loop
doneLoop:
	
	;result is in r18:r19
	pushs r18
	pushs r19

	pop r20
	pop r19
	pop r18
	pop r17
	pop r16

	ret

.dseg
.org 0x200
