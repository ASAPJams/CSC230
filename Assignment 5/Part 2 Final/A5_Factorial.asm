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
; This program calculates and stores the factorial of an integer
; between 1 and 6 inclusive, and outputs the least significant bits
; of the binary representation of the result on the LEDs.
;
; Where:
;	Initial value is found in program memory at init label
;   Result is stored in data segment at 0x200
;
.cseg

;  Obtain the constant from location init
	ldi zH, high(init<<1)
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


; The recursive factorial function is defined here.
; It takes one parameter, the number to be factorialized.
; Returns the value of the factorial in regitsters r20:r19
fact:

;	Protect registers used
	push r16
	push r17
	push r18
	push r24
	push r25
	push r28
	push r29

;	use Y to point to stack to retrieve param
	in yH, SPH
	in yL, SPL

	ldd r16, Y+11

;	if(n==1) return 1
	cpi r16, 1
	brne recursive
	
;	here we return 1, and ensure the high byte is 0x00
	mov r19, r16
	ldi r20, 0
	
	rjmp done_fact	

recursive:
;	This is the recursive case, which makes use 
;	of the multiply subroutine from part 1

;	Here we call fact(n-1)
	mov r18, r16
	dec r18
	push r18
	
	rcall fact
	
;	Remove param from stack
	pop r18

;	Next we multiply the parameter value with the result of factorial(n-1)
;	Since we have n <= 6, we know that the upper byte of the previous result 
;	is empty - so we only need to multiply the lower byte with the parameter.
	push r16	; param
	push r19	; fact(n-1)

	rcall multiply
	
;	Pop parameters back off
	pop r16
	pop r19 

;	We now have our new result stored in R25:R24 
;	so we copy them into our return registers
	mov r19, r24
	mov r20, r25
	

done_fact:
; pop all protected registers back
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

;	Note: we do not need to set up the stack
;	We can just use it as defined in m2560def.inc via in, out
	

;	We call the factorial function with the value at init
	push r16
	rcall fact
	pop r16

;	The output value has been stored in r20:r19 
;	by the fact function, so we now store it in result
	ldi yH, high(result)
	ldi yL, low(result)
	st Y+, r19
	st Y, r20



;	Now we need to output the lower nibble of rsult to portL, which is stored in r19


;	Space out the lower nibble
.def mask = r17
.def data = r19
.def ans = r18
.def tmp = r21
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

	lsl ans

;	Output the nibble to portL
	ldi r16, 0xFF
	sts 0x10A, r16	; Set DDRL
	sts 0x10B, ans  ;output to PORTL 
	

; YOUR CODE FINISHES HERE
;****

done:	jmp done

; The constant, named init, holds the starting number.  
init:	.db 0x03



; This is in the data segment (ie. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor.  
;
.dseg
.org 0x200

result:	.byte 2

