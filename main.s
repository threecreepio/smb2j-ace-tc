.segment "PRG"
.org $0

PPU_CTRL_REG1         = $2000
PPU_CTRL_REG2         = $2001
PPU_ADDRESS           = $2006
PPU_DATA              = $2007
SND_MASTERCTRL_REG    = $4015

FDSBIOS_VINTWAIT      = $E1B2
FDSBIOS_READPADS      = $E9EB
READPADS_CTL1         = $F5
READPADS_CTL2         = $F6

TRAMP_LOCATION        = $50
TRAMP_INDEX           = $6C

EXEC_LOCATION         = $200
EXEC_SRC_LO           = $10
EXEC_SRC_HI           = $11
EXEC_END              = $12

.res TRAMP_LOCATION-*,$00
: jsr FDSBIOS_VINTWAIT
  jsr FDSBIOS_READPADS
  ldx TRAMP_INDEX
  lda READPADS_CTL1
  sta EXEC_LOCATION,x
  inc TRAMP_INDEX
  bpl :-
  jmp EXEC_LOCATION


.res EXEC_LOCATION-*,$00
  lda #0
  tay
  sta PPU_CTRL_REG1
  sta PPU_CTRL_REG2
  sta SND_MASTERCTRL_REG
  sta $10
  sta $11

  ; copy ZP
  ;lda #1
  ;sta EXEC_END
  ;jsr ramcpy
  
  ;; copy $300-$7FF
  lda #3
  sta EXEC_SRC_HI
  lda #8
  sta EXEC_END
  jsr ramcpy

  ; copy PRG
  lda #$60
  sta EXEC_SRC_HI
  lda #$E0
  sta EXEC_END
  jsr ramcpy

  ; copy PPU
  lda #0
  sta EXEC_SRC_HI
  lda #$20
  sta EXEC_END
: jsr nextframe
  lda EXEC_SRC_HI
  sta PPU_ADDRESS
  lda EXEC_SRC_LO
  sta PPU_ADDRESS
  lda READPADS_CTL1
  sta PPU_DATA
  lda READPADS_CTL2
  sta PPU_DATA
  jsr advance
  bcc :-

  jmp ($fffc)

ramcpy:
: jsr nextframe
  lda READPADS_CTL1
  sta (EXEC_SRC_LO),y
  iny
  lda READPADS_CTL2
  sta (EXEC_SRC_LO),y
  dey
  jsr advance
  bcc :-
  rts

nextframe:
  jsr FDSBIOS_VINTWAIT
  jmp FDSBIOS_READPADS
  
advance:
  clc
  inc EXEC_SRC_LO
  inc EXEC_SRC_LO
  bne :+
  inc EXEC_SRC_HI
  lda EXEC_SRC_HI
  cmp EXEC_END
: rts

.res (EXEC_LOCATION+$80)-*,$EA
