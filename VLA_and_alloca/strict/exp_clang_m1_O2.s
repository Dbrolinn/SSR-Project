	.text
	.file	"fixed.c"
	.globl	validate                # -- Begin function validate
	.p2align	4, 0x90
	.type	validate,@function
validate:                               # @validate
	.cfi_startproc
# %bb.0:
	movl	$64, (%rdi)
	movl	$1, %eax
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
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.L.str, %edi
	movl	$64, %esi
	xorl	%eax, %eax
	callq	printf
	movl	$.Lstr.3, %edi
	callq	puts
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"final stored value read via int = %d\n"
	.size	.L.str, 38

	.type	.Lstr.3,@object         # @str.3
.Lstr.3:
	.asciz	"changed to 64"
	.size	.Lstr.3, 14

	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
	.addrsig
