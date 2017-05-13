; read password
; stage0: First byte of password is used to xor-decrypt stage1
; stage1: exit if ptrace detected (with anti-disassembly)
; stage1: sum ptrace detection code mod 256
; stage1: sum + second byte of password used to xor-decrypt stage2
; stage2: compare rest of password (16 bytes) to answer
	
bits 32


global _start

_start:	
read_input:
	mov ecx,input
	xor eax,eax
	xor ebx,ebx
	xor edx,edx
	add al,3
	mov dl,20
	int 0x80

check:	
	jmp check_password

finish: 
	mov ecx,wrong
	test eax,eax
	jnz failure
	mov ecx,right

failure:
	xor eax,eax
	xor ebx,ebx
	xor edx,edx
	add al,4
	inc ebx
	mov dl,19
	int 0x80

exit:
	xor eax,eax
	inc eax
	int 0x80


check_password:
	
stage0:
	mov esi,input
	mov al,byte [esi]
	jmp .pre_stage1
	db 0x81
	.dec:
	pop ebx
	push ebx
	mov ecx,LEN1
	dec ebx
	.dec_loop:
	xor [ebx+ecx],al
	loop .dec_loop
	inc esi
	ret
	db 0xe8
	.pre_stage1:
	call .dec
	
stage1:
	incbin "stage1.enc"

dec2:
	jmp .pre_stage2
	.dec2:
	pop ebx
	push ebx
	mov ecx,LEN2
	shr ecx,2
	sub ebx,4
	.dec_loop2:
	xor [ebx+ecx*4],eax
	loop .dec_loop2
	inc esi
	mov ebp,finish
	ret
	.pre_stage2:
	call .dec2
	
stage2:
	incbin "stage2.enc"
	
call lab1
db 0x81
lab2:
db 0x04
lab1:
pop eax
jmp short lab2
jmp eax

done:	
	jmp finish
	
section .data

right: db "Correct password!!",10
wrong: db "Incorrect password",10
input: times 100 db 0
