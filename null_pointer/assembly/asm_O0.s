	.file	"vuln.c"
	.text
	.section	.rodata
.LC0:
	.string	"Error: null input rejected\n"
.LC1:
	.string	"Processing: %s\n"
	.text
	.globl	process_request
	.type	process_request, @function
process_request:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$304, %rsp
	movq	%rdi, -296(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	-296(%rbp), %rax
	movzbl	(%rax), %eax
	movb	%al, -273(%rbp)
	cmpq	$0, -296(%rbp)
	jne	.L2
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$27, %edx
	movl	$1, %esi
	leaq	.LC0(%rip), %rdi
	call	fwrite@PLT
	jmp	.L1
.L2:
	movq	-296(%rbp), %rcx
	leaq	-272(%rbp), %rax
	movl	$255, %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	strncpy@PLT
	leaq	-272(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC1(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.L1:
	movq	-8(%rbp), %rax
	xorq	%fs:40, %rax
	je	.L4
	call	__stack_chk_fail@PLT
.L4:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	process_request, .-process_request
	.section	.rodata
.LC2:
	.string	"hello"
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
	leaq	.LC2(%rip), %rdi
	call	process_request
	movl	$0, %edi
	call	process_request
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
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
