.model tiny
.code
org 100h

locals @@

start:
    mov dx, 
    mov ah, 09h
    int 21h

    mov ax, 4c00h
    int 21h

    str db "asfasf"

end start
