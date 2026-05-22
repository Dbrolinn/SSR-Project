	.file	"vuln.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Error: null input rejected\n"
	.text
	.p2align 4
	.type	process_request.part.0, @function
process_request.part.0:
.LFB36:
	.cfi_startproc
	movq	stderr(%rip), %rcx
	movl	$27, %edx
	movl	$1, %esi
	leaq	.LC0(%rip), %rdi
	jmp	fwrite@PLT
	.cfi_endproc
.LFE36:
	.size	process_request.part.0, .-process_request.part.0
	.section	.rodata.str1.1
.LC1:
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
	movq	%fs:40, %rax
	movq	%rax, 264(%rsp)
	xorl	%eax, %eax
	testq	%rdi, %rdi
	je	.L8
	movq	%rsp, %r8
	movq	%rdi, %rsi
	movl	$255, %edx
	movq	%r8, %rdi
	call	strncpy@PLT
	leaq	.LC1(%rip), %rsi
	movl	$1, %edi
	movq	%rax, %rdx
	xorl	%eax, %eax
	call	__printf_chk@PLT
.L3:
	movq	264(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L9
	addq	$280, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L8:
	.cfi_restore_state
	call	process_request.part.0
	jmp	.L3
.L9:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE34:
	.size	process_request, .-process_request
	.section	.rodata.str1.1
.LC2:
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
	leaq	.LC2(%rip), %rdi
	call	process_request
	call	process_request.part.0
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
