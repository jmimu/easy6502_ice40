.alias oldframe $fc
.alias frame $fd

.org  $0600

    LDX #$00
    LDY #$00
loop:
    TYA
    STA $0200,X
    INX
    INY
    CPY #$20
    BNE +
    INY ; colorshift
*

waitframe:
    lda frame
    cmp oldframe
    bne waitframe
    sta oldframe


    JMP loop
