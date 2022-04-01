global printf

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess

; First arg is str and second is length
%macro WRITE 2
; WriteConsole( STD_OUTPUT_HANDLE, strbuffer, numofchar, numwritten, double 0)
        push    dword 0         
        push    numCharsWritten
        push    dword %2    
        push    dword %1             
        push    dword    [STDOutputHandle]
        call    WriteConsoleA
%endmacro ; WRITE

%define DEB     WRITE DEBSTR, 4

section .data
        str:     db 'xello, world!', 0x0D, 0x0A, 0 ; \r\n\0
        strLen:  equ $-str

section .bss
        numCharsWritten     resd 1
        STDOutputHandle     resd 1

        itoaBuff            resb 40 ; because 32 + some buffer space
        ret_addr            resd 1


section .text

%include "itoa.asm"

;------------------------------------------------
; STRLEN
; edi - source of str
; CHANGED: ecx, edi, eax, ebx
; RETURN: eax - len
;------------------------------------------------
strlen:
    ; TODO check flags of direction
    mov     ebx, edi
    xor     al, al  
    mov     ecx, 0xffffffff

    repne   scasb   ; while [edi] != al

    sub     edi, ebx     
    mov     eax, edi     
    dec eax

    ret         
; end of strlen 

;------------------------------------------------
; MACRO FOR PRINTF
; Writes ecx symbols from esi and see code, its simple
;------------------------------------------------
%macro WRITE_BUF 0
    WRITE edi, ecx
    xor ecx, ecx
    mov edi, esi
    add edi, 2      ; to move from % to actual string
%endmacro ; WRITE_BUF

;------------------------------------------------
; PRINTF
; 
; CHANGED: esi, eax, dl, ecx (ret), ebx
;------------------------------------------------
printf:
    ; TODO fix for __cedcl (add esp, n*4)
    ; si is where we read string
    pop     ecx
    mov     [ret_addr], ecx
    pop     esi
    mov     edi, esi
    dec     esi      ; useful because you do not need to inc it befoure calling loop
    xor ecx, ecx

    .printf_loop:
        inc     esi
        mov     al, [esi]
        cmp     al, '%'
        je      .codes

        cmp     al, 0
        je      .ret

        inc ecx
        jmp     .printf_loop

.ret:
    WRITE_BUF
    mov     ecx, [ret_addr]
    push    ecx
    ret

.jmp_percent:
    jmp     .percent

.jmp_default:
    jmp     .default

.codes:
    WRITE_BUF

    inc     esi
    mov     al, [esi]

    cmp     al, '%'
    je      .jmp_percent
    cmp     al, 'b'
    jl      .jmp_default    ; less than 'b'
    cmp     al, 'x'
    jg      .jmp_default    ; more than 'x'

    sub     al, 'b'
    xor     ebx, ebx
    mov     bl, al
    ; ebx = 4*al
    add     ebx, ebx
    add     ebx, ebx

    mov     ebx, [ebx + .jmp_table]
    jmp     ebx

.jmp_table:
    ; hardcoded jmp table
    dd      .bin 
    dd      .char
    dd      .dec
    dd      10 dup(.default)
    dd      .oct
    dd      3 dup(.default)
    dd      .str
    dd      4 dup(.default)
    dd      .hex

.dec:
    pop     eax
    push    esi
    push    edi
    push    ecx

    mov     edi, itoaBuff
    mov     ecx, 10
    call    itoa
    WRITE   itoaBuff, eax

    pop     ecx
    pop     edi
    pop     esi
    jmp     .printf_loop

.bin:
    pop     eax
    push    esi
    push    edi
    push    ecx

    mov     edi, itoaBuff
    mov     ecx, 1
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, eax

    pop     ecx
    pop     edi
    pop     esi
    jmp     .printf_loop

.oct:
    pop     eax
    push    esi
    push    edi
    push    ecx

    mov     edi, itoaBuff
    mov     ecx, 3
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, eax

    pop     ecx
    pop     edi
    pop     esi
    jmp     .printf_loop

.hex:
    pop     eax
    push    esi
    push    edi
    push    ecx

    mov     edi, itoaBuff
    mov     ecx, 4
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, eax

    pop     ecx
    pop     edi
    pop     esi
    jmp     .printf_loop

.char:
    pop     eax
    mov     [itoaBuff], al
    push    ecx
    WRITE   itoaBuff, 1
    pop     ecx
    jmp     .printf_loop

.str:
    pop     eax
    push    esi
    push    edi
    push    ecx

    mov     esi, eax
    mov     edi, eax
    call    strlen

    WRITE   esi, eax

    pop     ecx
    pop     edi
    pop     esi

    jmp     .printf_loop

.percent:
    mov     byte [itoaBuff], '%'
    WRITE   itoaBuff, 1
    jmp     .printf_loop

.default:
    jmp     .printf_loop

; end of printf

    str_to_printf db "PRINTFFFF %d was not %b and %c so it is %s and %x but not %o (not 0)", 10, "a", 0
    str_wr        db "some str", 0

    DEBSTR db "DEB", 10, 0
