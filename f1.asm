; f1.asm
global f1
extern f2

section .data
    msg_alocacao db "Bloco ", 0
    msg_erro     db "Erro: Nao ha espaco suficiente.", 10, 0

section .text
f1:
    enter 16, 0
    ; Parâmetros:
    ; [ebp+8]  = prog_size (tamanho do programa)
    ; [ebp+12] = num_blocos
    ; [ebp+16] = ponteiro para o vetor de blocos (cada bloco: endereço, tamanho)

    mov eax, [ebp+8]          ; prog_size
    mov [ebp-4], eax          ; remaining = prog_size
    mov ecx, [ebp+12]         ; num_blocos
    mov edi, [ebp+16]         ; ponteiro para o vetor de blocos
    mov dword [ebp-8], 0      ; i = 0 (índice do bloco na Fase 1)
    mov dword [ebp-12], 0     ; total_space acumulado = 0

    ;-------------------------------
    ; Fase 1: Verifica se algum bloco único comporta o programa
.phase1_loop:
    mov edx, [ebp-8]          ; i
    cmp edx, ecx
    jge .verifica_espaco_total
    ; Obtém o tamanho do bloco atual: blocos[i].size
    mov ebx, [edi + edx*8 + 4]
    add [ebp-12], ebx         ; total_space += bloco[i].size
    ; Se o bloco atual tem espaço suficiente para o programa:
    cmp ebx, [ebp-4]          ; se bloco[i].size >= remaining
    jl .phase1_next
    ; Alocação única: usa o bloco atual
    mov eax, [edi + edx*8]      ; endereço inicial do bloco
    mov edx, [ebp-4]            ; remaining (tamanho do programa)
    lea ebx, [eax + edx - 1]    ; endereço final = start + remaining - 1
    ; Chama f2 com os 4 parâmetros:
    ;   1. msg_alocacao
    ;   2. número do bloco (i + 1)
    ;   3. endereço inicial
    ;   4. endereço final
    push ebx                  ; endereço final
    push eax                  ; endereço inicial
    mov eax, [ebp-8]          
    inc eax                   ; número do bloco = i + 1
    push eax
    push msg_alocacao
    call f2
    add esp, 16
    jmp .fim

.phase1_next:
    inc dword [ebp-8]         ; i++
    jmp .phase1_loop

    ;-------------------------------
.verifica_espaco_total:
    ; Se a soma total dos blocos for menor que o tamanho do programa, não há espaço suficiente
    mov eax, [ebp-12]         ; total_space acumulado
    cmp eax, [ebp-4]
    jl .erro

    ;-------------------------------
    ; Fase 2: Alocação em partes (FIFO)
    mov dword [ebp-8], 0      ; reinicia i para percorrer os blocos
.phase2_loop:
    cmp dword [ebp-4], 0      ; enquanto remaining > 0
    jle .fim
    mov edx, [ebp-8]          ; i
    cmp edx, ecx            ; se i >= num_blocos, erro (não há blocos suficientes)
    jge .erro
    ; Obtém o endereço inicial e tamanho do bloco atual
    mov eax, [edi + edx*8]     ; endereço inicial do bloco
    mov esi, [edi + edx*8 + 4] ; tamanho do bloco
    ; Se o bloco tem mais espaço do que o que falta, usa apenas o que falta
    cmp esi, [ebp-4]
    jle .usar_todo_bloco
    mov esi, [ebp-4]          ; usa o restante necessário
.usar_todo_bloco:
    sub [ebp-4], esi          ; remaining -= quantidade alocada
    lea ebx, [eax + esi - 1]  ; endereço final = endereço inicial + quantidade - 1
    ; Chama f2 com os 4 parâmetros (sem push/pop extra):
    push ebx                  ; endereço final
    push eax                  ; endereço inicial
    mov eax, [ebp-8]
    inc eax                   ; número do bloco (i + 1)
    push eax
    push msg_alocacao
    call f2
    add esp, 16
    inc dword [ebp-8]         ; passa para o próximo bloco
    jmp .phase2_loop

    ;-------------------------------
.erro:
    cmp dword [ebp-4], 0
    jg .imprimir_erro
    jmp .fim

.imprimir_erro:
    push msg_erro
    call f2
    add esp, 4

.fim:
    leave
    ret
