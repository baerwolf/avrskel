#ifndef F_CPU
	#error please define F_CPU with the correct clock-frequency of your MCU
#endif

#define ALLOWSOFTWARE_DOWNCLOCK	0

#ifndef USEDISPLAY
#	define USEDISPLAY		0
#endif


#include "defines.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include <string.h>
#include <alloca.h>

#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

#include <util/delay.h>

#if USEDISPLAY
#include "libs/lcd.h"

FILE lcdstream = FDEV_SETUP_STREAM(lcd_putchar, NULL, _FDEV_SETUP_WRITE);

static volatile uint16_t counter = 0;

/* make strings flash-accessable instead of RAM */
static const char lcdmessage[] PROGMEM = "tinyUSBboard:\thello world";
#endif

void __attribute__ ((naked))  __attribute__ ((section (".init1"))) __init1(void);
void __init1(void) {
#if (defined (__AVR_ATmega1284P__) && (ALLOWSOFTWARE_DOWNCLOCK))
asm volatile (
    "ldi r30, %[clkpce]\n\t"
    "ldi r31, %[divider]\n\t"
    "st  Y, r30\n\t"
    "st  Y, r31\n\t"
    "wdr\n\t"
    :
    : "y" (_SFR_MEM_ADDR(CLKPR)),
      [clkpce]  "M" ((1<<CLKPCE)),
      // divide clock by (2^3 =) 8 to lower clock
      [divider] "M" ((1<<CLKPS1) | (1<<CLKPS0))
     );
#endif
}

/*
 * Under normal circumstances, RESET will not clear contents of RAM.
 * As always, if you want it done - do it yourself...
 */
void __attribute__ ((naked))  __attribute__ ((section (".init3"))) __init3(void);
void __init3(void) {
  extern size_t __bss_end;
  asm volatile (
    "__clearram:\n\t"
    "ldi r29, %[ramendhi]\n\t"
    "ldi r28, %[ramendlo]\n\t"
    "__clearramloop%=:\n\t"
    "st -Y , __zero_reg__\n\t"
    "cp  r28, %A[bssend]\n\t"
    "cpc r29, %B[bssend]\n\t"
    "brne __clearramloop%=\n\t"
    :
    : [ramendhi] "M" (((RAMEND+1)>>8) & 0xff),
      [ramendlo] "M" (((RAMEND+1)>>0) & 0xff),
      [bssend]   "r" (&__bss_end)
    : "memory"
      );
}

#if USEDISPLAY
void printmessage(void) {
  char *buffer = alloca(strlen_PF(lcdmessage)+1);
  if (buffer) {
    /* move the string into the RAM */
    strcpy_PF(buffer, lcdmessage);
    /* print it from RAM */
    printf("%s",buffer);
    /* since "buffer" is on stack, we do not need to free ... */
  }
}
#endif

int main(void)
{
    wdt_enable(WDTO_1S);
    cli();

#if USEDISPLAY
    lcd_init();
    stdout = stderr = &lcdstream;
    printmessage();
#endif

    /* see defines.h for detailed MACRO definitions */
    SET_PIN_OUT(TINYUSBBOARD_LED3);
    SET_PIN_IN(TINYUSBBOARD_PROGBUTON);
    
    /* activate pull-up resistor for progbutton */
    SET_OUTPUT_HIGH(TINYUSBBOARD_PROGBUTON);

    while(1)
    {
      wdt_reset();

#if USEDISPLAY
	printf("\n");
	printmessage();
#endif

      /* when "prog" is pushed, "TINYUSBBOARD_PROGBUTON" becomes low (zero) */
      if (GET_INPUT(TINYUSBBOARD_PROGBUTON)) {
	TOGGLE_OUTPUT(TINYUSBBOARD_LED3); /* if not pushed - blink */
#if USEDISPLAY
	counter++;
	printf(" %04x",(int)counter);
#endif
      }
      _delay_ms(50); /* sleep 50ms */
    }

}

