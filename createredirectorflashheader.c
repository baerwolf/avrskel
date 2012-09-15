#include <stdlib.h>
#include <stdio.h>

#ifndef FLASHADDRESS
  #error You have to define the new startposition within the flash
#endif

#if ((FLASHADDRESS % 2) == 1)
  #error executable code only can be located on even addresses
#endif

#ifndef FLASHPREAMBLE
 #define FLASHPREAMBLE FLASHADDRESS
#endif

static int newsectionstart = FLASHADDRESS;



int main(int argc, char ** argv) {
        int i;

#if (FLASHPREAMBLE > 0)
	for (i=0;i<FLASHPREAMBLE;i++) {
	  fputc(0xff, stdout);
	}
#endif

        for (i=0;i<19;i++) {
                unsigned short opcode;
                opcode = newsectionstart-2;  // subtract length of opcode
                
                opcode >>= 1; // operand is in words, not bytes!
                
                opcode &= 0xfff;
                opcode |= (0xc << 12);         // RJMP

                fputc((opcode>>0)&0xff, stdout);
		fputc((opcode>>8)&0xff, stdout);

        }

        return 0;
}

