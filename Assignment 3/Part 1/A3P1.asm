.include "m2560def.inc"
;
; ***********************************************************
; * CSC 230, Assignment 3 part A *
; * A3P1.asm, a formative program that adds 3 constants and stores the result *
; * Jamie Kirkwin, V00875987, 9/27/2017 *
; *********************************************************
; *************************
; * Code segment follows: *
; *************************
.cseg
;************************
; Your code starts here:

;defined the sum register for clarity
.def sum = R19

	;number1 = 27
	ldi R16, 27	

	;number2 = 41
	ldi R17, 41

	;number3 = 15
	ldi R18, 15

	;sum = 0
	ldi sum, 0

	;sum += number1
	add sum, R16	

	;sum += number2
	add sum, R17
	
	;sum += number3;
	add sum, R18

	;result = sum
	sts 0x0200, sum

; Your code finishes here.
;*************************
done: jmp done
; *************************
; * Data segment follows: *
; *************************
.dseg
.org 0x200
result: .db 1
