	.file	"vuln_vla.c"
	.text
	.p2align 4
	.globl	touch_pages
	.type	touch_pages, @function
touch_pages:
.LFB50:
	.cfi_startproc
	endbr64
	testq	%rsi, %rsi
	je	.L2
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L3:
	leaq	(%rdi,%rax), %rdx
	addq	$4096, %rax
	movb	$0, (%rdx)
	cmpq	%rax, %rsi
	ja	.L3
.L2:
	leaq	-1(%rdi,%rsi), %rax
	movb	$88, (%rax)
	ret
	.cfi_endproc
.LFE50:
	.size	touch_pages, .-touch_pages
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"[vla] allocated %lu bytes, buffer[n-1]=%c\n"
	.text
	.p2align 4
	.globl	process
	.type	process, @function
process:
.LFB51:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rdi, %r8
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	leaq	15(%rdi), %rax
	movq	%rsp, %rsi
	movq	%rax, %rdx
	andq	$-4096, %rax
	subq	%rax, %rsi
	andq	$-16, %rdx
	movq	%rsi, %rax
	cmpq	%rax, %rsp
	je	.L11
.L18:
	subq	$4096, %rsp
	orq	$0, 4088(%rsp)
	cmpq	%rax, %rsp
	jne	.L18
.L11:
	andl	$4095, %edx
	subq	%rdx, %rsp
	testq	%rdx, %rdx
	jne	.L19
.L12:
	movq	%r8, %rsi
	movq	%rsp, %rdi
	call	touch_pages
	xorl	%eax, %eax
	movl	$1, %edi
	leaq	.LC0(%rip), %rsi
	movsbl	-1(%rsp,%r8), %ecx
	movq	%r8, %rdx
	call	__printf_chk@PLT
	movq	-8(%rbp), %rax
	xorq	%fs:40, %rax
	jne	.L20
	leave
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
	.p2align 4,,10
	.p2align 3
.L19:
	.cfi_restore_state
	orq	$0, -8(%rsp,%rdx)
	jmp	.L12
.L20:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE51:
	.size	process, .-process
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	" VLA stack exhaustion"
	.section	.rodata.str1.8
	.align 8
.LC2:
	.string	"Requested allocation: %lu bytes\n"
	.section	.rodata.str1.1
.LC3:
	.string	"[vla] returned normally"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB52:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movl	$64, %ebp
	cmpl	$1, %edi
	jle	.L22
	movq	8(%rsi), %rdi
	movl	$10, %edx
	xorl	%esi, %esi
	call	strtoul@PLT
	movq	%rax, %rbp
.L22:
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	movq	%rbp, %rdx
	movl	$1, %edi
	xorl	%eax, %eax
	leaq	.LC2(%rip), %rsi
	call	__printf_chk@PLT
	movq	%rbp, %rdi
	call	process
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	xorl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE52:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
