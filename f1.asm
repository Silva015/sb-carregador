section .data
msg db "Bloco %d - Endereço: %d | Fim: %d", 0   ; String terminada em 0

section .text
f1:
    ; Prologo da função f1
    enter 0, 0

    ; Recebe os parâmetros pela pilha
    mov eax, [ebp+8]    ; Tamanho do programa (prog_size)
    mov ecx, [ebp+12]   ; Número de blocos (num_blocos)
    mov edi, [ebp+16]   ; Ponteiro para o array de blocos

    ; Processa os blocos
    xor edx, edx        ; Zera o índice de blocos
.check_block:
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
    lea ebx, [ebx + eax - 1]   ; Calcula o endereço final

    ; Passa o endereço da string para f2
    lea edi, [msg]             ; Carrega o endereço da string
    push edi                   ; Passa o endereço da string
    push dword [edi + edx*8]   ; Passa o endereço inicial
    push dword ebx             ; Passa o endereço final
    call f2

.end:
    leave
    ret
