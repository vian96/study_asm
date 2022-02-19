; strlen strchr strncpy strncmp atoi itoa (2, 8, 10, 16)

.model tiny
.code
org 100h

locals @@

;------------------------------------------------
; CONSTANTS
;------------------------------------------------
PUTS equ 09h
;------------------------------------------------

start:
jmp main

;------------------------------------------------
; STRLEN
; Computes length of string (end is '$' sym)
;   si - ptr of str
;   dl = 0
; RET: dl - len 
; CHANGED: si
;------------------------------------------------
strlen proc
    @@loop:
        cmp ds:[si], '$'
        je @@ret

        inc si
        inc dl
    jmp @@loop

@@ret:
    ret
strlen endp

;------------------------------------------------
; STRCHR
; Finds first character in str (end is '$' sym)
;   si - ptr of str
;   dl - sym to find
; RET: si - ptr to char
; CHANGED: si
;------------------------------------------------
strchr proc
    @@loop:
        ; end of string
        cmp ds:[si], '$'
        je @@ret

        ; needed character
        cmp ds:[si], dl
        je @@ret

        inc si
    jmp @@loop

@@ret:
    ret
strchr endp

;------------------------------------------------
; STRNCPY
; Copies no more than cx symbols from si to di
;   si - ptr of source
;   di - ptr of destination
;   cx - num of symbols to copy
; RET: di - end of copied str
; CHANGED: si, di, cx, al
;------------------------------------------------
strncpy proc
    @@loop:
        mov al, ds:[si]
        mov ds:[di], al
        
        ; returns only after copying end of str if there is
        cmp ds:[si], '$'
        je @@ret

        inc si
        inc di
    loop @@loop

@@ret:
    ret
strncpy endp

;------------------------------------------------
; STRNCMP
; Compares at most cx characters of two strings
;   si - frst str
;   di - scnd str
;   cx - num of symbols to cmp
; RET: al - res
; CHANGED: si, di, cx
;------------------------------------------------
strncmp proc
    @@loop:
        mov al, ds:[di]
        cmp ds:[si], al
        jne @@ret
        
        cmp ds:[si], '$'
        je @@ret

        inc si
        inc di
    loop @@loop

@@ret:
    mov al, ds:[si]
    sub al, ds:[di]
    ret
strncmp endp

;------------------------------------------------
; ATOI
; Calculates unsigned number at si with base cx
;   si - ptr of str
;   cx - base
;   bx = 0
; RET: bx - calculated num
; CHANGED: si, dx, ax
;------------------------------------------------
atoi proc
    ; TODO handle letters
    @@loop:
        ; returns if end of str
        mov al, ds:[si]     ; this is needed because we should compare only one byte but not a word
        cmp al, '$'
        je @@ret

        mov ax, cx
        mul bx              ; ax*=bx, dx is filled with overflow of mul
        mov bx, ax

        ; is it okay to do like this?
        mov dh, 0
        mov dl, ds:[si]
        sub dl, '0'
        add bx, dx

        inc si
    jmp @@loop

@@ret:
    ret
atoi endp

;------------------------------------------------
; ATOI2N
; Calculates unsigned number at si with base 2^cl
;   si - ptr of str
;   cl - power of base
;   bx = 0
;   ah = 0
; RET: bx - calculated num
; CHANGED: si, ax
;------------------------------------------------
atoi2n proc
    @@loop:
        ; returns if end of str
        mov al, ds:[si]     ; this is needed because we should compare only one byte but not a word
        cmp al, '$'
        je @@ret

        shl bx, cl          ; bx *= 2^cl
        sub al, '0'
        add bx, ax

        inc si
    jmp @@loop

@@ret:
    ret
atoi2n endp

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

main:
    mov di, offset end_of_file
    mov cx, 3
    mov ax, 23
    call itoa2n

    mov si, offset end_of_file
    mov cx, 3
    mov bx, 0
    mov ah, 0
    call atoi2n

    mov di, offset end_of_file
    mov cx, 10
    mov ax, bx
    call itoa

    mov ah, PUTS
    mov dx, offset end_of_file
    int 21h

@@ret:  ; exit 0
    mov ax, 4c00h
    int 21h

    text db "100$"
    secnd db "12347$"
    XlatTable db "0123456789ABCDEF"
    end_of_file db 0

end start



