.org  $0600

l1: ; start color loop
    LDY #$10
l2: ; start line
    LDX #$00

    CLC
    LDA #$00
    delay1:
      ADC #$00
      ADC #$00
      ADC #$00
      ADC #$00
      ADC #$01
      BCC delay1

l3: ; draw pix
    TYA
    STA $0241,X
    STA $05A1,X
    INX
    
    CPX #$1E ; end of line
    BNE l3
    
    INY ; colorshift
    CPY #$20 ; end of color loop
    BNE l2

    JMP l1
