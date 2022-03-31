	.file	"call.c"
	.intel_syntax noprefix
	.text
	.def	___main;	.scl	2;	.type	32;	.endef
	.globl	_main
	.def	_main;	.scl	2;	.type	32;	.endef
_main:
	push	ebp
	mov	ebp, esp
	and	esp, -16
	call	___main
	mov	eax, 0
	leave
	ret
	.ident	"GCC: (GNU) 11.2.0"
