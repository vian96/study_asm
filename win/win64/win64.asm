global _start

extern GetStdHandle
extern WriteFile
extern ExitProcess

section .rodata

msg db "Hello World!", 0x0d, 0x0a

msg_len equ $-msg
stdout_query equ -11
status equ 0

section .data

stdout dw 0
bytesWritten dw 0

section .text

_start:
    mov rcx, stdout_query
    call GetStdHandle
    mov [stdout], rax

    mov  rcx, [stdout]
    mov  rdx, msg
    mov  r8, msg_len
    mov  r9, bytesWritten
    push qword 0
    call WriteFile

    mov rcx, status
    call ExitProcess