	.file	"fixed_buffer.c"
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"[fixed-buf] request %lu exceeds limit %d - rejected\n"
	.align 8
.LC1:
	.string	"[fixed-buf] handled %lu bytes safely, buffer[0]=%c\n"
	.text
	.p2align 4
	.globl	process
	.type	process, @function
process:
.LFB50:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	subq	$4096, %rsp
	.cfi_def_cfa_offset 4112
	orq	$0, (%rsp)
	subq	$16, %rsp
	.cfi_def_cfa_offset 4128
	movq	%fs:40, %rax
	movq	%rax, 4104(%rsp)
	xorl	%eax, %eax
	movq	%rdi, %r12
	cmpq	$4096, %rdi
	ja	.L9
	movq	%rsp, %rdi
	movl	$4096, %ecx
	movq	%r12, %rdx
	movl	$65, %esi
	call	__memset_chk@PLT
	movq	4104(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L7
	movq	%r12, %rdx
	movl	$88, %ecx
	movl	$1, %edi
	xorl	%eax, %eax
	addq	$4112, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	leaq	.LC1(%rip), %rsi
	popq	%r12
	.cfi_def_cfa_offset 8
	jmp	__printf_chk@PLT
	.p2align 4,,10
	.p2align 3
.L9:
	.cfi_restore_state
	movq	4104(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L7
	movq	%rdi, %rcx
	movl	$4096, %r8d
	movl	$1, %esi
	xorl	%eax, %eax
	movq	stderr(%rip), %rdi
	addq	$4112, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	leaq	.LC0(%rip), %rdx
	popq	%r12
	.cfi_def_cfa_offset 8
	jmp	__fprintf_chk@PLT
.L7:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE50:
	.size	process, .-process
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC2:
	.string	" Fixed-buffer (safe)"
	.section	.rodata.str1.8
	.align 8
.LC3:
	.string	"Requested allocation: %lu bytes\n"
	.section	.rodata.str1.1
.LC4:
	.string	"[fixed-buf] returned normally"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB51:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movl	$64, %ebp
	cmpl	$1, %edi
	jle	.L11
	movq	8(%rsi), %rdi
	movl	$10, %edx
	xorl	%esi, %esi
	call	strtoul@PLT
	movq	%rax, %rbp
.L11:
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	movq	%rbp, %rdx
	movl	$1, %edi
	xorl	%eax, %eax
	leaq	.LC3(%rip), %rsi
	call	__printf_chk@PLT
	movq	%rbp, %rdi
	call	process
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	xorl	%eax, %eax
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE51:
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
