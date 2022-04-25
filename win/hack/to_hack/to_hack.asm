.model tiny
.code
org 100h

locals @@

start:
    jmp main

;------------------------------------------------
; STRNCMP
; Compares at most cx characters of two strings
;   si - frst str
;   di - scnd str
;   cx - num of symbols to cmp
; RET: al - res
; CHANGED: si, di, cx, al
;------------------------------------------------
strncmp proc
    @@loop:
        mov al, ds:[si]
        cmp al, 0
        je @@ret

        sub al, ds:[di]
        cmp al, 0
        jne @@ret

        inc si
        inc di
    loop @@loop

@@ret:
    ret
strncmp endp

;------------------------------------------------
; CONVERT 
; Replaces string from di according to lookup table
;   di - str to replace
; RET: None
; CHANGED: 
;------------------------------------------------
convert_pswd proc
    xor bh, bh

    @@loop:
        mov bl, ds:[di] 
        cmp bl, 126
        jg @@ret
        cmp bl, 32
        jle @@ret

        mov bl, ds:[offset lookup_tb + bx]
        mov ds:[di], bl
        inc di
        jmp @@loop
@@ret:
    xor bl, bl
    mov ds:[di], bl
    ret
convert_pswd endp

main:
    mov ah, 09h
    mov dx, offset greetings
    int 21h

    mov ah, 0ah
    mov dx, offset input_buf
    int 21h

    mov dl, 10
    mov ah, 02h
    int 21h

    mov di, offset input_buf + 2
    call convert_pswd

    ; mov ah, 09h
    ; mov dx, offset input_buf + 2
    ; int 21h

    mov si, offset password
    mov di, offset input_buf + 2
    mov cx, 40
    call strncmp

    cmp al, 0
    je @@acces_granted

    mov ah, 09h
    mov dx, offset failed
    int 21h
    jmp @@exit

@@acces_granted:
    mov ah, 09h
    mov dx, offset granted
    int 21h

@@exit:
    mov ax, 4c00h
    int 21h

    greetings db "Hello! You should put password to get access", 10, '$'
    password  db "6+c%{", 0
    input_buf db 255, 16 dup (0)    ; 255 for number of symbols to read
    failed    db "Wrong password", 10, '$'
    granted   db "Access granted!!", 10, '$'
    lookup_tb db 32 dup(0), "I.#WFnib@vVm`t;Qwke&$PK87(5?}!ZafXsY=JUTC21D*->Ro\jl]M:0G", '"', ",hLdSur) O%Eq'A|zpgH[+B^c{~y96Nx/_4<3"

end start
