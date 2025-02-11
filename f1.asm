; f1.asm
; Compile com: nasm -f elf32 f1.asm -o f1.o
global f1           ; Torna o símbolo f1 visível para o linker
extern f2           ; A função f2 será chamada para imprimir os resultados

section .text
f1:
    ; Prologo: Cria o frame da pilha
    enter 0, 0       ; Cria o frame da pilha (não usamos variáveis locais extras)

    ; Recebe os parâmetros pela pilha
    ; [ebp+8] -> prog_size (tamanho do programa)
    ; [ebp+12] -> num_blocos (número de blocos)
    ; [ebp+16] -> blocos (ponteiro para o array de blocos)
    mov eax, [ebp+8]    ; Tamanho do programa (prog_size)
    mov ecx, [ebp+12]   ; Número de blocos (num_blocos)
    mov edi, [ebp+16]   ; Ponteiro para o array de blocos

    ; Processa os blocos
    xor edx, edx        ; Zera o índice de blocos
.check_block:
    ; Acessa o endereço e o tamanho do bloco (blocos[i * 2], blocos[i * 2 + 1])
    mov ebx, [edi + edx*8]         ; Endereço do bloco
    mov esi, [edi + edx*8 + 4]     ; Tamanho do bloco
    cmp eax, esi                   ; Verifica se o programa cabe neste bloco
    jle .allocate                  ; Se couber, aloca o programa
    add edx, 1                     ; Se não couber, vai para o próximo bloco
    cmp edx, ecx                   ; Verifica se há mais blocos
    jl .check_block
    ; Se o programa não couber, chama a função de erro
    push dword "Programa não cabe nos blocos apresentados."
    call f2
    jmp .end

.allocate:
    ; Calcula o endereço final do programa no bloco
    ; endereço_final = endereço_inicial + tamanho_programa - 1
    lea ebx, [ebx + eax - 1]   ; Calcula o endereço final

    ; Agora passamos as informações para a função f2 para impressão
    ; Passa "Bloco X - Endereço: <endereco_inicial> | Fim: <endereco_final>"
    push dword ebx                ; Endereço final
    push dword [edi + edx*8]      ; Endereço inicial
    push dword msg               ; Mensagem formatada
    call f2

.end:
    ; Epílogo: Restaura o frame da pilha
    leave
    ret

section .data
msg db "Bloco %d - Endereço: %d | Fim: %d", 0  ; A string termina com 0 para indicar o fim
