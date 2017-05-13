; stage1: exit if ptrace detected (with anti-disassembly)
; stage1: sum ptrace detection code mod 256
; stage1: sum + second byte of password used to xor-decrypt stage2
	
bits 32


global _start ; TEST

_start: 

	push 0xVAR15
	push 0xVAR11
	push 0xVAR7
        push 0xVAR3
	mov ecx,4
	.dloop:
	jmp .lab0
	db 0x81
	.lab0:
	db 0x68
        .lab1:
	pop ebx
	pop edx
	jmp short .lab2
        jmp short .lab1
	.lab2:
        xor ebx,edx
	xor ebx,[esi]
	jz .lab3
	xor eax,eax
	inc eax
	jmp ebp
	.lab3:
	add esi,4
	loop .dloop
	xor eax,eax
	jmp ebp

section .data ; TEST
input: db "IUciuoUEIMirwzPE" ; TEST
