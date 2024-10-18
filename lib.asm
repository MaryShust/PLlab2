%include "lib.inc"
%define EXIT 60
%define STDIN 0
%define READ 0
%define STDOUT 1
%define WRITE 1

section .text

; Принимает код возврата и завершает текущий процесс
exit: 
    mov rax, EXIT        ; системный вызов exit
    syscall            ; выполнение системного вызова

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    mov rdx, 0
    .loop:
      cmp byte [rdi], 0 ; Проверяем на нуль-терминатор
      je .end     ; Если нуль, выходим из цикла
      inc rdx            ; Увеличиваем длину
      inc rdi            ; Переходим к следующему символу
      jmp .loop    ; Повторяем цикл
    .end:
      mov rax, rdx
      ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rdi ;сохраняем, потому что указатель на строку пригодится для вывода
    call string_length ; в rax лежит длина строки
    pop rsi     ; указатель на строку
    mov rdx, rax
    mov rdi, STDOUT  ; дескриптор файла(stdout)
    mov rax, WRITE  ; Номер системного вызова для write
    syscall     ; Выполнение системного вызова для вывода строки
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push rdi ; сохраняем rdi
    mov rax, WRITE
    mov rdi, STDOUT
    mov rsi, rsp ; указываем rsi на верхушку стека (там символ)
    mov rdx, 1
    syscall
    pop rdi
  ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, `\n`
    jmp print_char
    


; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:            
    mov rax, rdi

    ; Создаем буфер для строки
    mov rcx, rsp
    sub rsp, 24             ; Выделяем место для 20 символов (достаточно для 64-битного числа)
    sub rcx, rsp           ; Счётчик
    dec rcx
    mov rsi, 10           ; Делитель для десятичной системы

    .div:
        xor rdx, rdx      ; Очищаем rdx перед делением
        div rsi           ; Делим rax на 10, результат в rax, остаток в rdx
        add dl, '0'       ; Преобразуем остаток в ASCII
        dec rcx
        mov [rsp + rcx], dl ; Сохраняем символ в буфере
        test rax, rax     ; Проверяем, есть ли еще цифры
        jnz .div          ; Если rax не ноль, делим дальше


    mov byte [rsp + 23], 0 ; Нуль-терминатор в конец строки
    ; Выводим цифры
    
    lea rdi, [rsp+rcx]           ; Указываем rdi на начало буфера
    call print_string       ; Вызываем функцию для печати строки

    add rsp, 24             ; Освобождаем место в стеке
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    test rdi, rdi
    jns .print      ; если неотрицательное, то просто печатаем
    push rdi     ; сохраняем rdi(пригодится для печати)
    mov rdi, '-'  ; печатаем минус
    call print_char
    pop rdi
    neg rdi     ; Инвертируем, чтобы потом напечаталось правильно (исходное же отрицательное)

    .print:
        jmp print_uint  ; Перенаправляем для вывода числа, тк знак уже напечатан


; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rax, rax            ; rax = 0
	.loop:
		mov al, [rdi]           ; Загружаем байт из первой строки
		mov r8b, [rsi]           ; Загружаем байт из второй строки
		cmp al, r8b             ; Сравниваем байты
		jne .not_equal          ; Если они не равны, переход

		test al, al             ; Проверка на конец (z выставится)
		jz .equal               ; Если конец, возвращаем 1

		inc rdi                 ; Переходим к следующему байту в первой строке
		inc rsi                 ; Переходим к следующему байту во второй строке
		jmp .loop               ; Возвращаемся к началу цикла

	.not_equal:
		mov rax, 0
		ret                     ; Возвращаемся

	.equal:
		mov rax, 1
		ret                      ; Возвращаемся

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    sub rsp, 8 ; выделяем место на стеке для хранения
    mov rax, READ; Номер системного вызова для read
    mov rdi, STDIN ; дескриптор файла (stdin)
    mov rsi, rsp ; загружаем адрес для хранения
    mov rdx, 1     ;читаем 1 байт
    syscall
    cmp rax, 1    ; Сравниваем число прочитанных байт с 1
    jne .end_inp   ; Если не 1, значит, достигнут конец потока
    mov rax, [rsp]  ; кладём символ в rax
    jmp .end
    .end_inp:
    	xor rax, rax
    .end:
      add rsp, 8  ; возвращаем всё как было
      ret 
	

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    push r12      ; будем использовать для адреса(rdi)
    push r13      ; будем использовать для размера(rsi), чтобы не выйти за него и контрить это
    push r14      ; будем использовать для смещения

    mov r12, rdi
    mov r13, rsi
    xor r14, r14
    .loop:
        call read_char ; в rax char

        ; проверка на пробелы и тд и переход, если да
        cmp al, ' '       
        je .white_space
        cmp al, `\t`
        je .white_space
        cmp al, `\n`
        je .white_space

        mov byte[r12 + r14], al ; записываем, если не пробел

        test rax, rax ; проверка на конец потока
        jz .end_inp

        inc r14
        jmp .cont

        .white_space:
            test r14, r14   ; проверка, если пробельный символ не в начале, то сворачиваемся, иначе всё норм
            jnz .end_inp

        
        .cont:
            cmp r14, r13  ; проверка на отсутствие переполнения, если не записать, а надо, то переход
            jg .err
            jmp .loop

    .err:
        xor rax, rax
        xor rdx, rdx
        jmp .end

    .end_inp:
        mov rax, r12
        mov rdx, r14

    .end:
        pop r14
        pop r13
        pop r12
        ret
    
    

 

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint: 
    xor rax, rax        ; Обнуляем rax для хранения числа
    xor rsi, rsi
    mov r11, 10
    xor rdx, rdx
    xor rcx, rcx

    .loop:
        ; проверяем на то, что символ цифра
        mov cl, byte[rdi + rsi]
        cmp rcx, "0"        
        jb .end
        cmp rcx, "9"
        ja .end

        .add: ; добавляем, если цифра
            sub rcx, "0" ; Преобразуем в ASCII
            mul r11
            add rax, rcx
            inc rsi
            jmp .loop  
    .end:
        mov rdx, rsi
        ret 




; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось

parse_int:
    xor rax, rax        ; Обнуляем rax для хранения числа
    xor rdx, rdx        ; Обнуляем rdx для хранения длины
    xor rsi, rsi

    .loop:
        mov sil, byte[rdi + rdx]
        ; проверяем на то, что символ цифра, если минус, то просто скип, если не минус и не цифра, то сворачиваемся
        cmp sil, "-"
        je .next
        cmp sil, "0"
        jb .end
        cmp sil, "9"
        ja .end
        .add:   ; добавляем, если цифра
            sub sil, "0" ; Преобразуем в ASCII
            imul rax, rax, 10
            add rax, rsi
            jmp .next

        .next:
            inc rdx
            jmp .loop

        
    .end:  ; перед концом проверяем на '-', если был, инвертируем число
        cmp byte[rdi], "-"
        je .neg
        ret 

    .neg:
        neg rax
        ret

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    xor rax, rax
	.loop:
		cmp rax, rdx           ; Проверяем, есть ли место в буфере
		jz .err
		mov cl, [rdi + rax]    ; Получаем символ
		mov [rsi + rax], cl    ; Сохраняем символ
		test cl, cl            ; Проверяем на конец
		jz .end               ; Сворачиваемся, если 0
		inc rax
		jmp .loop
	.end:
		ret
	.err:
		mov rax, 0
		ret








; функция для чтения строки
; ввод-вывод как в read_word
read_str:
    push r12      ; будем использовать для адреса(rdi)
    push r13      ; будем использовать для размера(rsi), чтобы не выйти за него и контрить это
    push r14      ; будем использовать для смещения

    mov r12, rdi
    mov r13, rsi
    xor r14, r14

.loop:
    call read_char ; в rax char

    cmp rax, 0x0A  ; проверка на \n
    je .end_inp    ; если \n, завершаем чтение

    mov byte[r12 + r14], al ; записываем символ в буфер

    test rax, rax ; проверка на конец потока
    jz .end_inp

    inc r14
    jmp .cont

.cont:
    cmp r14, r13  ; проверка на отсутствие переполнения, если не записать, а надо, то переход
    jge .err
    jmp .loop

.err:
    xor rax, rax
    xor rdx, rdx
    jmp .end

.end_inp:
    mov byte[r12 + r14], 0 ; заменяем символ новой строки на нулевой символ
    mov rax, r12
    mov rdx, r14

.end:
    pop r14
    pop r13
    pop r12
    ret