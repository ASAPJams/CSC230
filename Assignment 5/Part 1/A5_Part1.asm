; Jamie Kirkwin
; V00875987
; CSc 230, Assingment 5, Part 1

.include "m2560def.inc"

.cseg

rjmp start

; Problem #1
;	this macro (add wide) takes 4 arguments, which are registers 
;	representing 2 16-bit integers. 
;	addw ah, al, bh, bl results in ah:al recieving the value of a+b
.macro addw
	; add the low bytes of a and b
	add @1, @3		

	; add the high bytes of a and b and any carry value from the low bytes
	adc @0, @2	
.endmacro


; A function that multiplies 2 bytes via repeated addition
; These bytes are passed on the stack
; The return value is placed in R25:R24
multiply: 

; protect registers to be used
push r16
push r17
push r18
push r30
push r31

;use Z to retrieve the parameters from the stack
.def factor = r16
.def multh = r17
.def multl = r18
	
	;Lillanne - Qustion: When I first wrote this program I used lds instead of in,
	;					 simply for continuity's sake as earlier I used sts, not out.
	;					 When I used lds, however, the Z pointer was always given the 
	; 					 RAMEND value (0x21FF). Why was this happening and how can I 
	;					 avoid such a bug in the future?
	in ZH, SPH
	in ZL, SPL
	
	
	ldd factor, Z+9
	ldd multl, Z+10

	; multiplier is only one byte, so in order to use the
	; macro we need to pass a register containing 0 as 
	; multiplier's high byte.
	ldi multh, 0	

;word answer = 0
.def ansh = r25
.def ansl = r24
	ldi ansl, 0
	ldi ansh, 0

loop:
;while(factor-- > 0)
	cpi factor, 0
	breq done_loop
	
	;answer += multiplier
	addw ansh, ansl, multh, multl
	
	dec factor

	rjmp loop
done_loop:

; reset protected registers
pop r31
pop r30
pop r18
pop r17
pop r16

; remove unneeded labels
.undef ansl
.undef ansh
.undef factor
.undef multh
.undef multl
	
	ret

; Regular execution begins here
start:

	; set up the stack
	ldi R16, high(RAMEND)
	sts SPH, r16
	ldi r16, low(RAMEND)
	sts SPL, r16

	ldi r16, 0x80
	ldi r17, 0x05
	push r16
	push r17	

	rcall multiply


done: 
	rjmp done


.dseg
.org 0x200
