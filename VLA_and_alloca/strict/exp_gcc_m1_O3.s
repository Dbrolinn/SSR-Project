	.file	"fixed.c"
	.text
	.p2align 4
	.globl	validate
	.type	validate, @function
validate:
.LFB34:
	.cfi_startproc
	endbr64
	movl	$64, (%rdi)
	movl	$1, %eax
	ret
	.cfi_endproc
.LFE34:
	.size	validate, .-validate
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"final stored value read via int = %d\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"changed to 64"
.LC2:
	.string	"stayed 1000"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB35:
	.cfi_startproc
	endbr64
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$64, %edx
	movl	$1, %edi
	movq	%fs:40, %rax
	movq	%rax, 8(%rsp)
	xorl	%eax, %eax
	movl	$1000, 4(%rsp)
	leaq	.LC0(%rip), %rsi
	movw	%dx, 4(%rsp)
	movl	4(%rsp), %edx
	cmpl	$64, %edx
	jg	.L4
	call	__printf_chk@PLT
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
.L5:
	movq	8(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L8
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L4:
	.cfi_restore_state
	xorl	%eax, %eax
	call	__printf_chk@PLT
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	jmp	.L5
.L8:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE35:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
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
