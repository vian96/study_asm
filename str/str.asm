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
; Copies cx symbols from si to di
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
; Calculates number at si with base bl
;   si - ptr of str
;   cx - base
;   bx = 0
; RET: bx - calculated num
; CHANGED: si, dx, ax
;------------------------------------------------
atoi proc
    @@loop:
        ; returns if end of str
        mov al, ds:[si] ; this is needed because we should compare only one byte but not a word
        mov ah, 0
        cmp ax, '$'
        je @@ret

        mov ax, cx
        mul bx      ; ax*=bx, dx is filled with overflow of mul
        mov bx, ax
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
; ITOA
; Translates bx number to str pointed by di
; IT WILL NOT BE '$' TERMINATED
;   di - ptr of str to be written
;   cx - base
;   ax - number to be translated
; RET: PROBABLY di - ptr to the symbol next to last number sym
; CHANGED: bx, dx
;------------------------------------------------
itoa proc
    ; TODO check if number is zero
    ; TODO check if it works properly on 1 integer number
    mov si, di

    @@loop:
        mov dx, 0
        div cx      ; ax = dx:ax div cx, dx = dx:ax % cx
        add dx, '0'

        mov ds:[di], dx
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


main:
    mov di, offset end_of_file
    mov cx, 10
    mov ax, 12345
    call itoa

    mov ah, PUTS
    mov dx, offset end_of_file
    int 21h

@@ret:  ; exit 0
    mov ax, 4c00h
    int 21h

    text db "100$"
    secnd db "12347$"
    end_of_file db 0

end start



