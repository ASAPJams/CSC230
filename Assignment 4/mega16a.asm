.cseg

.equ DDRA = 0x1A
.equ PINA = 0x19
.equ PORTA = 0x1B
	
	ldi R16, 0b11001010
	out DDRA, R16
	out PINA, R16
	out PORTA, R16

	nop

.dseg
