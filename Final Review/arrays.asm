;for(i = 0; i < 10; i++)
;	arr[i] = i + 14

.cseg

	ldi r16, 0
	ldi r18, 14
	ldi r30, low(arr)
	ldi r31, high(arr)
loop:
	cpi r16, 10
	breq done_Loop
	mov r17, r16
	add r17, r18
	st Z+, r17
	inc r16
	rjmp loop


done_Loop: rjmp done_Loop

.dseg
.org 0x200
arr: .byte 10
