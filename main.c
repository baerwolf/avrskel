#ifndef F_CPU
	#error please define F_CPU with the correct clock-frequency of your MCU
#endif

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include <avr/io.h>
#include <avr/wdt.h>


int main(void)
{
    wdt_enable(WDTO_1S);



    while(1)
    {
      wdt_reset();
    }

}

