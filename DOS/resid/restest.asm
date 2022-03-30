.model tiny
.code
org 100h

locals @@

start:
    mov ax, 111h
    mov bx, 2222h
    mov cx, 3333h
    mov dx, 4444h

    std

@@loop:
    in al, 60h
    cmp al, 1
    jne @@loop

    mov ax, 4c00h
    int 21h

end start

