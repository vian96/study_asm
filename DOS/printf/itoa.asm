;------------------------------------------------
; ITOA
; Translates unsigned bx number to str pointed by di with base cx and places $ at the end
;   di - ptr of str to be written
;   cx - base
;   ax - number to be translated
; CHANGED: bx, dx, di, si
;------------------------------------------------
itoa proc
    ; TODO check if number is zero
    ; TODO check if it works properly on 1 integer number
    mov si, di

    @@loop:
        mov dx, 0
        div cx              ; ax = dx:ax div cx, dx = dx:ax % cx
        mov bx, dx
        mov dl, ds:[bx + offset XlatTable]

        mov ds:[di], dl
        inc di

        cmp ax, 0
        je @@end_loop
    jmp @@loop

    @@end_loop:
    mov cx, di
    sub cx, si
    shr cx, 1
    mov ds:[di], '$'
    dec di

    @@reverse:
        mov al, ds:[di]
        xchg ds:[si], al
        mov ds:[di], al

        dec di
        inc si
    loop @@reverse

@@ret:
    ret
itoa endp

;------------------------------------------------
; ITOA2N
; Translates unsigned bx number to str pointed by di with base 2^cl and places $ at the end
;   di - ptr of str to be written
;   cl - power of base
;   ax - number to be translated
;   bh = 0
; CHANGED: bx, dx, di, si
;------------------------------------------------
itoa2n proc
    ; TODO check if number is zero
    ; TODO check if it works properly on 1 integer number
    mov si, di
    mov dx, 1
    shl dx, cl
    dec dx                  ; dx = 2^cl - 1

    @@loop:
        mov bx, ax
        and bx, dx          ; bx = ax % 2^cl
        shr ax, cl          ; ax = ax / 2^cl

        mov bl, ds:[bx + offset XlatTable]
        mov ds:[di], bl
        inc di

        cmp ax, 0
        je @@end_loop
    jmp @@loop

    ; TODO is it okay to have copypaste like this?
    @@end_loop:
    mov cx, di
    sub cx, si
    shr cx, 1
    mov ds:[di], '$'
    dec di

    @@reverse:
        mov al, ds:[di]
        xchg ds:[si], al
        mov ds:[di], al

        dec di
        inc si
    loop @@reverse

@@ret:
    ret
itoa2n endp

    XlatTable db "0123456789ABCDEF"

