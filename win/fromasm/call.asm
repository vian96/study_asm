extern print
extern ExitProcess

global _start

section .data

section .text

_start:
    call print

    ; ExitProcess( 0 )
    push    dword 0   
    call    ExitProcess
    
