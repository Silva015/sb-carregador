; f1.asm
; Compile com: nasm -f elf32 f1.asm -o f1.o
global f1           ; torna o símbolo f1 visível para o linker
extern f2           ; indica que a função f2 será definida em outro arquivo

section .data
    hello_msg db "Hello World", 10, 0   ; "Hello World" seguido de nova linha e finalizado com 0

section .text
f1:
    ; Prologo padrão da convenção cdecl
    push ebp
    mov ebp, esp

    ; Para teste, ignoramos os parâmetros (prog_size, num_blocos, blocos)
    ; e simplesmente empilhamos o endereço de hello_msg para chamar f2.
    push dword hello_msg
    call f2
    add esp, 4        ; limpa o parâmetro da pilha

    ; Epilogo
    mov esp, ebp
    pop ebp
    ret
