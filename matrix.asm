        org 08000h

; black border / black attributes

        xor a
        out (0FEh),a
        ld hl,05AFFh
attr:   ld (hl),a
        dec hl
        bit 2,h
        jr z,attr

; fill screen with random characters

        ld e,a
fillscr:ld d,040h
fill:   call rndchar
        ld a,d
        cp 058h
        jr nz,fill
        inc e
        jr nz,fillscr

; digital rain loop

frame:  ld b,06h
        halt
column: push bc

; randomize one character

        call random
        and 018h
        jr z,docol
        add a,038h
        ld d,a
        call random
        ld e,a
        call rndchar

; select a random column

docol:  call random
        and 01Fh
        ld l,a
        ld h,058h

; ~1% chance black -> white

        ld a,(hl)
        or a
        ld bc,0247h
        jr z,check

; white -> bright green

white:  cp c
        ld c,044h
        jr z,movecol

; bright green -> green

        cp c
        ld c,04h
        jr z,movecol

; ~6% chance green -> black

        ld bc,0F00h
check:  call random
        cp b
        jr c,movecol
        ld c,(hl)

; move column down

movecol:ld de,020h
        ld b,018h
down:   ld a,(hl)
        ld (hl),c
        ld c,a
        add hl,de
        djnz down
        pop bc
        djnz column

; test for keypress

        ld bc,07FFEh
        in a,(c)
        rrca
        jr c,frame
        ret

; display a random glyph

rndchar:call random
crange: sub 05Fh
        jr nc,crange
        add a,a
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        ld bc,(05C36h)
        add hl,bc
        ld b,8
char:   ld a,(hl)
        ld (de),a
        inc d
        inc hl
        djnz char
        ret

; get a byte from the ROM

random: push hl
        ld hl,(seed)
        inc hl
        ld a,h
        and 01Fh
        ld h,a
        ld (seed),hl
        ld a,(hl)
        pop hl
        ret

seed:
