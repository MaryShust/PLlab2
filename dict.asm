;section .data
;	message:
;		db "hello", 0

global find_word
extern string_equals

%include "colon.inc"

global _start

section .text

find_word:
									; rdi = address of a null terminated word name
									; rsi = address of the last word
									; returns: rax = 0 if not found, otherwise address
												

mov r8, rdi													

.loop:

	mov r9, rsi
	cmp rsi, 0 						; установит EF = 0, только если  rsi == null
	je .exit_false 					; выйдем и скажем, что ничего не нашли
	mov rdi, r8						; вернем строку в rdi
	add rsi, 8						; смотрим что там за строка
	call string_equals				; сравниваем строки
	mov rsi, r9						; возвращаем rsi на место (после string_equals у нас укзатель на конец строки)
	cmp rax, 0 						; если строки равны сохраняем указатель на нее и выходим
	jnz .exit_true
	mov rsi, [rsi]					; если не равны смотрим следующее слово
    jmp .loop
	
.exit_true:							; если нашли строку - сохраняем указатель на нее
	mov rax, rsi
	ret 
	
.exit_false:
	mov rax, 0						; если не нашли - сохраняем null
	ret
	
	
;_start:
;	mov rdi, message
;	mov rsi, lw
;	call find_word
;	mov rdi, rax
;	mov rax, 60
;	syscall	
