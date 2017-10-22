0010 <__trap_interrupt>
0010:  3041           ret
4400 <main>
4400:  013c           jmp	#0x4404 <main+0x4>
4402:  d1a1 3140 0044 dadd.b	0x4031(sp), 0x4400(sp)
4408:  013c           jmp	#0x440c <main+0xc>
440a:  d1a1 1542 5c01 dadd.b	0x4215(sp), 0x15c(sp)
4410:  013c           jmp	#0x4414 <main+0x14>
4412:  d1a1 75f3 013c dadd.b	-0xc8b(sp), 0x3c01(sp)
4418:  d1a1 35d0 085a dadd.b	-0x2fcb(sp), 0x5a08(sp)
441e:  013c           jmp	#0x4422 <main+0x22>
4420:  d1a1 3f40 0011 dadd.b	0x403f(sp), 0x1100(sp)
4426:  013c           jmp	#0x442a <main+0x2a>
4428:  d1a1 0f93 0724 dadd.b	-0x6cf1(sp), 0x2407(sp)
442e:  013c           jmp	#0x4432 <main+0x32>
4430:  d1a1 8245 5c01 dadd.b	0x4582(sp), 0x15c(sp)
4436:  013c           jmp	#0x443a <main+0x3a>
4438:  d1a1 2f83 0343 dadd.b	-0x7cd1(sp), 0x4303(sp)
443e:  013c           jmp	#0x4442 <main+0x42>
4440:  d1a1 1e4f 3446 dadd.b	0x4f1e(sp), 0x4634(sp)
4446:  013c           jmp	#0x444a <main+0x4a>
4448:  d1a1 8f4e 0024 dadd.b	0x4e8f(sp), 0x2400(sp)
444e:  013c           jmp	#0x4452 <main+0x52>
4450:  d1a1 ef23 013c dadd.b	0x23ef(sp), 0x3c01(sp)
4456:  d1a1 0f43 0f93 dadd.b	0x430f(sp), -0x6cf1(sp)
445c:  013c           jmp	#0x4460 <main+0x60>
445e:  d1a1 0e24 013c dadd.b	0x240e(sp), 0x3c01(sp)
4464:  d1a1 8245 5c01 dadd.b	0x4582(sp), 0x15c(sp)
446a:  013c           jmp	#0x446e <main+0x6e>
446c:  d1a1 1f83 013c dadd.b	-0x7ce1(sp), 0x3c01(sp)
4472:  d1a1 cf43 0035 dadd.b	0x43cf(sp), 0x3500(sp)
4478:  013c           jmp	#0x447c <main+0x7c>
447a:  d1a1 f923 013c dadd.b	0x23f9(sp), 0x3c01(sp)
4480:  d1a1 3e40 0012 dadd.b	0x403e(sp), 0x1200(sp)
4486:  013c           jmp	#0x448a <main+0x8a>
4488:  d1a1 3f40 0024 dadd.b	0x403f(sp), 0x2400(sp)
448e:  013c           jmp	#0x4492 <main+0x92>
4490:  d1a1 bf4f feef dadd.b	0x4fbf(sp), -0x1002(sp)
4496:  013c           jmp	#0x449a <main+0x9a>
4498:  d1a1 3e53 fa23 dadd.b	0x533e(sp), 0x23fa(sp)
449e:  013c           jmp	#0x44a2 <main+0xa2>
44a0:  d1a1 3b40 0c16 dadd.b	0x403b(sp), 0x160c(sp)
44a6:  013c           jmp	#0x44aa <main+0xaa>
44a8:  d1a1 0212 013c dadd.b	0x1202(sp), 0x3c01(sp)
44ae:  d1a1 3040 be44 dadd.b	0x4030(sp), 0x44be(sp)
44b4 <__stop_progExec__>
44b4:  32d0 f000      bis	#0xf0, sr
44b8:  fd3f           jmp	#0x44b4 <__stop_progExec__+0x0>
44ba <__ctors_end>
44ba:  3040 3246      br	#0x4632 <_unexpected_>
4632 <_unexpected_>
4632:  0013           reti	pc


4402:  3140 0044 
440a:  1542 5c01 
4412:  75f3 35d0 085a 
441e:  3f40 0011 
4426:  0f93 0724 
442e:  8245 5c01 
4436:  2f83 0343 
443e:  1e4f 3446 
4446:  8f4e 0024 
444e:  ef23 0f43 0f93 
445c:  0e24 8245 5c01 
446a:  1f83 cf43 0035 
4478:  f923 3e40 0012 
4486:  3f40 0024 
448e:  bf4f feef 
4496:  3e53 fa23 
449e:  3b40 0c16 
44a6:  0212 3040 be44 



3140 0044 
1542 5c01 
75f3 35d0 085a 
3f40 0011 
0f93 0724 
8245 5c01 
2f83 0343 
1e4f 3446 
8f4e 0024 
ef23 0f43 0f93 
0e24 8245 5c01 
1f83 cf43 0035 
f923 3e40 0012 
3f40 0024 
bf4f feef 
3e53 fa23 
3b40 0c16 
0212 3040 be44 



	

3140 0044      mov	#0x4400, sp
1542 5c01      mov	&0x015c, r5
75f3           and.b	#-0x1, r5
35d0 085a      bis	#0x5a08, r5
3f40 0011      mov	#0x1100, r15
0f93           tst	r15

442c:	
0724           jz	$+0x10 	; 443c
8245 5c01      mov	r5, &0x015c ; this is 4432
2f83           decd	r15
0343           clr	4 	; this is 443c
1e4f 3446      mov	0x4634(r15), r14
8f4e 0024      mov	r14, 0x2400(r15)

4452:	
ef23           jnz	$-0x20 	; 4432
0f43           clr	r15
0f93           tst	r15

4460:	
0e24           jz	$+0x1e 	; 447e
8245 5c01      mov	r5, &0x015c
1f83           dec	r15
cf43 0035      mov.b	#0x0, 0x3500(r15) ; this is 4470

447c:	
f923           jnz	$-0xc 	; 4470
3e40 0012      mov	#0x1200, r14 ; this is 447e
3f40 0024      mov	#0x2400, r15
bf4f feef      mov	@r15+, -0x1002(r15) ; this is 4492
3e53           add	#-0x1, r14

449c:	
fa23           jnz	$-0xa 	; 4492
3b40 0c16      mov	#0x160c, r11
0212           push	sr
3040 be44      br	#0x44be








	

	mov	#0x4400, sp
	mov	&0x015c, r5
	and.b	#-0x1, r5
	bis	#0x5a08, r5
	mov	#0x1100, r15
	tst	r15
	jz	lab2 	; 443c
lab1:	
	mov	r5, &0x015c ; this is 4432
	decd	r15
lab2:	
	clr	4 	; this is 443c
	mov	0x4634(r15), r14
	mov	r14, 0x2400(r15)
	jnz	lab1 	; 4432
	clr	r15
	tst	r15
	jz	lab4 	; 447e
	mov	r5, &0x015c
	dec	r15
lab3:
	mov.b	#0x0, 0x3500(r15) ; this is 4470
	jnz	lab3 	; 4470
lab4:
	mov	#0x1200, r14 ; this is 447e
	mov	#0x2400, r15
lab5:
	mov	@r15+, -0x1002(r15) ; this is 4492
	add	#-0x1, r14
	jnz	lab5 	; 4492
	mov	#0x160c, r11
	push	sr
	br	#0x44be
