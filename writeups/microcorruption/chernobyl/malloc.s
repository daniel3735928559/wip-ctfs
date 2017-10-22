malloc:	
4678:  0b12           push	r11
467a:  c293 0424      tst.b	&0x2404
467e:  0f24           jz	#0x469e <read_heap_metadata>

init_heap_metadata:	
4680:  1e42 0024      mov	&0x2400, r14
4684:  8e4e 0000      mov	r14, 0x0(r14)
4688:  8e4e 0200      mov	r14, 0x2(r14)
468c:  1d42 0224      mov	&0x2402, r13
4690:  3d50 faff      add	#0xfffa, r13
4694:  0d5d           add	r13, r13
4696:  8e4d 0400      mov	r13, 0x4(r14)
469a:  c243 0424      mov.b	#0x0, &0x2404

read_heap_metadata:	
469e:  1b42 0024      mov	&0x2400, r11
46a2:  0e4b           mov	r11, r14 ; r14 = start of heap

loop:	
46a4:  1d4e 0400      mov	0x4(r14), r13	      ; r14 is start of chunk and pointer to prev, r14+2 is pointer to next, r14+4 is size/free flag
46a8:  1db3           bit	#0x1, r13	      ; if allocated, 
46aa:  2820           jnz	#0x46fc <next_chunk>
46ac:  0c4d           mov	r13, r12
46ae:  12c3           clrc
46b0:  0c10           rrc	r12
46b2:  0c9f           cmp	r15, r12	      ; if too small
46b4:  2338           jl	#0x46fc <next_chunk>
46b6:  0b4f           mov	r15, r11
46b8:  3b50 0600      add	#0x6, r11
46bc:  0c9b           cmp	r11, r12
46be:  042c           jc	#0x46c8 <allocate>
46c0:  1dd3           bis	#0x1, r13
46c2:  8e4d 0400      mov	r13, 0x4(r14)
46c6:  163c           jmp	#0x46f4 <cleanup>

allocate:	
46c8:  0d4f           mov	r15, r13
46ca:  0d5d           add	r13, r13
46cc:  1dd3           bis	#0x1, r13
46ce:  8e4d 0400      mov	r13, 0x4(r14)
46d2:  0d4e           mov	r14, r13
46d4:  3d50 0600      add	#0x6, r13
46d8:  0d5f           add	r15, r13
46da:  8d4e 0000      mov	r14, 0x0(r13)
46de:  9d4e 0200 0200 mov	0x2(r14), 0x2(r13)
46e4:  0c8f           sub	r15, r12
46e6:  3c50 faff      add	#0xfffa, r12
46ea:  0c5c           add	r12, r12
46ec:  8d4c 0400      mov	r12, 0x4(r13)
46f0:  8e4d 0200      mov	r13, 0x2(r14)

cleanup:	
46f4:  0f4e           mov	r14, r15
46f6:  3f50 0600      add	#0x6, r15
46fa:  0e3c           jmp	#0x4718 <done>

next_chunk:	
46fc:  0d4e           mov	r14, r13      ; r13 = current chunk location
46fe:  1e4e 0200      mov	0x2(r14), r14 ; r14 = address of next chunk
4702:  0e9d           cmp	r13, r14      ; If r14 < r13
4704:  0228           jnc	#0x470a <exhausted>
4706:  0e9b           cmp	r11, r14
4708:  cd23           jne	#0x46a4 <loop>

exhausted:	
470a:  3f40 5e46      mov	#0x465e, r15                  ;; "Heap exhausted; aborting"
470e:  b012 504d      call	#0x4d50 <puts>
4712:  3040 3e44      br	#0x443e <__stop_progExec__>
4716:  0f43           clr	r15

<done>
4718:  3b41           pop	r11
471a:  3041           ret
