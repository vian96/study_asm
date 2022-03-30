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
        _start:

        ; GetStdHandle( STD_OUTPUT_HANDLE ) ;
        push    dword -11
        call    GetStdHandle ; returns in eax
        mov [STDOutputHandle], eax

        WRITE str, strLen

        ; ExitProcess( 0 )
        push    dword 0         ; Arg1: push exit code
        call    ExitProcess
        