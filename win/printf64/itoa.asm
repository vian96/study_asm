;------------------------------------------------
; ITOA
; Translates unsigned bx number to str pointed by di with base cx and places $ at the end
;   rdi - ptr of str to be written
;   ecx - base
;   eax - number to be translated
; CHANGED: ebx, edx, rdi, rsi
; RETURNED: eax - length
;------------------------------------------------
itoa:
    cmp eax, ecx
    jg .main_itoa

    mov dl, [eax + XlatTable]
    mov [rdi], dl
    mov byte [rdi+1], 0
    mov eax, 1
    ret

.main_itoa:
    mov rsi, rdi

    .loop:
        mov edx, 0
        div ecx              ; eax = edx:eax div ecx, edx = edx:eax % ecx
        mov ebx, edx
        mov dl, [ebx + XlatTable]

        mov [rdi], dl
        inc rdi

        cmp eax, 0
        je .end_loop
    jmp .loop

.end_loop:
    mov rcx, rdi
    sub rcx, rsi
    shr rcx, 1      ; number of loops
    mov byte [rdi], 0
    mov rdx, rdi
    sub rdx, rsi    ; gets lenth of string
    dec rdi

    .reverse_ans:
        mov al, [rdi]
        xchg [rsi], al
        mov [rdi], al

        dec rdi
        inc rsi
    loop .reverse_ans

    mov rax, rdx ; returned value is length
    ret

; end of itoa


;------------------------------------------------
; ITOA2N
; Translates unsigned bx number to str pointed by di with base 2^cl and places $ at the end
;   di - ptr of str to be written
;   cl - power of base
;   ax - number to be translated
;   bh = 0
; CHANGED: bx, dx, di, si
;------------------------------------------------
itoa2n:
    mov ebx, 1
    shl ebx, cl
    cmp eax, ebx
    jg .main_itoa2n

    mov dl, [eax + XlatTable]
    mov [rdi], dl
    mov byte [rdi+1], 0
    mov eax, 1
    ret

.main_itoa2n:
    mov rsi, rdi
    mov edx, 1
    shl edx, cl
    dec edx                  ; dx = 2^cl - 1

    .loop:
        mov ebx, eax
        and ebx, edx          ; bx = ax % 2^cl
        shr eax, cl          ; ax = ax / 2^cl

        mov bl, [ebx + XlatTable]
        mov [rdi], bl
        inc rdi

        cmp eax, 0
        je .end_loop
    jmp .loop

    ; TODO is it okay to have copypaste like this?
    .end_loop:
    mov rcx, rdi
    sub rcx, rsi
    shr rcx, 1      ; number of loop
    mov byte [rdi], 0
    mov rdx, rdi
    sub rdx, rsi    ; returned value is length
    dec rdi

    .reverse:
        mov al, [rdi]
        xchg [rsi], al
        mov [rdi], al

        dec rdi
        inc rsi
    loop .reverse

    mov rax, rdx ; returned value is length
    ret

; end of itoa2n

    XlatTable db '0123456789ABCDEF'
