	.file	"vuln.c"
	.text
	.globl	validate
	.type	validate, @function
validate:
.LFB34:
	.cfi_startproc
	endbr64
	movl	$1000, (%rdi)
	movw	$64, (%rsi)
	cmpl	$65, (%rdi)
	setle	%al
	movzbl	%al, %eax
	ret
	.cfi_endproc
.LFE34:
	.size	validate, .-validate
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"final stored value reading as the int pointer = %d\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"changed to 64"
.LC2:
	.string	"stayed 1000"
	.text
	.globl	main
	.type	main, @function
main:
.LFB35:
	.cfi_startproc
	endbr64
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	movq	%fs:40, %rax
	movq	%rax, 8(%rsp)
	xorl	%eax, %eax
	movl	$1000, 4(%rsp)
	movw	$64, 4(%rsp)
	movl	4(%rsp), %ebx
	movl	%ebx, %edx
	leaq	.LC0(%rip), %rsi
	movl	$1, %edi
	call	__printf_chk@PLT
	cmpl	$65, %ebx
	jg	.L3
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
.L4:
	movq	8(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L7
	movl	$0, %eax
	addq	$16, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
.L3:
	.cfi_restore_state
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L7:
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
