.model tiny
.code
org 100h

locals @@

;------------------------------------------------
; CONSTANTS

;------------------------------------------------

;------------------------------------------------
; PUTC MACRO
; Calls putchar from int 21h
; Changes al to 02h and dl to sym
;------------------------------------------------
PUTC macro sym
    mov dl, sym
    mov ah, 02h
    int 21h
endm    ; PUTC
;------------------------------------------------

start:
    jmp main

INCLUDE itoa.asm

;------------------------------------------------
; PRINTF
; 
; CHANGED: si, ax, dl, cx (ret), bx
;------------------------------------------------
printf      proc
    ; si is where we read string
    pop cx
    mov ds:[@@ret_addr], cx
    pop si
    dec si      ; useful because you do not need to inc it befoure calling loop

    @@printf_loop:
        inc si
        mov al, ds:[si]
        cmp al, '%'
        je @@codes

        cmp al, 0
        je @@ret

        PUTC al
        
        jmp @@printf_loop

@@ret:
    mov cx, ds:[@@ret_addr]
    push cx
    ret

@@jmp_percent:
    jmp @@percent

@@jmp_default:
    jmp @@default

@@codes:
    inc si
    mov al, ds:[si]

    cmp al, '%'
    je @@jmp_percent
    cmp al, 'b'
    jl @@jmp_default    ; less than 'b'
    cmp al, 'x'
    jg @@jmp_default    ; more than 'x'

    sub al, 'b'
    mov bl, al
    xor bh, bh
    add bx, bx

    mov bx, ds:[bx + offset @@jmp_table]
    jmp bx

@@jmp_table:
    ; hardcoded jmp table
    dw offset @@bin 
    dw offset @@char
    dw offset @@dec
    dw 10 dup(offset @@default)
    dw offset @@oct
    dw 3 dup(offset @@default)
    dw offset @@str
    dw 4 dup(offset @@default)
    dw offset @@hex

@@dec:
    ; TODO check if it is needed
    ; PUTC 'D'
    
    pop ax
    push bx cx dx si di
    mov di, offset @@str_buffer
    mov cx, 10
    call itoa
    pop di si dx cx bx

    mov dx, offset @@str_buffer
    mov ah, 09h
    int 21h
    jmp @@printf_loop

@@bin:
    ; PUTC 'B'
    
    pop ax
    push bx cx dx si di
    mov di, offset @@str_buffer
    mov cx, 1
    xor bh, bh
    call itoa2n
    pop di si dx cx bx

    mov dx, offset @@str_buffer
    mov ah, 09h
    int 21h
    jmp @@printf_loop

@@oct:
    ; PUTC 'O'

    pop ax
    push bx cx dx si di
    mov di, offset @@str_buffer
    mov cx, 3
    xor bh, bh
    call itoa2n

    mov dx, offset @@str_buffer
    mov ah, 09h
    int 21h
    pop di si dx cx bx

    jmp @@printf_loop

@@hex:
    ; PUTC 'X'

    pop ax
    push bx cx dx si di
    mov di, offset @@str_buffer
    mov cx, 4
    xor bh, bh
    call itoa2n
    
    mov dx, offset @@str_buffer
    mov ah, 09h
    int 21h
    pop di si dx cx bx

    jmp @@printf_loop

@@char:
    ; PUTC 'C'
    pop ax
    PUTC al
    jmp @@printf_loop

@@str:
    ; PUTC 'S'
    pop ax
    push si dx
    mov si, ax

    ; TODO strlen + write
    ;      or if i can use str funct
    mov ah, 02h
@@print_str:
    mov dl, ds:[si]
    cmp dl, 0
    je @@exit_print_str_loop
    int 21h
    inc si
    jmp @@print_str

@@exit_print_str_loop:
    pop dx si
    jmp @@printf_loop


@@percent:
    ; PUTC '%'
    jmp @@printf_loop

@@default:
    ; PUTC 'E'
    jmp @@printf_loop

@@str_buffer db 16 dup(0DEh)
@@ret_addr   dw 0

printf      endp 

main:
    push 17
    push 0DEh
    push offset str_wr
    push 'j'
    push 6
    push 1345
    push offset str_to_printf
    call printf

@@exit:
    mov ax, 4c00h
    int 21h

    str_to_printf db "PRINTFFFF %d was not %b and %c so it is %s and %x but not %o (not 0)", 0
    str_wr        db "some str", 0
end start
