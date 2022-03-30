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

section .data
        str:     db 'xello, world!', 0x0D, 0x0A, 0 ; \r\n\0
        strLen:  equ $-str

section .bss
        numCharsWritten:        resd 1
        STDOutputHandle         resd 1

section .text

;------------------------------------------------
; ITOA
; Translates unsigned bx number to str pointed by di with base cx and places $ at the end
;   di - ptr of str to be written
;   cx - base
;   ax - number to be translated
; CHANGED: bx, dx, di, si
;------------------------------------------------
itoa:
    ; TODO check if number is zero
    ; TODO check if it works properly on 1 integer number
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
    mov byte [edi], '$'
    dec edi

    .reverse_ans:
        mov al, [edi]
        xchg [esi], al
        mov [edi], al

        dec edi
        inc esi
    loop .reverse_ans

    ret

    XlatTable db '0123456789ABCDEF'

; end of itoa

_start:

        ; GetStdHandle( STD_OUTPUT_HANDLE )
        push    dword -11
        call    GetStdHandle ; returns in eax
        mov [STDOutputHandle], eax

        WRITE str, strLen

        ; ExitProcess( 0 )
        push    dword 0   
        call    ExitProcess
        