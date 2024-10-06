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
    php
    pha
waitframe_loop:
    lda frame
    cmp oldframe
    beq waitframe_loop
    sta oldframe
    pla
    plp
    rts
