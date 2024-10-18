all: lab2

lab2: main.o lib.o dict.o
	ld -o lab2 main.o lib.o dict.o -e _start

main.o: main.asm
	nasm -f elf64 -o main.o main.asm

lib.o: lib.asm
	nasm -f elf64 -o lib.o lib.asm

dict.o: dict.asm
	nasm -f elf64 -o dict.o dict.asm
	
test_lab2: lab2
	python3 test.py

clean:
	rm -f lab2 main.o lib.o dict.o
