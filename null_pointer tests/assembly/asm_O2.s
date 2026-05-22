	.file	"vuln.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Processing: %s\n"
	.text
	.p2align 4
	.globl	process_request
	.type	process_request, @function
process_request:
.LFB34:
	.cfi_startproc
	endbr64
	subq	$280, %rsp
	.cfi_def_cfa_offset 288
	movq	%rdi, %rsi
	movl	$255, %edx
	movq	%fs:40, %rax
	movq	%rax, 264(%rsp)
	xorl	%eax, %eax
	movq	%rsp, %r8
	movq	%r8, %rdi
	call	strncpy@PLT
	leaq	.LC0(%rip), %rsi
	movl	$1, %edi
	movq	%rax, %rdx
	xorl	%eax, %eax
	call	__printf_chk@PLT
	movq	264(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L5
	addq	$280, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L5:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE34:
	.size	process_request, .-process_request
	.section	.rodata.str1.1
.LC1:
	.string	"hello"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB35:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	.LC1(%rip), %rdi
	call	process_request
	xorl	%edi, %edi
	call	process_request
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE35:
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
