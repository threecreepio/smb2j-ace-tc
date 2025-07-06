# SMB2J ACE Total Control

Not really documenting this much, but this project creates TAS inputs that can be combined with the SMB2J ACE setup to rewrite a bunch of cpu and ppu memory, that was you can load in another game, for example.

Example: https://www.youtube.com/watch?v=9LROCd7102Y

By default the 'payload_ppu.bin' will be written to the PPU at $0000-$1FFF, 'payload_cpu.bin' will be written to $6000-$DFFF, 'payload_ram' will write $300-$7FF

main.s contains two programs, the first gets very slowly loaded in at $50, that will then continually read in the second program using controller 1 inputs. after that the secondary does the heavy lifting of copying in the payloads and resetting.

make_tas.js takes all the data and converts it to FCEUX tas inputs for each stage, that can then be copied and pasted into the FCEUX tas editor.

you can run 'make' or look at the Makefile to see how to run the build and generate the tas.

Prerequities:
You will need to have 96 coins, be sure to take a step to left before the ACE inputs start, and set up fireball shots so that memory location $8D is the value $94 and $8E is the value $A5. There is an FM2 file that contains a working example.

Good luck!
/threecreepio
