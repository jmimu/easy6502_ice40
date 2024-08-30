.org  $0600

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
      ADC #$00
      ADC #$00
      ADC #$00
      ADC #$00
      ADC #$00
      ADC #$00
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
    STA $0241,X
    STA $05A1,X
    INX
    INY ; colorshift
    CPY #$20 ; end of color loop
    BNE next
    LDY #$10    
   next:
    CPX #$1E ; end of line
    BNE l3
    JMP l2
