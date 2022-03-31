extern _print
extern ExitProcess

global _start

section .data

section .text

_start:
    call _print

    ; ExitProcess( 0 )
    push    dword 0   
    call    ExitProcess
    
