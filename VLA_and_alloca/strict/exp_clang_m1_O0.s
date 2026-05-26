	.text
	.file	"fixed.c"
	.globl	validate                # -- Begin function validate
	.p2align	4, 0x90
	.type	validate,@function
validate:                               # @validate
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -16(%rbp)
	movq	-16(%rbp), %rax
	movl	$1000, (%rax)           # imm = 0x3E8
	movw	$64, -18(%rbp)
	movq	-16(%rbp), %rax
	movw	-18(%rbp), %cx
	movw	%cx, (%rax)
	movq	-16(%rbp), %rax
	cmpl	$64, (%rax)
	jle	.LBB0_2
# %bb.1:
	movl	$0, -4(%rbp)
	jmp	.LBB0_3
.LBB0_2:
	movl	$1, -4(%rbp)
.LBB0_3:
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movl	$0, -4(%rbp)
	leaq	-8(%rbp), %rdi
	callq	validate
	movl	%eax, -12(%rbp)
	movl	-8(%rbp), %esi
	movabsq	$.L.str, %rdi
	movb	$0, %al
	callq	printf
	cmpl	$0, -12(%rbp)
	je	.LBB1_2
# %bb.1:
	movabsq	$.L.str.1, %rdi
	movb	$0, %al
	callq	printf
	jmp	.LBB1_3
.LBB1_2:
	movabsq	$.L.str.2, %rdi
	movb	$0, %al
	callq	printf
.LBB1_3:
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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

	.type	.L.str.1,@object        # @.str.1
.L.str.1:
	.asciz	"changed to 64\n"
	.size	.L.str.1, 15

	.type	.L.str.2,@object        # @.str.2
.L.str.2:
	.asciz	"stayed 1000\n"
	.size	.L.str.2, 13

	.ident	"clang version 10.0.0-4ubuntu1 "
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym validate
	.addrsig_sym printf
