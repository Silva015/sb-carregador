; f2.asm
; Compile com: nasm -f elf32 f2.asm -o f2.o
global f2           ; Torna o símbolo f2 visível para o linker

section .text
f2:
    ; Prologo da convenção cdecl
    enter 0, 0       ; Cria o frame da pilha

    ; Recebe os parâmetros:
    ; [ebp+8] -> mensagem (formatada)
    ; [ebp+12] -> endereço inicial
    ; [ebp+16] -> endereço final
    mov edi, [ebp+12]  ; O primeiro parâmetro (mensagem) está em [ebp+8]
    mov esi, [ebp+16]  ; Endereço inicial
    mov edx, [ebp+20]  ; Endereço final

    ; Calcula o tamanho da string (mensagem)
    xor ecx, ecx      ; Inicializa o contador
.len_loop:
    cmp byte [edi+ecx], 0  ; Verifica o fim da string
    je .len_done
    inc ecx
    jmp .len_loop
.len_done:

    ; Chama o sistema para imprimir (sys_write)
    mov eax, 4        ; Syscall número 4 (write)
    mov ebx, 1        ; File descriptor 1 = stdout
    mov edx, ecx      ; Tamanho da string
    int 0x80          ; Interrupção para chamar o kernel

    ; Epílogo
