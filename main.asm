%include "main.inc"
%include "words.inc"

section .data
    buffer: times 256 db 0
    not_found_word: db "Word not found"
    very_long: db "Buffer overflow"

section .text
global _start

_start:
    ; Чтение строки
    mov rdi, buffer
    mov rsi, 255
    call read_str

    ; Поиск слова
    mov rdi, buffer
    
    mov rsi, end_point
    test rax, rax
    je .overflow
    
    call find_word

    ; Проверка
    cmp rax, 0
    je .not_found

    ; Вывод значения
    add rax, 8 
    mov rdi, rax
    call print_string
    call print_newline
    jmp .exit

.not_found:
    ; Вывод, если не найдено
    mov rsi, not_found_word
    mov rdx, 14
    jmp .ng

.overflow:
    ; Вывод, если буфер переполнен
    mov rsi, very_long
    mov rdx, 15
    jmp .ng

.ng:
    mov rax, 1
    mov rdi, 2
    syscall
    call print_newline

.exit:
    call exit
