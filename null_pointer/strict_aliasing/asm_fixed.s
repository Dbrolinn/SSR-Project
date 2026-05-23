	.file	"fixed.c"
	.text
	.p2align 4
	.globl	validate_packet
	.type	validate_packet, @function
validate_packet:
.LFB34:
	.cfi_startproc
	endbr64
	movl	$1073741824, (%rdi)
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE34:
	.size	validate_packet, .-validate_packet
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Strict Aliasing Demo FIXED"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC1:
	.string	"PACKET DROPPED. Actual memory value: %u\n"
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
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	movl	$1073741824, %edx
	leaq	.LC1(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
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
