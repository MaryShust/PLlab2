%include "dict.inc"

find_word:
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r12, rsi       
    xor r13, r13

.loop:
    test r12, r12      ; Проверяем, не равен ли нулю указатель
    jz .not_found       ; Если ноль, переходим к .not_found

    lea rsi, [r12 + 8]  ; Указываем rsi на текущий ключ
    call string_length  ; Длина строки
    mov r13, rax        ; Сохраняем длину
    call string_equals  ; Сравниваем строки
    cmp rax, 1          ; Проверка на равенство
    je .found           ; Если равны, переходим к .found

    mov r12, qword[r12] ; Переходим к следующему элементу
    jmp .loop           ; Повторяем цикл

.found:
    mov rax, r12       ; Загружаем адрес найденного слова
    add rax, r13       
    inc rax            ; Сдвигаем указатель
    jmp .end           ; Переходим к завершению

.not_found:
    xor rax, rax       ; Устанавливаем 0, если не найдено

.end:
    pop r13
    pop r12             
    pop rbx             
    add rsp, 8         
    ret                 
