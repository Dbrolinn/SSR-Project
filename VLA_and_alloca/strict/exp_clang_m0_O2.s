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
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.L.str, %edi
	movl	$64, %esi
	xorl	%eax, %eax
	callq	printf
	movl	$.Lstr, %edi
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
	.asciz	"final stored value reading as the int pointer = %d\n"
	.size	.L.str, 52

	.type	.Lstr,@object           # @str
.Lstr:
	.asciz	"stayed 1000"
	.size	.Lstr, 12

	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
	.addrsig
