bits 64
section .text
global _start

_start:

push exit

; set up stack
mov rbp,rsp

; password entry will be rbp-0x30
; canary will be at rbp-0x18
; admin bool will be at rbp-0x10

; set up admin checking
mov qword [rbp-0x10],0x0

; setup password

; zero variable
xor rax,rax
mov [rbp-0x30],rax	
mov [rbp-0x28],rax	
mov [rbp-0x20],rax	

; open password file
mov rax,0x2
mov rdi,password_filename
mov rsi,0x0
mov rdx,0x0
syscall

; read password file
mov rdi,rax
mov rax,0x0
mov rsi,password_data
mov rdx,0x18
syscall

; close password flie
mov rax,0x3
mov rdi,3
syscall

; setup flag
; open flag file
mov rax,0x2
mov rdi,flag_filename
mov rsi,0x0
mov rdx,0x0
syscall

; read flag file
mov rdi,rax
mov rax,0x0
mov rsi,flag_data
mov rdx,0x10
syscall

; close flag flie
mov rax,0x3
syscall


; setup canary
; open canary file
mov rax,0x2
mov rdi,canary_filename
mov rsi,0x0
mov rdx,0x0
syscall

; read canary file
mov rdi,rax
mov rax,0x0
lea rsi,[rbp-0x18]
mov rdx,0x8
syscall

; close canary flie
mov rax,0x3
syscall

; save canary value
mov r15,qword [rbp-0x18]

; write greeting
mov rax,0x1
mov rdi,0x1
mov rsi,hello
mov rdx,21
syscall

; read password
mov rax,0x0
mov rdi,0x0
lea rsi,[rbp-0x30]
mov rdx,0x30
syscall

; check canary value
mov rax,qword [rbp-0x18]
cmp rax,r15
jz check_password

bad_canary:
; write error and exit
mov rax,0x1
mov rdi,0x1
mov rsi,error
mov rdx,18
syscall
ret

check_password:

; compare password and set admin bit

mov rcx,0x3
mov rsi,password_data
lea rdi,[rbp-0x30]
repe cmpsq
jnz check_admin

mov rax,1
mov qword [rbp-0x10],rax

check_admin:

; if non-admin, exit
mov rax,qword [rbp-0x10]
test rax,rax
jnz flag

; write fail and exit
mov rax,0x1
mov rdi,0x1
mov rsi,fail
mov rdx,19
syscall
ret

	
flag:	
; write flag
mov rax,0x1
mov rdi,0x1
mov rsi,flag_data
mov rdx,21
syscall

exit:

mov rax,60
mov rdi,0
syscall

hello:
db "enter your password:",10

error: 
db "Password too long",10

fail: 
db "Password incorrect",10

canary_filename:
db ".canary",0

password_filename:
db ".password",0

flag_filename:
db ".flag",0

section .data
password_data:
times 100 db 0
flag_data:
times 100 db 0
