; stage1: exit if ptrace detected (with anti-disassembly)
; stage1: sum ptrace detection code mod 256
; stage1: sum + second byte of password used to xor-decrypt stage2
	
bits 32


global _start ; TEST

_start:
	mov esi,input ; TEST
	inc esi ; TEST
	call .ptrace
	db 0x90,0x80
	.ptrace:
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	inc ecx
	jmp .ptrace1
	db 0x81
	.ptrace1:
	xor eax,eax
	mov al,0x19
	inc eax
	int 0x80
	cmp eax,-1
	jne .sum_ptrace
	ud2
	.sum_ptrace:
	pop ebx
	xor ecx,ecx
	mov cl,10
	xor eax,eax
	.sum_loop:
	add eax,dword [ebx+4*ecx]
	loop .sum_loop
	add eax,dword [ebx+4*ecx]
	xor ebx,ebx
	mov bl,byte [esi]
	xor eax,ebx
stuff: ; TEST
	push eax ; TEST
	xor eax,eax ; TEST
	xor ebx,ebx ; TEST
	xor edx,edx ; TEST
	xor esi,esi ; TEST
	mov al,0x4 ; TEST
 	mov bl,1 ; TEST
	mov ecx,esp ; TEST
	mov dl,4 ; TEST
	int 0x80 ; TEST
        xor eax,eax ; TEST
        inc eax ; TEST
        int 0x80 ; TEST

section .data ; TEST
input: db "ZSIUciuoUEIMirwzPEPD" ; TEST
