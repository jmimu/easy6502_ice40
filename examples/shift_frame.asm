.alias oldframe $fc
.alias frame $fd

.org  $0600

    LDX #$00
    LDY #$00
loop:
    TYA
    STA $0200,X
    INX
    
    jsr waitframe
    
    INY
    CPY #$20
    BNE +
    INY ; colorshift
*
    JMP loop
    
waitframe:
    php  ;pb??
    pha  ;pb??
    lda frame
    cmp oldframe
    beq waitframe
    sta oldframe
    pla
    plp
    rts
