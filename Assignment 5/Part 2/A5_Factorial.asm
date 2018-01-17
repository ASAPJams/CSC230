;
; CSc 230 Assignment 5 Part 2 Programming
;   Factorial
;  
; YOUR NAME GOES HERE:  Jamie Kirkwin
;	Date: 				11/13/2017
; Description			Questions 3, 4 from CSc 230 Assignment 5
;						A factorial is calculated, and its lower nibble is output to the LEDs
;
.include "m2560def.inc"
; This program . . . (edit this line)
;
; Where:
;
;   (result) . . . (edit this line)  
;
.cseg

;  Obtain the constant from location init
	ldi zH, High(init<<1)
	ldi zL, low(init<<1)
	lpm r16, Z

;***
; YOUR CODE GOES HERE:
;


;	We skip past function and macro definitions
	rjmp start_program



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




;The recursive factorial function is defined here.
;It takes one parameter, the number to be factorialized.
;It stores the result in SRAM at the 'result' label.
fact:
	
;	Protect registers used
	push r16
	push r17
	push r18
	push r24
	push r25
	push r28
	push r29
	push r30
	push r31

;	use Z to point to result in SRAM
	ldi zH, high(result)
	ldi zL, low(result)

;	use Y to point to stack to retrieve param
	in yH, SPH
	in yL, SPL

	ldd r16, Y+13

;	if(n==1) return 1
	cpi r16, 1
	brne recursive
	
;	here we store the value of 1 in result, and ensure the high byte is 0x00
	st Z+, r16
	ldi r16, 0
	st Z, r16
	
	rjmp done_fact	

recursive:
;	This is the recursive case, which makes use 
;	of the macro and subroutine from part 1

;	Here we call fact(n-1)
	mov r18, r16
	dec r18
	push r18
	
	rcall fact
	
;	Remove param from stack
	pop r18

;	We retrieve value stored in result by our recursive call
	ld r17, Z

;	Next we multiply the parameter value with the result value
;	Since we have n <= 6, we know that the upper byte of result is empty,
;	And so we only need to multiply the lower byte with the parameter.
	push r16
	push r17

	rcall multiply
	
;	Pop parameters back off
	pop r16
	pop r17 

;	We now have our new result stored in R25:R24
;	so we make those values our result
	st Z+, r24
	st Z, r25
	

done_fact:
;	pop all protected registers back

	pop r31
	pop r30
	pop r29 
	pop r28
	pop r25
	pop r24
	pop r18
	pop r17
	pop r16


	ret

; Regular execution begins here.
start_program:

;	Set up the stack
	ldi r17, high(RAMEND)
	sts SPH, r16
	ldi r17, low(RAMEND)
	sts SPL, r16

;	We call the factorial function with the value at init
	push r16
	rcall fact
	pop r16

;	The output value has been stored in result by the fact function
;	Now we need to output the lower nibble of rsult to portL

;	Retrieve the lower byte of result
	ldi yH, high(result)
	ldi yL, low(result)
	ld r16, Y

;	Space out the lower nibble
.def mask = r17
.def data = r16
.def ans = r18
.def tmp = r19
	ldi mask, 0x01
	ldi ans, 0x00
bit_loop:
	mov tmp, data
	and tmp, mask
	or ans,tmp
	

	lsl data
	lsl mask
	lsl mask
	cpi mask, 0x00
	brne bit_loop

;	Output the nibble to portL
	ldi r16, 0xFF
	sts 0x10A, r16	; Set DDRL
	sts 0x10B, ans  ;output to PORTL 
	

; YOUR CODE FINISHES HERE
;****

done:	jmp done

; The constant, named init, holds the starting number.  
init:	.db 0x04



; This is in the data segment (ie. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor.  
;
.dseg
.org 0x200

result:	.byte 2

