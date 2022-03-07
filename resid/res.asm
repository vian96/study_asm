.model tiny

.code 
org 100h
locals @@

start:
        jmp main

new09       proc
            push es ax  ; TODO check if there are more unused

            in al, 60h  ; get pressed button from keyboard
            cmp al, 2   ; if key is not 1 then do nothing
            jne @@old_int

            mov ax, 0b800h
            mov es, ax
            mov al, 0FFh
            mov es:[(80*6+30)*2], al

@@old_int:
            pop ax es   ; TODO check if list is fine
            db 0eah     ; opcode of jmp far
old09       dd 0        ; place for ptr to prev int

new09       endp




main:
        xor bx, bx
        mov es, bx      ; es = 0
        mov bx, 09h*4   ; *4 is needed because every int ptr is 4 bytes

        ; saves 4 bytes of ptr to int func
        mov ax, es:[bx]
        mov word ptr cs:[old09], ax
        mov ax, es:[bx+2]
        mov word ptr cs:[old09+2], ax

        mov ax, offset new09
        mov es:[bx], ax
        mov es:[bx+2], cs

        mov dx, offset main     ; leaving as resident, offset main is enough since interruption is before
        shl dx, 4
        inc dx
        mov ax, 3100h
        int 21h

end start
