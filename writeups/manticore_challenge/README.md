# Manticore challenge

Trailofbits put out a challenge in automated reverse engineering, found in manticore_challenge.c.  

The idea is to reverse-engineer the correct password.  The input is 12 bytes, of which each byte is checked by a separate function, each of which does its own separate simple 
mathematical computation to verify the byte.  Each one individually would not be hard to solve, but the number of different such functions makes it suitable for an automated tool.  
However, this tool needs to be able to actually back-solve through such operations, and so will need some understanding of symbolic execution.

One such tool is Z3, and Manticore is their library for applying it to such situations as this.  So we will take this as an opportunity to learn Manticore and in general begin to 
understand the business of automated reverse-engineering.

## Plan

The basic strategy in using Manticore appears to be to attach functions ("hooks") to specific addresses in the binary, which will be run when execution reaches those addresses.  
These functions all receive one argument: `state`.  This provides access to the current state of the CPU (so we can modify registers in the functions, say) as well as any symbolic 
state that we are keeping track of (so that we can e.g. elect to solve for the original values of such state that would have brought us to the address).  

In this case, then, we start off wanting to add the following hooks: 

* The address right before the password checking function is called.  This hook will set up the symbolic state for the input which we will eventually solve for.

* The address after the password checking function has returned.  Since the individual character-checking functions will exit upon failure, if we make it to this point we can solve 
for the answer.

* The addresses in the character-checking functions at which the program will exit.  At these points we can abandon whatever state might have brought us here since we know it is 
wrong.

For simplicity, we will also skip over the initial functions that print the prompt and receive the password input, since.  We do this by adding an additional hook: 

* The address right before the `puts` function is called.  This hook will set EIP to the address after the `fgets` function returns, effectively skipping the IO.

Most of these hooks are just addresses in the `main` function, which is relatively simple: 

```
00000000004008e8 <main>:
  4008e8:	55                   	push   rbp
  4008e9:	48 89 e5             	mov    rbp,rsp
  4008ec:	48 83 ec 10          	sub    rsp,0x10
  4008f0:	bf b4 09 40 00       	mov    edi,0x4009b4
  4008f5:	e8 a6 fb ff ff       	call   4004a0 <puts@plt>
  4008fa:	48 8b 15 3f 07 20 00 	mov    rdx,QWORD PTR [rip+0x20073f]        # 601040 <stdin@@GLIBC_2.2.5>
  400901:	48 8d 45 f0          	lea    rax,[rbp-0x10]
  400905:	be 0c 00 00 00       	mov    esi,0xc
  40090a:	48 89 c7             	mov    rdi,rax
  40090d:	e8 9e fb ff ff       	call   4004b0 <fgets@plt>
  400912:	48 8d 45 f0          	lea    rax,[rbp-0x10]
  400916:	48 89 c7             	mov    rdi,rax
  400919:	e8 d4 fe ff ff       	call   4007f2 <check>
  40091e:	bf c1 09 40 00       	mov    edi,0x4009c1
  400923:	e8 78 fb ff ff       	call   4004a0 <puts@plt>
  400928:	b8 00 00 00 00       	mov    eax,0x0
  40092d:	c9                   	leave  
  40092e:	c3                   	ret    
  40092f:	90                   	nop
```

So: 

* The hook for address `0x4008f5` will set `eip` to `0x400912`

* The hook for address `0x400916` will set up a symbolic buffer of size 12 at `rbp - 0x10`

* The hook for address `0x40091e` will solve for the original state of the symbolic buffer that got us there.

The only thing that is slightly complex is getting the addresses that indicate failure.  These are in the individual character-checking functions, which all look relatively similar: 

```
00000000004006f3 <check_char_6>:
  4006f3:	55                   	push   rbp
  4006f4:	48 89 e5             	mov    rbp,rsp
  4006f7:	53                   	push   rbx
  4006f8:	48 83 ec 18          	sub    rsp,0x18
  4006fc:	89 f8                	mov    eax,edi
  4006fe:	88 45 ec             	mov    BYTE PTR [rbp-0x14],al
  400701:	0f b6 5d ec          	movzx  ebx,BYTE PTR [rbp-0x14]
  400705:	83 c3 47             	add    ebx,0x47
  400708:	80 fb 8a             	cmp    bl,0x8a
  40070b:	74 0a                	je     400717 <check_char_6+0x24>
  40070d:	bf 01 00 00 00       	mov    edi,0x1
  400712:	e8 a9 fd ff ff       	call   4004c0 <exit@plt>
  400717:	b8 01 00 00 00       	mov    eax,0x1
  40071c:	48 83 c4 18          	add    rsp,0x18
  400720:	5b                   	pop    rbx
  400721:	5d                   	pop    rbp
  400722:	c3                   	ret    
```

The `call exit@plt` instruction is common to all and reaching it indicates failure, so as a kind of very rough static analysis (it seems it will be beneficial to have some better 
tools later), we can simply grep through the disassembly for this:

```
objdump -d -Mintel manticore_challenge |grep 'call.*exit' | sed 's/:.*//;s/  /0x/' > exit_addrs
```

Then the hooks we set at these addresses will simply be to abandon the current state.  

The complete solution is in solve.sh, with the Manticore calls happening in ans.py, and runs in around 90 seconds: 

```
$ time ./solve.sh 
Starting
hooked
skipping puts/gets
setting up input
140737488354752
abandoning
abandoning
abandoning
abandoning
abandoning
abandoning
solving
RESULT:
=MANTICORE==

real	1m28.095s
user	1m25.880s
sys	0m2.493s
```
