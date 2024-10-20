section .data
	msg: db "No word", 0

global _start	
	
section .text
%include "colon.inc"

extern read_word
extern find_word
extern string_length
extern print_string
extern print_newline

_start: 
	
	mov rsi, 255			; максимум, что мы можем записать в буфер
	sub rsp, 256			; место под буфер
	
	mov rdi, rsp			; скажем ему куда записываем слово
	call read_word			; оно нам вернет где начало слово (в rax)
	
	cmp rax, 0				; тут надо проверить если в rax 0
	je .false
	 
	mov rdi, rax
	mov rsi, lw
	call find_word			; возвращает указатель на строку
	cmp rax, 0
	je .false
	add rax, 8				; указатель на начало строки, а не на адрес следующего слова	
	mov r10, rax 
	mov rdi, rax
							; дальше нам надо найти строку по метке 
							;(для этого надо найти сначала метку, которая лежит после строки)
		 						
	call string_length
	add r10, rax			; сдвинем указатель на начало метки
	inc r10					; учитываем \0
	mov rdi, r10	
	
	mov r15, 1				; дескриптор для stdout
	call print_string
	
.exit:	
	call print_newline
	mov rax, 60 
	mov rdi, rax 			; чтобы echo выводило то, что у нас возвращает find_word
	syscall
	ret
	
.false:
	mov rdi, msg			; если нет слова - то так и напишем :)
	call string_length
	mov rsi, rax
	
	mov r15, 2				; дескриптор для ошибок
	call print_string
	jmp .exit
	
