AS = ca65
CC = cc65
LD = ld65

.PHONY: clean

build: tas.txt

%.o: %.asm
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@

payload_loader.nes: layout main.o
	$(LD) --dbgfile $@.dbg -C $^ -o $@

clean:
	rm -f payload_loader.nes *.dep *.o *.dbg *.nes

tas.txt: make_tas.js payload_loader.nes payload_ppu.bin payload_prg.bin payload_ram.bin
	node make_tas.js > tas.txt

include $(wildcard *.dep)
