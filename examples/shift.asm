.org  $0600

    LDX #$00
    LDY #$00
loop:
    TYA
    STA $0200,X
    INX
    INY
    CPY #$20
    BNE next
    INY ; colorshift
next:
    JMP loop
