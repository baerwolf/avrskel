#######################################################################################

# environment variable of the current user to locate the AVR8 toolchain
AVRPATH = $(AVR8TOOLCHAINBINDIR)

# the type of avr microcontroller
DEVICE = atmega8

# the frequency the microcontroller is clocked with
F_CPU = 16000000

# where the firmware should be located within the flashmemory (in case you trampoline)
FLASHADDRESS = 0x0000

# (not important for compiling) - the device transporting firmware into the controller
#PROGRAMMER = -c pony-stk200
PROGRAMMER = -c usbasp

#######################################################################################



# Tools:
ECHO=@echo
GCC=gcc
MAKE=@make
RM=@rm -f

CC=$(AVRPATH)avr-gcc
OBC=@$(AVRPATH)avr-objcopy
OBD=@$(AVRPATH)avr-objdump
SIZ=@$(AVRPATH)avr-size

AVRDUDE = $(ECHO) CALL: avrdude $(PROGRAMMER) -p $(DEVICE)


MYCFLAGS = -Wall -Os -fno-move-loop-invariants -fno-tree-scev-cprop -fno-inline-small-functions -I. -mmcu=$(DEVICE) -DF_CPU=$(F_CPU) $(CFLAGS)   $(DEFINES)
MYLDFLAGS = -Wl,--relax,--gc-sections $(LDFLAGS)


FLASHPREAMBLEDEFINE = 
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
FLASHPREAMBLEDEFINE = -DFLASHPREAMBLE=$(FLASHPREAMBLE)
MYLDFLAGS += -Wl,--section-start=.text=$(FLASHADDRESS)
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







all:  main.hex main.raw main.asm

hd44780.o: libs/hd44780.c libs/hd44780.h
	$(CC) libs/hd44780.c -c -o hd44780.o $(MYCFLAGS)

lcd.o: libs/lcd.c libs/lcd.h
	$(CC) libs/lcd.c -c -o lcd.o $(MYCFLAGS)

main.o: main.c
	$(CC) main.c -c -o main.o $(MYCFLAGS)

main.elf: main.o lcd.o hd44780.o
	$(CC) main.o lcd.o hd44780.o -o main.elf $(MYCFLAGS) $(MYLDFLAGS)
	$(ECHO) "."
	$(SIZ) main.elf
	$(ECHO) "."

main.hex: main.elf
	$(OBC) -j .text -j .data -O ihex main.elf main.hex

main.raw: main.elf
	$(OBC) -j .text -j .data -O binary main.elf main.raw

main.asm: main.elf
	$(OBD) -d main.elf > main.asm

disasm: main.elf
	$(OBD) -d main.elf

flash: main.hex
	$(ECHO) "."
	$(AVRDUDE) -D -U flash:w:main.hex:i
	$(ECHO) "."

deepclean: clean
	$(RM) libs/*~
	$(RM) *~

clean:
	$(RM) *.o
	$(RM) main.hex
	$(RM) main.raw
	$(RM) main.asm
	$(RM) main.elf
