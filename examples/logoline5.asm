
.org  $0600

    LDY #$10
l2: ; start line
    LDX #$00

l3: ; draw pix

    JSR waitframe

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

;-------------------------------------

.alias oldframe $fc
.alias frame $fd
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

