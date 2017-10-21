4832 <add_to_table>
4832:  0b12           push	r11
4834:  0a12           push	r10
4836:  0912           push	r9
4838:  0b4f           mov	r15, r11
483a:  0a4e           mov	r14, r10
483c:  094d           mov	r13, r9
483e:  1e4f 0200      mov	0x2(r15), r14
4842:  1c4f 0400      mov	0x4(r15), r12
4846:  0f4e           mov	r14, r15
4848:  0f93           tst	r15
484a:  0324           jz	#0x4852 <add_to_table+0x20>


484c:  0c5c           add	r12, r12
484e:  1f83           dec	r15
4850:  fd23           jnz	#0x484c <add_to_table+0x1a>


4852:  0c93           tst	r12
4854:  0234           jge	#0x485a <add_to_table+0x28>
4856:  3c50 0300      add	#0x3, r12


485a:  0c11           rra	r12
485c:  0c11           rra	r12
485e:  2c9b           cmp	@r11, r12
4860:  0434           jge	#0x486a <add_to_table+0x38>
4862:  1e53           inc	r14
4864:  0f4b           mov	r11, r15
4866:  b012 d448      call	#0x48d4 <rehash>


486a:  9b53 0000      inc	0x0(r11)
486e:  0f4a           mov	r10, r15
4870:  b012 0e48      call	#0x480e <hash>
4874:  1c43           mov	#0x1, r12
4876:  1e4b 0200      mov	0x2(r11), r14
487a:  0e93           tst	r14
487c:  0324           jz	#0x4884 <add_to_table+0x52>


487e:  0c5c           add	r12, r12
4880:  1e83           dec	r14
4882:  fd23           jnz	#0x487e <add_to_table+0x4c>


4884:  3c53           add	#-0x1, r12
4886:  0cff           and	r15, r12
4888:  0c5c           add	r12, r12
488a:  1f4b 0800      mov	0x8(r11), r15
488e:  0f5c           add	r12, r15
4890:  2e4f           mov	@r15, r14
4892:  1b4b 0600      mov	0x6(r11), r11
4896:  0b5c           add	r12, r11
4898:  0c4e           mov	r14, r12
489a:  0c5c           add	r12, r12
489c:  0c5c           add	r12, r12
489e:  0c5c           add	r12, r12
48a0:  0c5e           add	r14, r12
48a2:  0c5c           add	r12, r12
48a4:  2c5b           add	@r11, r12
48a6:  1e53           inc	r14
48a8:  8f4e 0000      mov	r14, 0x0(r15)
48ac:  0f43           clr	r15
48ae:  093c           jmp	#0x48c2 <add_to_table+0x90>


48b0:  0b4c           mov	r12, r11
48b2:  0b5f           add	r15, r11
48b4:  cb4e 0000      mov.b	r14, 0x0(r11)
48b8:  1f53           inc	r15
48ba:  3f90 0f00      cmp	#0xf, r15
48be:  0424           jeq	#0x48c8 <add_to_table+0x96>
48c0:  1a53           inc	r10


48c2:  6e4a           mov.b	@r10, r14
48c4:  4e93           tst.b	r14
48c6:  f423           jnz	#0x48b0 <add_to_table+0x7e>


48c8:  8c49 1000      mov	r9, 0x10(r12)
48cc:  3941           pop	r9
48ce:  3a41           pop	r10
48d0:  3b41           pop	r11
48d2:  3041           ret
