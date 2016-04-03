/*
 * main.c
 */
#define __MAIN_C_dc83edef7fb74d0f88488010fe346ac7	1

#include "main.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

/* http://nongnu.org/avr-libc/user-manual/modules.html */
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>

#include <util/delay.h>


void init_cpu(void) {
  uint16_t clockcalibration;

  cli();
  bootupreason=MCUBOOTREASONREG;
  MCUBOOTREASONREG=0;
  wdt_disable();

#	if ((F_CPU) <= 8000000ULL)
  /* check if last word of eeprom contains clock calibration data */
  clockcalibration=eeprom_read_word((void*)((E2END)-1));
  if (clockcalibration != 0xffff) {
    /* calibrate the counter */
    OSCCAL=clockcalibration & 0xff;
  }
#	endif
}

int main(void) {
  init_cpu();

  // YOUR CODE HERE:


  return 0;
}