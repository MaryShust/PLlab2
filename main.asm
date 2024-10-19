global _start
section .data
msg_noword: db "No such word",0

section .data
%include "colon.inc"

section .text
%define d_err 2
%define d_out 1

extern find_word
extern read_word
extern string_length
extern print_string
extern print_newline

_start:
	mov rsi, last
.link_loop:
	mov r12, rsi  ; текущий элемент
	mov rsi, [rsi] ; адрес предыдущего
	test rsi, rsi
	jz .ent
	mov [rsi + 8], r12
	jmp .link_loop
.ent:
	mov rsi, 255
	sub rsp, 256
	mov rdi, rsp
	call read_word
	test rax, rax
	jz .bad
	mov rdi, rax
	mov rsi, last
	call find_word
	test rax, rax
	jz .bad
	add rax, 16
	mov r10, rax
	call string_length
	add r10, rax
	mov rdi, r10
	inc rdi
	mov r15, d_out
	call print_string
.exit:
	call print_newline
	mov rdi, rax
	mov rax, 60	; number 'exit'
	syscall
.bad:
	mov rdi, msg_noword
	call string_length
	mov rsi, rax
	mov r15, d_err
	call print_string
	jmp .exit

.list_linker:
	; rsi - last word




