%include "dict.inc"

find_word:
    push rbx
    push r12
    push r13
    sub rsp, 8
    mov r12, rsi        ; Устанавливаем указатель на первый элемент словаря
    xor rax, rax        ; Обнуляем rax (используется для хранения результата)
.loop:
    test r12, r12       ; Проверяем, не нулевой ли указатель
    jz .not_found       ; Если да, то переходим к .not_found
    lea rsi, [r12 + 8]  ; Указываем на ключ текущего элемента словаря
    push rdi
    push rsi
    call string_length   ; Получаем длину ключа
    mov r13, rax        ; Сохраняем длину в r13
    pop rsi
    pop rdi
    call string_equals   ; Сравниваем строки
    test rax, rax        ; Проверяем, равны ли строки
    jz .next             ; Если не равны, переходим к следующему элементу
    ; Слова совпали
    lea rax, [r12 + r13 + 8] ; Указываем на адрес начала совпадения
    jmp .end             ; Переходим к завершению
.next:
    mov r12, [r12]      ; Переходим к следующему элементу словаря
    jmp .loop            ; Продолжаем цикл
.not_found:
    xor rax, rax        ; Устанавливаем rax в 0 (что означает, что не нашли)
.end:
    pop r13
    pop r12
    pop rbx
    add rsp, 8          ; Восстанавливаем стек
    ret
