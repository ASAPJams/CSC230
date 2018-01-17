;
; params.asm
;
; An example to illustrate passing parameters via
; the stack.
;

; The stack pointer is in I/O space, so if we 
; want to use LDS and STS instructions we have to
; use the alternate addresses.
;
; SPH is 0x3E if using IN/OUT and 0x5E if using LDS/STS
; SPL is 0x3D if using IN/OUT and 0x5D if using LDS/STS
;
.equ SPH=0x5E
.equ SPL=0x5D

;
; The Z register is the combination of
; R30:R31
;
.def ZH=r31
.def ZL=r30



		; initialize the stack pointer

		ldi r16, 0xFF
		sts SPL, r16
		ldi r16, 0x21
		sts SPH, r16
		
		; call the subroutine
		; Note that it is the caller's responsibility
		; to push the parameters on the stack before
		; the call and pop the parameters from the
		; stack after the call
		;
		; push the first parameter		
		ldi r16, 0xEE
		push r16
		; push the second parameter
		ldi r16, 0xCC
		push r16
		call do_something
		; now that the subroutine has returned
		; pop the parameters we previously pushed
		pop r16
		pop r16
		; At this point, the stack is empty, which
		; is what we want.

lp:		jmp lp

;
; do_something
; 
; This subroutine demonstrates using the stack to pass
; parameters and using the stack to 'protect' registers
; that are used in the subroutine.
;
; By protecting registers this subroutine uses, the callers
; are free to use any registers.
;
;
; After the Z register is set to be the stack pointer, the
; stack frame looks like:
;
; |      | <- Z and SP
; | r1   |  saved register
; | r0   |  saved register
; | r31  |  saved register 
; | r30  |  saved register
; | ret  |  return address
; | ret  |  return address
; | ret  |  return address
; | 0xCC |  parameter (Z + 8)
; | 0xEE |  parameter (Z + 9)
;
do_something:
		; first protect the Z register, since we will use it
		push r30
		push r31
		; now protect r0 and r1 since they will be used
		; to store the parameters
		push r0
		push r1

		; put the stack pointer into the Z register
		lds ZH, SPH
		lds ZL, SPL
	
		; get the 1st parameter pushed on the stack:
		ldd r0, Z+9
		; get the 2nd parameter pushed on the stack:
		ldd r1, Z+8

		; In a real subroutine you would now
		; do whatever you needed to do with the
		; parameters here
		
					
ds_end: ; This is where we return from the subroutine
		; restore the registers protected on entry
		; into the subroutine
		pop r1
		pop r0
		pop r31
		pop r30
		ret

; 
