global _start

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess
extern WriteFile

;------------------------------------------------
; First arg is str and second is length
; WARNING: 
; RDX and R8 ARE REWRITEN BEFORE CALL
; It may break if you call write(sth, rdx) 
; CHANGED: rdx, r8, r9, rcx
%macro WRITE 2
    mov     r8, %2
    mov     rdx, %1
    sub     rsp, 0x100

; I DONT KNOW WHY THIS IS NEEDED
; But windows sometimes resets this
; GetStdHandle( STD_OUTPUT_HANDLE )
    mov     rcx, -11
    call    GetStdHandle ; returns in rax

    mov     rcx, rax
    mov     r9, numCharsWritten
    push    qword 0
    call    WriteFile
    add     rsp, 0x100
%endmacro ; WRITE

%define DEB     WRITE DEBSTR, 4

section .data
        str:     db 'xello, world!', 0x0D, 0x0A, 0 ; \r\n\0
        strLen:  equ $-str

section .bss
        numCharsWritten     resq 1
        STDOutputHandle     resq 1

        itoaBuff            resb 40 ; because 32 + some buffer space
        ret_addr            resq 1


section .text

%include "itoa.asm"

;------------------------------------------------
; STRLEN
; rdi - source of str
; CHANGED: rcx, rdi, rax, rbx
; RETURN: rax - len
;------------------------------------------------
strlen:
    ; TODO check flags of direction
    mov     rbx, rdi
    xor     al, al  
    mov     ecx, 0xffffffff

    repne   scasb   ; while [rdi] != al

    sub     rdi, rbx     
    mov     rax, rdi     
    dec     rax

    ret         
; end of strlen 

;------------------------------------------------
; MACRO FOR PRINTF
; Writes rcx symbols from rsi and see code, its simple
;------------------------------------------------
%macro WRITE_BUF 0
    WRITE rdi, rcx
    xor rcx, rcx
    mov rdi, rsi
    add rdi, 2      ; to move from % to actual string
%endmacro ; WRITE_BUF

;------------------------------------------------
; PRINTF
; 
; CHANGED: rsi, rax, dl, rcx (ret), rbx
;------------------------------------------------
printf:
    ; si is where we read string
    pop     rcx
    mov     [ret_addr], rcx
    pop     rsi
    mov     rdi, rsi
    dec     rsi      ; useful because you do not need to inc it befoure calling loop
    xor rcx, rcx

    .printf_loop:
        inc     rsi
        mov     al, [rsi]
        cmp     al, '%'
        je      .codes

        cmp     al, 0
        je      .ret

        inc rcx
        jmp     .printf_loop

.ret:
    WRITE_BUF
    mov     rcx, [ret_addr]
    push    rcx
    ret

.jmp_percent:
    jmp     .percent

.jmp_default:
    jmp     .default

.codes:
    WRITE_BUF

    inc     rsi
    mov     al, [rsi]

    cmp     al, '%'
    je      .jmp_percent
    cmp     al, 'b'
    jl      .jmp_default    ; less than 'b'
    cmp     al, 'x'
    jg      .jmp_default    ; more than 'x'

    sub     al, 'b'
    xor     rbx, rbx
;    mov     bl, al

;    jmp     qword [8*rbx + .jmp_table]

    ; rax is var
    lea     rbx, [rel .jmp_table] 
    mov     eax, [rbx + rax*4] 
    sub     rbx, .jmp_table wrt ..imagebase 
    add     rbx, rax 
    jmp     rbx 

.jmp_table:
    ; hardcoded jmp table
    dd      .bin                wrt ..imagebase  
    dd      .char               wrt ..imagebase  
    dd      .dec                wrt ..imagebase  
    dd      10 dup(.default)    wrt ..imagebase  
    dd      .oct                wrt ..imagebase  
    dd      3 dup(.default)     wrt ..imagebase  
    dd      .str                wrt ..imagebase  
    dd      4 dup(.default)     wrt ..imagebase  
    dd      .hex                wrt ..imagebase  

.dec:
    pop     rax
    push    rsi
    push    rdi
    push    rcx

    mov     rdi, itoaBuff
    mov     rcx, 10
    call    itoa
    WRITE   itoaBuff, rax

    pop     rcx
    pop     rdi
    pop     rsi
    jmp     .printf_loop

.bin:
    pop     rax
    push    rsi
    push    rdi
    push    rcx

    mov     rdi, itoaBuff
    mov     rcx, 1
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, rax

    pop     rcx
    pop     rdi
    pop     rsi
    jmp     .printf_loop

.oct:
    pop     rax
    push    rsi
    push    rdi
    push    rcx

    mov     rdi, itoaBuff
    mov     rcx, 3
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, rax

    pop     rcx
    pop     rdi
    pop     rsi
    jmp     .printf_loop

.hex:
    pop     rax
    push    rsi
    push    rdi
    push    rcx

    mov     rdi, itoaBuff
    mov     rcx, 4
    xor     bh, bh
    call    itoa2n
    WRITE   itoaBuff, rax

    pop     rcx
    pop     rdi
    pop     rsi
    jmp     .printf_loop

.char:
    pop     rax
    mov     [itoaBuff], al
    push    rcx
    WRITE   itoaBuff, 1
    pop     rcx
    jmp     .printf_loop

.str:
    pop     rax
    push    rsi
    push    rdi
    push    rcx

    mov     rsi, rax
    mov     rdi, rax
    call    strlen

    WRITE   rsi, rax

    pop     rcx
    pop     rdi
    pop     rsi

    jmp     .printf_loop

.percent:
    mov     byte [itoaBuff], '%'
    WRITE   itoaBuff, 1
    jmp     .printf_loop

.default:
    jmp     .printf_loop

; end of printf

_start:
    DEB
    DEB
    DEB
    DEB
    DEB


    push    qword 17
    push    qword 0DEh
    push    qword  str_wr
    push    qword 'j'
    push    qword 6
    push    qword 1345
    push    qword  str_to_printf
    call    printf

    ; ExitProcess( 0 )
    mov     rcx, 0   
    call    ExitProcess

    str_to_printf db "PRINTFFFF %d was not %b and %c so it is %s and %x but not %o (not 0)", 10, "a", 0
    str_wr        db "some str", 0

    DEBSTR db "DEB", 10, 0
