;------------------------------------------------
; ITOA
; Translates unsigned bx number to str pointed by di with base cx and places $ at the end
;   edi - ptr of str to be written
;   ecx - base
;   eax - number to be translated
; CHANGED: ebx, edx, edi, esi
; RETURNED: eax - length
;------------------------------------------------
itoa:
    cmp eax, ecx
    jg .main_itoa

    mov dl, [eax + XlatTable]
    mov [edi], dl
    mov byte [edi+1], 0
    mov eax, 1
    ret

.main_itoa:
    mov esi, edi

    .loop:
        mov edx, 0
        div ecx              ; eax = edx:eax div ecx, edx = edx:eax % ecx
        mov ebx, edx
        mov dl, [ebx + XlatTable]

        mov [edi], dl
        inc edi

        cmp eax, 0
        je .end_loop
    jmp .loop

.end_loop:
    mov ecx, edi
    sub ecx, esi
    shr ecx, 1
    mov byte [edi], 0
    mov edx, edi
    sub edx, esi
    dec edi

    .reverse_ans:
        mov al, [edi]
        xchg [esi], al
        mov [edi], al

        dec edi
        inc esi
    loop .reverse_ans

    mov eax, edx ; returned value is length
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
    mov [edi], dl
    mov byte [edi+1], 0
    mov eax, 1
    ret

.main_itoa2n:
    mov esi, edi
    mov edx, 1
    shl edx, cl
    dec edx                  ; dx = 2^cl - 1

    .loop:
        mov ebx, eax
        and ebx, edx          ; bx = ax % 2^cl
        shr eax, cl          ; ax = ax / 2^cl

        mov bl, [ebx + XlatTable]
        mov [edi], bl
        inc edi

        cmp eax, 0
        je .end_loop
    jmp .loop

    ; TODO is it okay to have copypaste like this?
    .end_loop:
    mov ecx, edi
    sub ecx, esi
    shr ecx, 1
    mov byte [edi], 0
    mov edx, edi
    sub edx, esi
    dec edi

    .reverse:
        mov al, [edi]
        xchg [esi], al
        mov [edi], al

        dec edi
        inc esi
    loop .reverse

    mov eax, edx ; returned value is length
    ret

; end of itoa2n

    XlatTable db '0123456789ABCDEF'
