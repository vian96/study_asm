extern Printf
extern ExitProcess

global _start

section .data
    str_to: db "this is not the test from %d %o %c %s", 10, 0
    str_in: db "but i will say hello", 0

section .text

_start:
    push str_in
    push 'j'
    push 63
    push 1342
    push str_to
    call Printf
    add esp, 4*5

    ; ExitProcess( 0 )
    push    dword 0   
    call    ExitProcess
    
