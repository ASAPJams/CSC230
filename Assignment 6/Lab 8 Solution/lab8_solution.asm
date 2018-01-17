
.equ PORTB = 0x25
.equ DDRB = 0x24
.equ PORTL = 0x10B
.equ DDRL = 0x10A
.equ SPH=0x5E
.equ SPL=0x5D

; timer/counter 1
.equ TCCR1A = 0x80
.equ TCCR1B = 0x81
.equ TCCR1C = 0x82
.equ TCNT1H = 0x85
.equ TCNT1L = 0x84
.equ TIFR1  = 0x36
.equ TIMSK1 = 0x6F
.equ SREG	= 0x5F

.org 0x0000
	jmp setup

.org 0x0028
	jmp timer1_isr
    
.org 0x0050
	
setup:
	; setup stack pointer
	ldi r16, high(0x21FF)
	sts SPH, r16
	ldi r16, low(0x21FF)
	sts SPL, r16

	; set PORTL to output mode
	ldi r16, 0xFF
	sts DDRL, r16
	sts DDRB, r16

	; turn on one LED
	ldi r16, 0b00000010
	sts PORTL, r16

	; setup timer
	call timer_init

	; blink LEDs on PORTB
	call blink_LED

done:		
	rjmp done


; this subroutine runs once while interrupts are disabled
; no need to protect registers
; interrupts are enabled at the end, right before ret
timer_init:
	
	; timer mode is normal
	ldi r16, 0x00
	sts TCCR1A, r16

	; prescale 
	; Our clock is 16 MHz, which is 16,000,000 per second
	;
	; scale values are the last 3 bits of TCCR1B:
	;
	; 000 - timer disabled
	; 001 - clock (no scaling)
	; 010 - clock / 8
	; 011 - clock / 64
	; 100 - clock / 256
	; 101 - clock / 1024
	; 110 - external pin Tx falling edge
	; 111 - external pin Tx rising edge
	ldi r16, 0b00000100	; clock / 256
	sts TCCR1B, r16

	; set timer counter to 3035, leaving 62500 ticks till overflow
	; this is equal to exactly one second with 256 presecalar 
	; 16000000/256 = 0xFFFF - 3035
	ldi r16, 0x0B
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, 0xDB
	sts TCNT1L, r16		; low byte

	; enable timer interrupts (CPU interrupt on overflow)
	ldi r16, 0x01
	sts TIMSK1, r16

	; enable CPU interrupts (make it interruptable)
	sei

	ret


; timer interrupt flag is automatically
; cleared when this ISR is executed
; per page 168 ATmega datasheet
timer1_isr:
	; protect registers
	push r16
	push r17
	lds r16, SREG
	push r16

	; toggle LEDs
	lds r16, PORTL
	ldi r17, 0b00001010
	eor r16, r17
	sts PORTL, r16
		
	; reset timer counter to 3035, to make it one second exactly
	ldi r16, 0x0B
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, 0xDB
	sts TCNT1L, r16		; low byte
		
	; restore registers
	pop r16
	sts SREG, r16
	pop r17
	pop r16
	reti


; this subroutine runs in an infinite loop
; no need to protect registers
; never returns
blink_LED:
	; turn on LED
	ldi r19, 0b00000010
	sts PORTB, r19

	; wait approximately 30 seconds
	ldi r20, 0x40
del1:
	nop
	ldi r21,0xFF
del2:
	nop
	ldi r22, 0xFF
del3:
	nop
	dec r22
	brne del3
	dec r21
	brne del2
	dec r20
	brne del1	

	; turn off LED
	ldi r19, 0x00
	sts PORTB, r19

	; wait approximately 30 seconds
	ldi r20, 0x40
del1_2:
	nop
	ldi r21,0xFF
del2_2:
	nop
	ldi r22, 0xFF
del3_2:
	nop
	dec r22
	brne del3_2
	dec r21
	brne del2_2
	dec r20
	brne del1_2
			
	rjmp blink_LED
