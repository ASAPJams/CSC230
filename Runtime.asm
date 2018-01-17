.cseg

	ldi r23, 0xFF
outer:
	ldi r22, 0xFF
inner:
	nop
	nop
	nop
	nop
	nop
	dec r22

	brne inner

	dec r23

	brne outer

	nop	

done: rjmp done

