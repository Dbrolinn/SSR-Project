	.file	"vuln.c"
	.text
	.globl	validate_packet
	.type	validate_packet, @function
validate_packet:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	-8(%rbp), %rax
	movl	$32, (%rax)
	movq	-16(%rbp), %rax
	movss	.LC0(%rip), %xmm0
	movss	%xmm0, (%rax)
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	cmpl	$64, %eax
	jbe	.L2
	movl	$0, %eax
	jmp	.L3
.L2:
	movl	$1, %eax
.L3:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	validate_packet, .-validate_packet
	.section	.rodata
.LC1:
	.string	"Strict Aliasing Demo"
.LC2:
	.string	"PASSED!"
	.align 8
.LC3:
	.string	"actual memory value processed: %u <-- bypass vulnerability!\n"
	.align 8
.LC4:
	.string	"PACKET DROPPED! actual memory value: %u\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -16(%rbp)
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	leaq	-16(%rbp), %rdx
	leaq	-16(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	validate_packet
	movl	%eax, -12(%rbp)
	cmpl	$1, -12(%rbp)
	jne	.L5
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	movl	-16(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC3(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L6
.L5:
	movl	-16(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC4(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.L6:
	movl	$0, %eax
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L8
	call	__stack_chk_fail@PLT
.L8:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.section	.rodata
	.align 4
.LC0:
	.long	1073741824
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
