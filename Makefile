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







all:  main.hex


main.o: main.c
	$(CC) main.c -c -o main.o $(MYCFLAGS)

main.elf: main.o
	$(CC) main.o -o main.elf $(MYCFLAGS) $(MYLDFLAGS)

main.hex: main.elf
	$(OBC) -j .text -j .data -O ihex main.elf main.hex
	$(ECHO) "."
	$(SIZ) main.elf
	$(ECHO) "."
	$(AVRDUDE) -D -U flash:w:main.hex:i
	$(ECHO) "."


trampoline: flashheadertool
flashheader: flashheadertool

flashheadertool: createredirectorflashheader.c
	$(GCC) -O0 -ggdb -g3 -o flashheadertool createredirectorflashheader.c -DFLASHADDRESS=$(FLASHADDRESS) $(FLASHPREAMBLEDEFINE)
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
