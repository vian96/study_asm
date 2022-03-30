.model tiny
.code
org 100h

locals @@

start:
    jmp main

;------------------------------------------------
; ITOA16_RESID
; Translates unsigned bx number to str pointed by di with base 2^cl for resident purposes
; It doesn't place \0 or $ at the end
; TODO make program always fill four symbols
;   di - ptr of str to be written
;   ax - number to be translated
;   es - segment of memory to write
; CHANGED: bx, di
;------------------------------------------------
itoa16_resid proc
    mov bx, ax
    shr bx, 12
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

    mov bx, ax
    and bx, 0F00h
    shr bx, 8
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

    mov bx, ax
    and bx, 0F0h
    shr bx, 4
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

    mov bx, ax
    and bx, 0Fh
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

@@ret:
    ret

    XlatTable db "0123456789ABCDEF"

itoa16_resid endp

main:
    mov ax, 0b800h
    mov es, ax
    mov di, 2 * (80*20 + 40)
    mov ax, 0ABCDh
    call itoa16_resid

    add di, 2
    mov ax, 1234h
    call itoa16_resid

@@ret:  ; exit 0
    mov ax, 4c00h
    int 21h

end start
