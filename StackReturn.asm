stackReturn:	;returns 0 if the values passed in are both even or both odd, and FF otherwise
	push r16
	push r17
	push r18
	push r30
	push r31

	;point Z to SP
	in r30, spl
	in r31, sph

	;params are at Z+8, Z+9
	ldd r16, Z+9
	ldd r17, Z+10

	;clear all but 0th bit
	ldi r18, 1
	and r16, r18
	and r17, r18
	
	;we will put the result in r18.
	cp r16, r17
	brne different
same:
	ldi r16, 0		
	rjmp done_Different

different:
	ldi r16, 0xFF

done_Different:
	;now we need to get r16's contents onto the stack, underneath the return address

	;idea: 	starting at the top of the stack, move each item up by one
	;		then put r16's contents in 
	
	ldi r18, 8
loop:
	cpi r18, 0
	breq doneLoop
	dec r18

	;loop this 8 times
	ldd r17, Z+1
	st Z, r17
	inc r30 ;Z++
	rjmp loop

doneLoop:		

	;now put the return value on the stack, below the return values	
	;Z points to where we want to put the value
	st Z, r16		

	;now  decrement SP and pop back protected registers
	
	;Stack Pointer should be at SP-1
	;sub 1 from spl, subc0 to sph
	in r16, spl
	in r17, sph
	ldi r18, 0
	dec r16
	sbc r17, r18
	out spl, r16
	out sph, r17

	pop r31
	pop r30
	pop r18
	pop r17
	pop r16

ret
