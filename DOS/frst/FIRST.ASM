.model tiny

PUTS equ 09h

.code 
org 100h
Start:
    ; calling PUTS(msg)
    mov ah, PUTS
    mov dx, offset msg
    int 21h

    ; return 0
    mov ax, 4c00h
    int 21h

    nop
    nop
    msg db "ruleZZZ\n$"

end Start
