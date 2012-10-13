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

AS=$(AVRPATH)avr-as
LD=$(AVRPATH)avr-ld
CC=$(AVRPATH)avr-gcc
OBC=@$(AVRPATH)avr-objcopy
OBD=@$(AVRPATH)avr-objdump
SIZ=@$(AVRPATH)avr-size

AVRDUDE = $(ECHO) CALL: avrdude $(PROGRAMMER) -p $(DEVICE)


MYCFLAGS = -I. -mmcu=$(DEVICE)  $(CFLAGS)   $(DEFINES)
MYLDFLAGS = $(LDFLAGS)


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
MYLDFLAGS += --section-start=.text=$(FLASHADDRESS)
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







all:  main.elf

main.elf: main.S
	$(AS) $(MYCFLAGS)   main.S -o main.o
	$(LD) $(MYLDFLAGS)  main.o -o main.elf
	$(OBC) -j .text -j .data -O ihex main.elf main.hex
	$(OBC) -j .text -j .data -O binary main.elf main.raw


disasm: main.elf
	$(OBD) -d main.elf

deepclean: clean
	$(RM) *~

clean:
	$(RM) *.o
	$(RM) main.out
	$(RM) main.raw
	$(RM) main.hex
	$(RM) main.elf
