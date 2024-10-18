%include "dict.inc"

find_word:
    push rbx
    push r12
    push r13
    sub rsp, 8      
    mov r12, rsi       
    xor r13, r13

.loop:
    cmp r12, 0          ; Не достигли ли конца
    je .not_found       ; Если достигли, переходим к .not_found

    lea rsi, [r12 + 8]  ; Устанавливаем rsi на ключ текущего элемента словаря
    push rdi
    push rsi
    call string_length  ; Находим длину, понадобится для вывода
    mov r13, rax
    pop rsi
    pop rdi
    call string_equals  ; Сравниваем строки
    cmp rax, 1          ; Проверяем, равны, или нет
    je .found           

    mov r12, qword[r12] ; Переходим к следующему элементу словаря
    jmp .loop           

.found:
    ; Адрес начала вхождения в словарь
    mov rax, r12       
    add rax, r13       
    inc rax
    jmp .end         

.not_found:
    mov rax, 0          ; 0, если не нашли

.end:
    pop r13
    pop r12             
    pop rbx             
    add rsp, 8          ; Возвращаем всё на место
    ret                 
