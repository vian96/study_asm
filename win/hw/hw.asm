global _start

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess

section .data
        str:     db 'hello, world!', 0x0D, 0x0A, 0 ; \r\n\0
        strLen:  equ $-str

section .bss
        numCharsWritten:        resd 1

section .text
        _start:

        ; GetStdHandle( STD_OUTPUT_HANDLE ) ;
        push    dword -11
        call    GetStdHandle ; returns in eax

        
        ; WriteConsole( STD_OUTPUT_HANDLE, strbuffer, numofchar, numwritten, double 0)
        push    dword 0         
        push    numCharsWritten 
        push    dword strLen    
        push    str             
        push    eax             
        call    WriteConsoleA


        ; ExitProcess( 0 )
        push    dword 0         ; Arg1: push exit code
        call    ExitProcess
        