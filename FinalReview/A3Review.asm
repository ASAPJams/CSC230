.include "m2560def.inc"
.cseg

;set up the stack
	ldi r16, high(RAMEND)
	out sph, r16
	ldi r16, 0xFF
	out spl, r16

;configure portl for output
	ldi r16, 0xFF
	sts DDRL, r16

.def number = r16
;number = /* choose a number in (0x00, 0x0F] */ ;
	ldi r30, low(initial<<1)
	ldi r31, high(initial<<1)
	lpm number, Z

;set Z to point to dest
	ldi r30, low(dest)
	ldi r31, high(dest)

;while (number > 0) {
loop:
	cpi number, 0
	breq doneLoop

	;dest[count++] = number;
	st Z+, number

	; * Output number on LEDs *
	push number
	rcall output
	pop number
	
	; * delay 0.5 second *
	
	; number --;

	dec number
	rjmp loop

doneLoop:

done:	rjmp done

output:
	push r31
	push r30
	push r19
	push r18
	push r17
	push r16

	;use z to get parameters
	in r30, spl
	in r31, sph
	
	;param at SP+(# protected registers) + 3 + 1 = SP + 10
	ldd r16, Z+10 
	
	;now need to spread out the bits of r16
	ldi r17, 0b1000 ;mask
	
	ldi r18, 0 ; spaced out 
	
	ldi r19, 0 ;temp

shiftLoop:
	cpi r17, 0
	breq doneShiftLoop
	
	;isolate the bit
	mov r19, r16
	and r19, r17

	;add the bit to result
	or r18, r19

	;shift mask and result
	asr r17
	lsl r18
	rjmp shiftLoop
	
doneShiftLoop:

	;output to portl
	sts portl, r18

	pop r16
	pop r17
	pop r18
	pop r19
	pop r30
	pop r31

	ret


initial: .db 0xF

.dseg
.org 0x200
dest: .byte 16
