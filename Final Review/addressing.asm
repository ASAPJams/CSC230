.cseg
.def gang = r16
.def shit = r17
; store real, gang, shit in label, then put their sum in 
	ldi r30, low(real<<1)
	ldi r31, high(real<<1)
	
	lpm r20,  Z+
	inc r30
	lpm gang, Z+
	inc r30
	lpm shit, Z

	sts	label, 	 r20
	sts	label+1, gang
	sts	label+2, shit

	mov r21, r20
	add r21, gang
	add r21, shit
	
	ldi r28, low(label+3)
	ldi r29, high(label+3)
	
	st	Y, r21


done: 
	rjmp done

real: 	.db 0x11
		.db 0x01
		.db 0x10

.dseg
.org 0x200
label: .byte 4
