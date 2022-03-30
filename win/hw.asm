STD_OUTPUT_HANDLE   equ -11
NULL                equ 0

global GobleyGook
extern ExitProcess, GetStdHandle, WriteConsoleA

section .data
msg                 db "Hello World!", 13, 10, 0
msg.len             equ $ - msg

section .bss
dummy               resd 1

section .text
GobleyGook:
    push    STD_OUTPUT_HANDLE
    call    GetStdHandle

    push    NULL
    push    dummy
    push    msg.len
    push    msg
    push    eax
    call    WriteConsoleA 

    push    NULL
    call    ExitProcess