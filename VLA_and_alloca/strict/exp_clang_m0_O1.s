	.text
	.file	"vuln.c"
	.globl	validate                # -- Begin function validate
	.p2align	4, 0x90
	.type	validate,@function
validate:                               # @validate
	.cfi_startproc
# %bb.0:
	movl	$1000, (%rdi)           # imm = 0x3E8
	movw	$64, (%rsi)
	xorl	%eax, %eax
	retq
.Lfunc_end0:
	.size	validate, .Lfunc_end0-validate
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	leaq	12(%rsp), %rdi
	movq	%rdi, %rsi
	callq	validate
	movl	%eax, %ebx
	movl	12(%rsp), %esi
	movl	$.L.str, %edi
	xorl	%eax, %eax
	callq	printf
	testl	%ebx, %ebx
	movl	$.Lstr, %eax
	movl	$.Lstr.3, %edi
	cmoveq	%rax, %rdi
	callq	puts
	xorl	%eax, %eax
	addq	$16, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"final stored value reading as the int pointer = %d\n"
	.size	.L.str, 52

	.type	.Lstr,@object           # @str
.Lstr:
	.asciz	"stayed 1000"
	.size	.Lstr, 12

	.type	.Lstr.3,@object         # @str.3
.Lstr.3:
	.asciz	"changed to 64"
	.size	.Lstr.3, 14

	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
	.addrsig
