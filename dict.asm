%include "dict.inc"

section .text
; rdi = address of a null terminated word name
; rsi = address of the last word
; returns: rax = 0 if not found, otherwise address
find_word:
	push r12
	push r13
	xor rax, rax
	mov r12, rdi
.loop:
	mov r13, rsi
	test r13, r13
	jz .didntfound
	add rsi, 16
	mov rdi, r12
	call string_equals
	mov rsi, r13
	test rax, rax
	jne .success
	mov rsi, [rsi]
	jmp .loop
.success:
	mov rax, rsi
	pop r13
	pop r12
	ret
.didntfound:
	mov rsi, 0
	jmp .success
