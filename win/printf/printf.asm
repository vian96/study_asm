global _start

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
        numCharsWritten:        resd 1
        STDOutputHandle         resd 1

        itoaBuff                resb 40 ; because 32 + some buffer space
        ret_addr                resd 1


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
    mov   ebx, edi
    xor   al, al  
    mov   ecx, 0xffffffff

    repne scasb   ; while [edi] != al

    sub   edi, ebx     
    mov   eax, edi     

    ret         
; end of strlen 

;------------------------------------------------
; PRINTF
; 
; CHANGED: esi, eax, dl, ecx (ret), ebx
;------------------------------------------------
printf:
    DEB
    ; si is where we read string
    pop ecx
    DEB
    mov [ret_addr], ecx
    DEB
    pop esi
    dec esi      ; useful because you do not need to inc it befoure calling loop

    DEB

    .printf_loop:
        inc esi
        mov al, [esi]
        cmp al, '%'
        je .codes

        cmp al, 0
        je .ret

        WRITE esi, 1
        
        jmp .printf_loop

.ret:
    mov ecx, [ret_addr]
    push ecx
    ret

.jmp_percent:
    jmp .percent

.jmp_default:
    jmp .default

.codes:
    inc esi
    mov al, [esi]

    cmp al, '%'
    je .jmp_percent
    cmp al, 'b'
    jl .jmp_default    ; less than 'b'
    cmp al, 'x'
    jg .jmp_default    ; more than 'x'

    sub al, 'b'
    xor ebx, ebx
    mov bl, al
    ; ebx = 4*al
    add ebx, ebx
    add ebx, ebx

    mov ebx, [ebx + .jmp_table]
    jmp ebx

.jmp_table:
    ; hardcoded jmp table
    dd .bin 
    dd .char
    dd .dec
    dd 10 dup(.default)
    dd .oct
    dd 3 dup(.default)
    dd .str
    dd 4 dup(.default)
    dd .hex

.dec:
    pop eax
    push ecx
    push esi

    mov edi, itoaBuff
    mov ecx, 10
    call itoa

    pop esi
    pop ecx

    WRITE itoaBuff, eax
    jmp .printf_loop

.bin:
    pop eax
    push ecx
    push esi

    mov edi, itoaBuff
    mov ecx, 1
    xor bh, bh
    call itoa2n

    pop esi
    pop ecx

    WRITE itoaBuff, eax
    jmp .printf_loop

.oct:
    pop eax
    push ecx
    push esi

    mov edi, itoaBuff
    mov ecx, 3
    xor bh, bh
    call itoa2n

    pop esi
    pop ecx

    WRITE itoaBuff, eax
    jmp .printf_loop

.hex:
    pop eax
    push ecx
    push esi

    mov edi, itoaBuff
    mov ecx, 4
    xor bh, bh
    call itoa2n

    pop esi
    pop ecx

    WRITE itoaBuff, eax
    jmp .printf_loop

.char:
    ; PUTC 'C'
    pop eax
    ; PUTC al
    ; TODO DO CHAR
    jmp .printf_loop

.str:
    pop eax
    push ecx
    push esi

    mov esi, eax
    mov edi, eax
    call strlen

    WRITE esi, eax

    pop esi
    pop ecx

    jmp .printf_loop

.percent:
    ; PUTC '%'
    jmp .printf_loop

.default:
    ; PUTC 'E'
    jmp .printf_loop

; end of printf

_start:

        ; GetStdHandle( STD_OUTPUT_HANDLE )
        push    dword -11
        call    GetStdHandle ; returns in eax
        mov [STDOutputHandle], eax

        push dword 17
        push dword 0DEh
        push dword  str_wr
        push dword 'j'
        push dword 6
        push dword 1345
        push dword  str_to_printf
        call printf

        ; ExitProcess( 0 )
        push    dword 0   
        call    ExitProcess

        str_to_printf db "PRINTFFFF %d was not %b and %c so it is %s and %x but not %o (not 0)", 0
        str_wr        db "some str", 0

        DEBSTR db "DEB", 10, 0
