/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <joerg@FreeBSD.ORG> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.        Joerg Wunsch
 * 
 * extended-by: Stephan Baerwolf
 * ----------------------------------------------------------------------------
 *
 * General stdiodemo defines
 *
 * $Id: defines.h 2186 2010-09-22 10:25:15Z aboyapati $
 */

#ifndef __DEFINES_H_1c0fdb4cd9ec4e16951610dd60361c6a
#define __DEFINES_H_1c0fdb4cd9ec4e16951610dd60361c6a 1

#include <avr/sfr_defs.h>

/* UART baud rate */
#define UART_BAUD		9600

/* some abstract output-pin names */

/* HD44780 LCD port connections */
#define HD44780_RS		B, 3
#define HD44780_RW		B, 4
#define HD44780_E		B, 5

/* The data bits have to be not only in ascending order but also consecutive. */
#define HD44780_D4		C, 0



#define	TINYUSBBOARD_LED1	B, 0
#define	TINYUSBBOARD_LED2	B, 1
#define	TINYUSBBOARD_LED3	D, 5
#define	TINYUSBBOARD_LED4	D, 3
#define	TINYUSBBOARD_PROGBUTON	D, 7


/* Whether to read the busy flag, or fall back to
   worst-time delays. */
#define USE_BUSY_BIT 1







/* some makros improving the world */

#define GLUE(a, b)     a##b
#define	PINMAKRO(a,b)	P##a##b

#define		PORTNAME(a,b)		GLUE(PORT, a)
#define		DDRNAME(a,b)		GLUE(DDR, a)
#define		PINNAME(a,b)		GLUE(PIN, a)
#define		PINNR(a,b)		(b)

/* single-bit macros, used for control bits */
#define SET_(what, p, m) GLUE(what, p) |= (_BV(m))
#define CLR_(what, p, m) GLUE(what, p) &= ~(_BV(m))
#define TGL_(what, p, m) GLUE(what, p) ^= (_BV(m))
#define GET_(/* PIN, */ p, m) GLUE(PIN, p) & (_BV(m))

#define SET(what, a, b)		SET_(what, a, PINMAKRO(a,b))
#define CLR(what, a, b)		CLR_(what, a, PINMAKRO(a,b))
#define TGL(what, a, b)		TGL_(what, a, PINMAKRO(a,b))
#define GET(/* PIN, */ a, b)	GET_(a, PINMAKRO(a,b))


#define		SET_PIN_OUT(a)		SET(DDR, a)
#define		SET_PIN_IN(a)		CLR(DDR, a)

#define		GET_INPUT(a)		GET(a)
#define		SET_OUTPUT_HIGH(a)	SET(PORT, a)
#define		SET_OUTPUT_LOW(a)	CLR(PORT, a)
#define		TOGGLE_OUTPUT(a)	TGL(PORT, a)




#endif