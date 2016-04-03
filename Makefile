#######################################################################################

# environment variable of the current user to locate the AVR8 toolchain
AVRPATH = $(AVR8TOOLCHAINBINDIR)

# the type of avr microcontroller
DEVICE = atmega8
EFUSE  = ""
HFUSE  = 0xd9
LFUSE  = 0xe1

# the frequency the microcontroller is clocked with
F_CPU = 1000000

# extra data section
# DEFINES += -D__AVR_LIBC_DEPRECATED_ENABLE__
# DEFINES += -DDATASECTION=__attribute__\ \(\(section\ \(\".extradata\"\)\)\)
# LDFLAGS += -Wl,--section-start=.extradata=0x6000

# where the firmware should be located within the flashmemory (in case you trampoline)
FLASHADDRESS = 0x0000

# (not important for compiling) - the device transporting firmware into the controller
PROGRAMMER = -c usbasp

#######################################################################################



# Tools:
ECHO=@echo
GCC=gcc
MAKE=@make
RM=@rm -f

DOX=@doxygen

CC=$(AVRPATH)avr-gcc
OBC=@$(AVRPATH)avr-objcopy
OBD=@$(AVRPATH)avr-objdump
SIZ=@$(AVRPATH)avr-size

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
AVRDUDE_FUSE = -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m
ifneq ($(EFUSE), "")
AVRDUDE_FUSE += -U efuse:w:$(EFUSE):m
endif


MYCFLAGS = -Wall -g3 -ggdb -Os -fno-move-loop-invariants -fno-tree-scev-cprop -fno-inline-small-functions -ffunction-sections -fdata-sections -I. -Isource -mmcu=$(DEVICE) -DF_CPU=$(F_CPU) $(CFLAGS)   $(DEFINES)
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




STDDEP	 = *.h source/*.h
EXTRADEP = Makefile


all: release/main.hex release/eeprom.hex release/main.bin release/eeprom.bin release/main.asm build/main.asm



build/main.o: source/main.c $(STDDEP) $(EXTRADEP)
	$(CC) source/main.c -c -o build/main.o $(MYCFLAGS)





MYOBJECTS = build/main.o
release/main.elf: $(MYOBJECTS) $(STDDEP) $(EXTRADEP)
	$(CC) $(MYOBJECTS) -o release/main.elf $(MYCFLAGS) -Wl,-Map,release/main.map $(MYLDFLAGS)
	$(ECHO) "."
	$(SIZ) release/main.elf
	$(ECHO) "."

release/main.asm: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBD) -d release/main.elf > release/main.asm

build/main.asm: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBD) -dS release/main.elf > build/main.asm

release/main.hex: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBC) -R .eeprom -R .fuse -R .lock -R .signature -O ihex release/main.elf release/main.hex

release/eeprom.hex: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBC) -j .eeprom -O ihex release/main.elf release/eeprom.hex

release/main.bin: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBC) -R .eeprom -R .fuse -R .lock -R .signature -O binary release/main.elf release/main.bin

release/eeprom.bin: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBC) -j .eeprom -O binary release/main.elf release/eeprom.bin

disasm: release/main.elf $(STDDEP) $(EXTRADEP)
	$(OBD) -d release/main.elf

fuse:
	$(ECHO) "."
	$(AVRDUDE) $(AVRDUDE_FUSE)
	$(ECHO) "."

flash: all
	$(ECHO) "."
	$(AVRDUDE) -U flash:w:release/main.hex:i
	$(ECHO) "."

eeprom: all
	$(ECHO) "."
	$(AVRDUDE) -D -U eeprom:w:release/eeprom.hex:i
	$(ECHO) "."

deepclean: clean
	$(RM) source/*~
	$(RM) *~

clean:
	$(RM) build/*
	$(RM) release/*
