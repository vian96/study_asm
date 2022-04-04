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
; MACRO FOR PRINTF
; Macro for printing hex, oct and bin
; Uses the first arg as power
;------------------------------------------------
%macro PRINT_2N 1
    pop     eax
    push    esi
    push    edi
    push    ecx
    push    edx

    mov     edi, itoaBuff
    mov     ecx, %1
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, eax

    pop     edx
    pop     ecx
    pop     edi
    pop     esi
    jmp     .printf_loop
%endmacro ; PRINT_2N

;------------------------------------------------
; PRINTF
; 
; CHANGED: esi, eax, dl, ecx, ebx, edx
;------------------------------------------------
printf:
    ; esi is where we read string
    ; edx is offset of stack for cdecl
    mov     edx, 4   ; 4 for adresses
    pop     ecx
    mov     [ret_addr], ecx
    pop     esi
    mov     edi, esi
    dec     esi      ; useful because you do not need to inc it befoure calling loop
    xor     ecx, ecx

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
    add     esp, edx 
    mov     ecx, [ret_addr]
    push    ecx
    ret

.jmp_percent:
    jmp     .percent

.jmp_default:
    jmp     .default

.codes:
    add edx, 4
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

    mov     ebx, [4*ebx + .jmp_table]
    jmp     ebx

section .data
; hardcoded jmp table for printf
.jmp_table:
    dd      .bin 
    dd      .char
    dd      .dec
    dd      10 dup(.default)
    dd      .oct
    dd      3 dup(.default)
    dd      .str
    dd      4 dup(.default)
    dd      .hex
; end of jmp table for printf

section .text
; printf
.dec:
    pop     eax
    push    esi
    push    edi
    push    ecx
    push    edx

    mov     edi, itoaBuff
    mov     ecx, 10
    call    itoa
    WRITE   itoaBuff, eax

    pop     edx
    pop     ecx
    pop     edi
    pop     esi
    jmp     .printf_loop

.bin:
    PRINT_2N 1

.oct:
    PRINT_2N 3

.hex:
    PRINT_2N 4

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
    sub     edx, 4
    mov     byte [itoaBuff], '%'
    WRITE   itoaBuff, 1
    jmp     .printf_loop

.default:
    sub     edx, 4
    jmp     .printf_loop

; end of printf

    str_to_printf db "PRINTFFFF %d was not %b and %c so it is %s and %x but not %o (not 0)", 10, "a", 0
    str_wr        db "some str", 0

    DEBSTR db "DEB", 10, 0
