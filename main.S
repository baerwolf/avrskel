#include <avr/io.h> 

; assembler-only example for atmega8 at 16MHz
; will PWM-fade output on PB3

__SREG__ = 0x3f
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__CCP__ = 0x34
__tmp_reg__ = 0
__zero_reg__ = 1

__DDRB__ = 0x17
__PORTB__ = 0x18

__OCR2__ = 0x23
__TCCR2__ = 0x25

__MCUCR__ = 0x35
__WDTCR__ = 0x21

__TCNT0__ = 0x32
__TIFR__ = 0x38
__TIMSK__ = 0x39
__TCCR0__ = 0x33


RAMEND = 0x45f
RAMPTR_START = 0x60

RAMPTR_JIFFIES128	= RAMPTR_START+0x0000
RAMPTR_DIRECTION	= RAMPTR_START+0x0010

.section	.text
.global		__start

	; every firmware starts with its interrupt table
	; atmega8 has 19 sources of interrupt
__vectors:
	rjmp	__start
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_timer0_overflow
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore
	rjmp	_intterupt_ignore


__start:
	wdr
	eor	__zero_reg__,	__zero_reg__	; r1=0
	out	__SREG__,	__zero_reg__	; clear processor status
	ldi	r28,		lo8(RAMEND)	; 
	ldi	r29,		hi8(RAMEND)	; (r29:28) Y <-- 0x45f (last address of RAM)
	out	__SP_H__,	r29		; 
	out	__SP_L__, 	r28		; place stackpointer pointing to last addressof RAM


	; !! CLEAR ALL THE SRAM !!
	; now clear all the SRAM to defined state of "0x00"
	; Y (r29:r28) is still set to last RAM address
	st	Y,		__zero_reg__	; fill the last byte in a special fashion
__start_eraseSRAM_loop:
	wdr
	st	-Y,		__zero_reg__
	andi	r29,		0xff		; just to generate a possible zeroflag for the hi8(Y)
	brne	__start_eraseSRAM_loop
	cpi	r28,		RAMPTR_START	; do not reloop if we reached the SRAMs first address
	brne	__start_eraseSRAM_loop

	; SRAM is clean now, Y will be zeroed...
	eor	r28,		r28

main:
	wdr
	ldi	r17,		0x08
	out	__DDRB__,	r17		; LED on PB3 --> so PB3 is an output!

	;we do not want to switch on directly - instead use PWM
	out	__OCR2__,	__zero_reg__	; full power
	ldi	r17,		0x79		; power timer2 on
	out 	__TCCR2__,	r17

	;deactivate the watchdog timer
	in	r17,		__WDTCR__
	ori	r17,		0x18
	out	__WDTCR__,	r17
	out	__WDTCR__,	__zero_reg__

	;activate timer0 with prescaler
	out	__TCNT0__,	__zero_reg__

	in	r17,		__TIFR__
	andi	r17,		0xfe
	out	__TIFR__,	r17

	in	r17,		__TIMSK__
	ori	r17,		0x01
	out	__TIMSK__,	r17

	ldi	r17,		0x01		; (prescaler) as fast as possible
	out	__TCCR0__,	17


	sei

_fin:
	ldi	r17,		0x80
	out	__MCUCR__,	r17
	sleep
/* 	rcall	inc_jiffies128_loop */
	rjmp	_fin



;subroutines
inc_jiffies128:
	push	__tmp_reg__			; otherwise interrupts may poison code
	push	r27
	ldi	r27,		hi8(RAMPTR_JIFFIES128)
	push	r26
	ldi	r26,		lo8(RAMPTR_JIFFIES128)
	push	r17
	ldi	r17,		0x10
	clr	r0
	sec
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inc_jiffies128_loop:
	ld	r0,		X
	adc	r0,		__zero_reg__
	st	X+,		r0
	dec	r17
	brne	inc_jiffies128_loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pop	r17
	pop	r26
	pop	r27
	pop	__tmp_reg__
	ret




;interrupt subroutines
_intterupt_ignore:
	reti

_intterupt_timer0_overflow:
	push	r17					; save r17 onto stack

	lds	r17,		RAMPTR_JIFFIES128	; load LSB of our global 128bit jiffy-counter into r17
	cpi	r17,		0x00
	brne	_intterupt_timer0_overflow_finished	; skip the increment of LED-intensity if LSB is not ZERO

	lds	r17,		RAMPTR_JIFFIES128+2
	andi	r17,		0x01
	lds	r17,		RAMPTR_JIFFIES128+1	; the fade of the LED - ATTANTION lds MUST NOT DESTROY ZEROFLAG
	brne	_intterupt_timer0_overflow_viceversacount
	com	r17

_intterupt_timer0_overflow_viceversacount:
	out	__OCR2__,	r17

_intterupt_timer0_overflow_finished:
	pop	r17
	rcall	inc_jiffies128				; increment our internal 128Bit counter		
	reti
