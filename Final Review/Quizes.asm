.cseg
.include "m2560def.inc"
rjmp quiz2Setup

quiz1Setup:
	ldi r17, 0x20
	mov r0, r17
	ldi r17, 0x00
	mov r1, r17
	ldi r17, 0x11
	mov r2, r17
	ldi r17, 0x1f
	mov r3, r17
	ldi r26,0x17
	ldi r27,0x18
	ldi r30, 0
	ldi r31, 2

	ldi r16, 0x10
	st Z+, r16
	ldi r16, 0x2f
	st Z+, r16
	st Z+, r16
	ldi r16, 0xfd
	st Z+, r16
	ldi r16, 6
	st Z+, r16
	ldi r16, 00
	st Z+, r16
	ldi r16, 0x0f
	st Z+, r16
	ldi r16, 0xde
	st Z+, r16

doneQ1Setup:

quiz1:
	ldi r26, 00
	ldi r27, 02
	ld r0, X+
	ld r1, X+
	cp r0, r1
	breq skip
	add r2, r1
skip:
	lsl r3

quiz2Setup:
.def sum = r16
.def term = r17
.def index = r18
.def size = r19

	ldi size, 8
	ldi r16, 0xFF
	out spl, r16
	ldi r16, 0x21
	out sph, r16

	push size
	rcall computeSum
	pop size

	ldi r30, low(sumLoc)
	ldi r31, high(sumLoc)
	st Z, sum

done:rjmp done

computeSum:
	push size
	push term
	push index
	push r30
	push r31

	ldi sum, 0
	ldi index, 0
	ldi term, 1

	;get size param
	in r30, spl
	in r31, sph

	ldd size, Z+9

loop:
	cp size, index ;for(index = 0; index < size; index++)
	breq doneLoop
	inc index
	add sum, term
	lsl term
	rjmp loop
doneLoop:
	pop r31
	pop r30
	pop index
	pop term
	pop size

	ret

.dseg
.org 0x200
sumLoc: .byte 2
