# No RE

## Level categories

Exploitation, reverse engineering

## To run

Distribute the `sc` file.  

## To play:

Try to guess the correct password.  If you get it right, you will be rewarded with the message `Correct password!!`

## Solution

The first part of the program is straightforward: Reading in the user input.  Following that is this blob: 

```
(gdb) x/20i $eip
=> 0x8048093:	mov    esi,0x804817a
   0x8048098:	mov    al,BYTE PTR [esi]
   0x804809a:	jmp    0x80480ad
   0x804809c:	sbb    DWORD PTR [ebx+0x53],0x36b9
   0x80480a3:	add    BYTE PTR [ebx+0x30],cl
   0x80480a6:	add    al,0xb
   0x80480a8:	loop   0x80480a5
   0x80480aa:	inc    esi
   0x80480ab:	ret    
   0x80480ac:	call   0x8046c99
```

This contains several jumps and similar intended to obfuscate its true meaning to a disassembler, but watching it work, we can discover that it xors some 54 bytes of ram with the 
value at esi (which `x/s esi` will reveal is our input), and then jumps to them.  If we break at the return instruction and then examine the stack, we will find where these 54 bytes 
start: 

```
(gdb) b *0x80480ab
Breakpoint 2 at 0x80480ab
(gdb) c
Continuing.

Breakpoint 2, 0x080480ab in ?? ()
(gdb) x/xw $esp
0xffffda9c:     0x080480b2
```

So the 54 bytes starting from 0x080480b2 are xored with the first byte of the input.  

From here, there are two paths: The path that looks to understand the precise behaviour of the file and the path that wants to brute force the solution when possible.  For brute 
forcing, we expect pretty different behaviour between when we are running successfully xor-decrypted code and when we are running garbage, so we can try: 

```
for x in {A..z}; do echo $x; echo $x | ./sc; done
```

The only character that doesn't give either an illegal instruction or a segfault (both suggestive of running invalid code, such as encrypted code) is Z.  So we try it again: 

```
for x in {A..z}; do echo Z$x; echo $x | ./sc; done
```

This time, the only character that gives anything other than a stoppage is S, at which the program prints "Incorrect password".  We surmise that perhaps the second character of the 
password is S.  

Trying a third time, however, 

```
for x in {A..z}; do echo ZS$x; echo $x | ./sc; done
```

every input elicits an "Incorrect password".  So now we need to understand what is happening.  

So let us return to the 54 bytes that are being xor-decrypted.  How do we pull these bytes out of the ELF file?  First, we have to find the offset within the 
file.  Specifically: We know where these bytes are loaded into RAM: at address `0x080480b2`.  If we do: 

```
readelf -S sc|grep 'text\|Addr'
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 1] .text             PROGBITS        08048060 000060 0000f1 00 WAX  0   0 16
```

we discover that the offset within the .text section is loaded into RAM starting at `0x08048060`.  Thus the offset of the instructions within the text section is: 

```
$ echo $((0x080480b2 - 0x08048060))
82
```

And so the offset in the file is the offset of the .text sectionwithin the file (0x60) plus the offset of the code within the .text section of the code (82).  Thus: 

```
$ echo $((0x60+82))
178
```

So to pull out the 54 bytes starting here we do: 

```
dd if=sc bs=1 skip=178 count=54 of=xor
54+0 records in
54+0 records out
54 bytes copied, 0.000290667 s, 186 kB/s
```

At this point, how to tell what xor key makes sense with this is hard to say.  Several possibilities come to mind: 

* See which key gives the most of some common instruction like xor
* See which key gives the shortest maximum line length (meaningless instructions often have long operands)
* Filter which keys give bad instructions in their disassembly

The last option we should be wary of, however, considering we know the code is obfuscated against naive disassembly.  In this case, it happens that looking for instructions that xor 
two registers, only two possible keys give non-trivial quantities: 

```
for i in `seq 0 255`; do printf "$i "; ndisasm -b32 <(python2 util/xorenc.py xor $(printf %x $i)) | grep -c 'xor e.x,e.x'; done | sort -n -k 2 | tail
128 1
129 1
131 1
160 1
162 1
169 1
171 1
176 1
88 5
90 7
```

So our guess might be that the first character of the password is the ASCII decoding of 90, or Z.  

Following this, we need to understand the first stage.  

```
$ ndisasm -b32 s1
00000000  E802000000        call dword 0x7
00000005  90                nop
00000006  8031C0            xor byte [ecx],0xc0
00000009  31DB              xor ebx,ebx
0000000B  31C9              xor ecx,ecx
0000000D  31D2              xor edx,edx
0000000F  41                inc ecx
00000010  EB01              jmp short 0x13
00000012  8131C0B01940      xor dword [ecx],0x4019b0c0
00000018  CD80              int 0x80
0000001A  83F8FF            cmp eax,byte -0x1
0000001D  7502              jnz 0x21
0000001F  0F0B              ud2
00000021  5B                pop ebx
00000022  31C9              xor ecx,ecx
00000024  B10A              mov cl,0xa
00000026  31C0              xor eax,eax
00000028  03048B            add eax,[ebx+ecx*4]
0000002B  E2FB              loop 0x28
0000002D  03048B            add eax,[ebx+ecx*4]
00000030  31DB              xor ebx,ebx
00000032  8A1E              mov bl,[esi]
00000034  31D8              xor eax,ebx
```

If one were to analyse this, one would find that it does two things: ptraces itself and runs the instruction `ud2` (an mnemonic signifying a particular undefined opcode that will 
raise an "Illegal instruction" exception) if it fails.  This means if we run this in a debugger, we will get different behaviour to if we run it outside.  The second thing it does 
is computes a checksum of itself, so that if our attempt to foil the anti-debugging measures are to modify the code (e.g. replace the `int 0x80` with nops), this checksumming will 
fail.  

Further, in the next portion of the code after these 54 bytes back in `sc`, we find that it is xor-decrypting the next 56 bytes with this checksum, so we cannot simply replace the 
checksumming code either.  It must give a specific answer.  

Since this checksum is in eax, we can cheat, however, and modify the executable to write eax after this has run.  Within the executable, we are now at the address 54 bytes after the 
start of the xor-encrypted block, which we concluded started 178 bytes into the executable file.  Thus we can overwrite it thus: 

```
$ cat printeax.s
bits 32
push eax 
xor eax,eax 
xor ebx,ebx 
xor edx,edx 
mov al,0x4 
mov bl,1 
mov ecx,esp 
mov dl,4 
int 0x80 
xor eax,eax 
inc eax 
int 0x80 
$ nasm -f bin -o printeax printeax.s
$ dd if=printeax of=sc2 bs=1 seek=$((178+54)) conv=notrunc
22+0 records in
22+0 records out
22 bytes copied, 0.000210466 s, 105 kB/s
$ echo ZS | ./sc2|hexdump -e '1/4 "%08x"' -e '"\n"'
f0154057
```

And this will give us the proper value of eax after this stage.  So if we replace the entire xor-decryptor portion (starting as we saw above at 0x08048098) and xor-encoded portion 
(the 54 bytes starting at 0x080480b2) of the code with code that only sets eax to this value and does nothing else, we can win.  In the .text section, 0x08048098 is at offset 0x38.  
The total size of the portion to be replaced is 

```
$ echo $((0x080480b2+54-0x08048098))
80
```

We note that esi is set to the address of our input.  Since the process consumes two bytes of input, we will need also to increment esi by 2.  

So we can use the following snippet:

```
mov eax,0xf0154057
inc esi
inc esi
times 80-$ nop
```

Since the decoder starts at an offset of `0x08048098 - 0x08048060 = 0x38` from the start of the .text section, which starts `0x60` into the file, we can write this with: 

```
$ cat seteax.s
bits 32
mov eax,0xf0154057
inc esi
inc esi
times 80-($-$$) nop
$ nasm -f bin -o seteax seteax.s
$ cp sc sc3
'sc' -> 'sc3'
$ dd if=seteax bs=1 of=sc3 seek=$((0x60+0x38)) conv=notrunc
80+0 records in
80+0 records out
80 bytes copied, 0.000312788 s, 256 kB/s
```

Then the final (now xor-decrypted) section starts at 0x8048108, within which 0x0804812d is where we see an instruction xoring something with [esi]--ebx specifically.  So we break 
there.  The first time through, we see ebx is 0x69635549, i.e. `IUci`.  So we know the password start with ZSIUci.  The remaining times through, at this same address, we see the 
remainder of the password in four-byte increments, eventually giving us the full password.
