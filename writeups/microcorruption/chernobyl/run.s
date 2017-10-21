4b66 <run>
[ WELCOME MESSAGES ]

4b9a:  0e43           clr	r14
4b9c:  3740 ff05      mov	#0x5ff, r7
4ba0:  053c           jmp	#0x4bac <run+0x46> ;; get_input

<something>
4ba2:  0f41           mov	sp, r15
4ba4:  0f5e           add	r14, r15
4ba6:  cf43 0000      mov.b	#0x0, 0x0(r15)
4baa:  1e53           inc	r14

<get_input>
4bac:  079e           cmp	r14, r7
4bae:  f937           jge	#0x4ba2 <run+0x3c>
4bb0:  3e40 5005      mov	#0x550, r14
4bb4:  0f41           mov	sp, r15
4bb6:  b012 404d      call	#0x4d40 <getsn>
4bba:  0b41           mov	sp, r11
4bbc:  923c           jmp	#0x4ce2 <run+0x17c> ;; check_nonempty

<check_if_a>
4bbe:  7f90 6100      cmp.b	#0x61, r15
4bc2:  3a20           jne	#0x4c38 <run+0xd2>
4bc4:  0e4b           mov	r11, r14
4bc6:  3e50 0700      add	#0x7, r14
4bca:  0b4e           mov	r14, r11
4bcc:  073c           jmp	#0x4bdc <run+0x76>
4bce:  7f90 2000      cmp.b	#0x20, r15
4bd2:  0320           jne	#0x4bda <run+0x74>
4bd4:  cb43 0000      mov.b	#0x0, 0x0(r11)
4bd8:  043c           jmp	#0x4be2 <run+0x7c>
4bda:  1b53           inc	r11
4bdc:  6f4b           mov.b	@r11, r15
4bde:  4f93           tst.b	r15
4be0:  f623           jnz	#0x4bce <run+0x68>
4be2:  1b53           inc	r11
4be4:  0a43           clr	r10
4be6:  0b3c           jmp	#0x4bfe <run+0x98>
4be8:  0d4a           mov	r10, r13
4bea:  0d5d           add	r13, r13
4bec:  0d5d           add	r13, r13
4bee:  0d5a           add	r10, r13
4bf0:  0d5d           add	r13, r13
4bf2:  6a4b           mov.b	@r11, r10
4bf4:  8a11           sxt	r10
4bf6:  3a50 d0ff      add	#0xffd0, r10
4bfa:  0a5d           add	r13, r10
4bfc:  1b53           inc	r11


4bfe:  6f4b           mov.b	@r11, r15
4c00:  4f93           tst.b	r15
4c02:  0324           jz	#0x4c0a <run+0xa4>
4c04:  7f90 3b00      cmp.b	#0x3b, r15
4c08:  ef23           jne	#0x4be8 <run+0x82>
4c0a:  0f48           mov	r8, r15
4c0c:  b012 cc49      call	#0x49cc <get_from_table>
4c10:  3f93           cmp	#-0x1, r15
4c12:  0320           jne	#0x4c1a <run+0xb4>
4c14:  3f40 964a      mov	#0x4a96, r15          ;; No such box
4c18:  413c           jmp	#0x4c9c <run+0x136>
4c1a:  0aef           xor	r15, r10
4c1c:  3af0 ff7f      and	#0x7fff, r10
4c20:  0820           jnz	#0x4c32 <run+0xcc>
4c22:  0f9a           cmp	r10, r15
4c24:  0334           jge	#0x4c2c <run+0xc6>
4c26:  3f40 a34a      mov	#0x4aa3, r15          ;; Access Granted
4c2a:  383c           jmp	#0x4c9c <run+0x136>
4c2c:  3f40 b34a      mov	#0x4ab3, r15          ;; Access Granted; but account not activated
4c30:  353c           jmp	#0x4c9c <run+0x136>
4c32:  3f40 de4a      mov	#0x4ade, r15          ;; Access denied.Can not have a pin with high bit set
4c36:  323c           jmp	#0x4c9c <run+0x136>

<check_if_n>
4c38:  7f90 6e00      cmp.b	#0x6e, r15
4c3c:  4020           jne	#0x4cbe <run+0x158>
4c3e:  094b           mov	r11, r9
4c40:  2952           add	#0x4, r9
4c42:  0b49           mov	r9, r11
4c44:  073c           jmp	#0x4c54 <run+0xee>
4c46:  7f90 2000      cmp.b	#0x20, r15
4c4a:  0320           jne	#0x4c52 <run+0xec>
4c4c:  cb43 0000      mov.b	#0x0, 0x0(r11)
4c50:  043c           jmp	#0x4c5a <run+0xf4>
4c52:  1b53           inc	r11
4c54:  6f4b           mov.b	@r11, r15
4c56:  4f93           tst.b	r15
4c58:  f623           jnz	#0x4c46 <run+0xe0>
4c5a:  1b53           inc	r11
4c5c:  0a43           clr	r10
4c5e:  0b3c           jmp	#0x4c76 <run+0x110>
4c60:  0c4a           mov	r10, r12
4c62:  0c5c           add	r12, r12
4c64:  0c5c           add	r12, r12
4c66:  0c5a           add	r10, r12
4c68:  0c5c           add	r12, r12
4c6a:  6a4b           mov.b	@r11, r10
4c6c:  8a11           sxt	r10
4c6e:  3a50 d0ff      add	#0xffd0, r10
4c72:  0a5c           add	r12, r10
4c74:  1b53           inc	r11
4c76:  6f4b           mov.b	@r11, r15
4c78:  4f93           tst.b	r15
4c7a:  0324           jz	#0x4c82 <run+0x11c>
4c7c:  7f90 3b00      cmp.b	#0x3b, r15
4c80:  ef23           jne	#0x4c60 <run+0xfa>
4c82:  0a93           tst	r10
4c84:  0334           jge	#0x4c8c <run+0x126>
4c86:  3f40 ec4a      mov	#0x4aec, r15
4c8a:  083c           jmp	#0x4c9c <run+0x136>
4c8c:  0e49           mov	r9, r14
4c8e:  0f48           mov	r8, r15
4c90:  b012 cc49      call	#0x49cc <get_from_table>
4c94:  3f93           cmp	#-0x1, r15
4c96:  0524           jeq	#0x4ca2 <run+0x13c>
4c98:  3f40 124b      mov	#0x4b12, r15

4c9c:  b012 504d      call	#0x4d50 <puts>
4ca0:  1c3c           jmp	#0x4cda <run+0x174>
4ca2:  0a12           push	r10
4ca4:  0912           push	r9
4ca6:  3012 2f4b      push	#0x4b2f           ;; Adding user account %s with pin %x
4caa:  b012 4844      call	#0x4448 <printf>
4cae:  3150 0600      add	#0x6, sp
4cb2:  0d4a           mov	r10, r13
4cb4:  0e49           mov	r9, r14
4cb6:  0f48           mov	r8, r15
4cb8:  b012 3248      call	#0x4832 <add_to_table>
4cbc:  0e3c           jmp	#0x4cda <run+0x174>
4cbe:  3f40 544b      mov	#0x4b54, r15
4cc2:  b012 504d      call	#0x4d50 <puts>
4cc6:  1f43           mov	#0x1, r15
4cc8:  3150 0006      add	#0x600, sp
4ccc:  3741           pop	r7
4cce:  3841           pop	r8
4cd0:  3941           pop	r9
4cd2:  3a41           pop	r10
4cd4:  3b41           pop	r11
4cd6:  3041           ret
4cd8:  1b53           inc	r11
4cda:  fb90 3b00 0000 cmp.b	#0x3b, 0x0(r11)
4ce0:  fb27           jeq	#0x4cd8 <run+0x172>

<check_nonempty>
4ce2:  6f4b           mov.b	@r11, r15
4ce4:  4f93           tst.b	r15
4ce6:  6b23           jnz	#0x4bbe <run+0x58> ;; check_if_a
4ce8:  0e43           clr	r14
4cea:  603f           jmp	#0x4bac <run+0x46>
