.model tiny
.code
org 100h

locals @@

start:
    xor al, al
    xor bl, bl
    xor cl, cl

@@loop:
    add ax, 128
    cmp ax, 0
    jne @@loop
    add bx, 64
    cmp bx, 0
    jne @@loop
    add cx, 32
    cmp cx, 0
    jne @@loop
    inc dx
    cmp dx, 0
    jne @@loop

end start

