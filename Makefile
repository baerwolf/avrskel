F_CPU = 16000000
DEVICE = atmega8
FLASHADDRESS = 0x0000

PROGRAMMER = -c usbasp
#PROGRAMMER = -c pony-stk200

CC=@avr-gcc
RM=@rm -f
OBC=@avr-objcopy
ECHO=@echo
AVRDUDE = $(ECHO) CALL: avrdude $(PROGRAMMER) -p $(DEVICE)


CFLAGS = -Wall -Os -fno-move-loop-invariants -fno-tree-scev-cprop -fno-inline-small-functions -I. -mmcu=$(DEVICE) -DF_CPU=$(F_CPU) $(DEFINES)
LDFLAGS = -Wl,--relax,--gc-sections

ifneq ($(FLASHADDRESS), 0)
ifneq ($(FLASHADDRESS), 00)
ifneq ($(FLASHADDRESS), 000)
ifneq ($(FLASHADDRESS), 0000)
ifneq ($(FLASHADDRESS), 00000)
ifneq ($(FLASHADDRESS), 0x0)
ifneq ($(FLASHADDRESS), 0x00)
ifneq ($(FLASHADDRESS), 0x000)
ifneq ($(FLASHADDRESS), 0x0000)
ifneq ($(FLASHADDRESS), 0x00000)
FLASHPREAMBLE = 0x0000
LDFLAGS += -Wl,--section-start=.text=$(FLASHADDRESS)
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif

all:  main.hex


main.o: main.c
	$(CC) main.c -c -o main.o $(CFLAGS)

main.elf: main.o
	$(CC) main.o -o main.elf $(CFLAGS) $(LDFLAGS)

main.hex: main.elf
	$(OBC) -j .text -j .data -O ihex main.elf main.hex
	$(ECHO) "."
	avr-size main.elf
	$(ECHO) "."
	$(AVRDUDE) -D -U flash:w:main.hex:i
	$(ECHO) "."


trampoline: flashheadertool
flashheader: flashheadertool

flashheadertool: createredirectorflashheader.c
	@gcc -O0 -ggdb -g3 -o flashheadertool createredirectorflashheader.c -DFLASHADDRESS=$(FLASHADDRESS) -DFLASHPREAMBLE=$(FLASHPREAMBLE)
	./flashheadertool > flashheader.bin
	$(ECHO) "."
	$(AVRDUDE) -D -U flash:w:flashheader.bin:r
	$(ECHO) "."

deepclean: clean
	$(RM) *~

clean:
	$(RM) *.o
	$(RM) main.hex
	$(RM) main.elf
	$(RM) flashheader.bin
	$(RM) flashheadertool