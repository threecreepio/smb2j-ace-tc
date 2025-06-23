.include "inc.s"

.segment "PRG"
.org $0

.res $50-*,$00
: jsr $e1b2 ; vintwait
  jsr $e9eb ; read joypad
  lda $f5
  ldx $6c
  sta $200,x
  inc $6c
  bpl :-
  jmp $200


.res $200-*,$00
  lda #0
  tay
  sta PPU_CTRL_REG1
  sta PPU_CTRL_REG2
  sta $4015
  sta $10
  sta $11

  ; copy ZP
  ;lda #1
  ;sta $12
  ;jsr ramcpy
  
  ;; copy $300-$7FF
  lda #3
  sta $11
  lda #8
  sta $12
  jsr ramcpy

  ; copy PRG
  lda #$60
  sta $11
  lda #$E0
  sta $12
  jsr ramcpy

  ; copy PPU
  lda #0
  sta $11
  lda #$20
  sta $12
: jsr nextframe
  lda $11
  sta PPU_ADDRESS
  lda $10
  sta PPU_ADDRESS
  lda $f5
  sta PPU_DATA
  lda $f6
  sta PPU_DATA
  jsr advance
  bcc :-

  jmp ($fffc)

ramcpy:
: jsr nextframe
  lda $f5
  sta ($10),y
  iny
  lda $f6
  sta ($10),y
  dey
  jsr advance
  bcc :-
  rts

nextframe:
  jsr $e1b2 ; vintwait
  jmp $e9eb ; read joypad
  
advance:
  clc
  inc $10
  inc $10
  bne :+
  inc $11
  lda $11
  cmp $12
: rts

.res $280-*,$00

