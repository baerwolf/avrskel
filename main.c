#ifndef F_CPU
  #define F_CPU 1000000UL /* 1 Mhz-Takt; hier richtigen Wert eintragen */
#endif

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

