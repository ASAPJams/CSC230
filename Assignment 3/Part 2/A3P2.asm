;Jamie Kirkwin
;V00875987
;CSC 230 Assignment 3, Part 2
;Last Edited:	10/10/2017

;Pre-Condition: The number given is between 0x01 and 0x0F inclusive.

.cseg
.def number = R16
.def mask = R17
.def tmp = R18
.def result = R19
.def index = R20



		; number = /* choose a number in (0x00, 0x0F] */
		ldi number, 0x0C

		; will use X as a pointer to our destination location in dseg
		ldi R26, low(dest)
		ldi R27, high(dest)

; while (number > 0) {
loop:
	
		; dest[count++] = number;
		st X+, number		


		; Register are loaded with the appropriate starting values
		ldi result, 0x00
		ldi tmp, 0x00
		ldi mask, 0x08
		ldi index, 4

; A loop used to get the result properly formatted
; in order to display the number on the microcontroller
LED_loop:
	
		mov tmp, mask		; copy the mask into a temp register
		and tmp, number		; isolate the next digit
		or result, tmp		; combine current result with previous results
		asr mask			; move the mask over by 1
		lsl result			; move the result over one
		
		dec index			;i--
		cpi index, 0		;if (index == 0) break

		brne LED_loop
			
		; * Output number on LEDs *		
.equ DDRL = 0x10A
.equ PORTL = 0x10B
		
		ldi R21, 0xFF		; set data direction
		sts DDRL, R21

		sts PORTL, result	; display the number on the LEDs

		

		; * delay approx 0.5 second *
		; Credit for this code segment (the following four lines)
		; goes to LillAnne Jackson, Ph.D.
		jmp past_loop

		ldi r24, 0x2A 
outer:	ldi r23, 0xFF
middle: ldi r22, 0xFF
inner:	dec r22

		brne inner
		dec r23
		brne middle
		dec r24
		brne outer
		; End .5 second delay
past_loop:

		; number --;
		dec number

		; repeat loop if number > 0
		cpi number, 0
		brne loop

		; store the final value of 0 in the destination
		st X, number

		; output the final value of 0
		sts PORTL, number

done:	rjmp done

.dseg
.org 0x200

dest: .BYTE 0x10	; reserve space to put the series of decreasing numbers
					; Note: this requires number+1 bytes
