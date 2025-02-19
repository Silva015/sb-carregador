global f1
extern f2

section .data
    msg_alocacao db "Bloco ", 0
    msg_erro     db "Erro: Nao ha espaco suficiente.", 10, 0

section .text
f1:
    enter 24, 0
    ; Carrega parâmetros:
    ; [ebp+8]  = prog_size (tamanho do programa)
    ; [ebp+12] = num_blocos
    ; [ebp+16] = ponteiro para vetor de blocos (cada bloco: endereço, tamanho)
    mov eax, [ebp+8]          ; prog_size
    mov [ebp-4], eax          ; remaining = prog_size
    mov ecx, [ebp+12]         ; num_blocos
    mov edi, [ebp+16]         ; ponteiro para blocos
    mov dword [ebp-8], 0      ; i = 0
    mov dword [ebp-12], 0     ; total_space = 0

    ; --- Ordena os blocos por endereço (Bubble Sort) ---
    mov esi, ecx
    dec esi
    mov dword [ebp-16], 0     ; outer index = 0
.outer_loop:
    cmp dword [ebp-16], esi
    jge .end_sort
    mov dword [ebp-20], 0     ; inner index = 0
.inner_loop:
    mov eax, esi
    sub eax, [ebp-16]
    cmp dword [ebp-20], eax
    jge .end_inner
    mov edx, [ebp-20]
    ; Compara os endereços de blocos consecutivos
    mov eax, [edi + edx*8]          ; bloco atual
    mov ebx, [edi + edx*8 + 8]        ; próximo bloco
    cmp eax, ebx
    jle .no_swap
    ; Troca os endereços
    mov [edi + edx*8], ebx
    mov [edi + edx*8 + 8], eax
    ; Troca os tamanhos correspondentes
    mov eax, [edi + edx*8 + 4]
    mov ebx, [edi + edx*8 + 12]
    mov [edi + edx*8 + 4], ebx
    mov [edi + edx*8 + 12], eax
.no_swap:
    inc dword [ebp-20]
    jmp .inner_loop
.end_inner:
    inc dword [ebp-16]
    jmp .outer_loop
.end_sort:

    ; --- Fase 1: Acumula espaço total dos blocos ---
.phase1_loop:
    mov edx, [ebp-8]          ; i
    cmp edx, ecx              ; se i >= num_blocos, sair
    jge .verifica_espaco_total
    mov ebx, [edi + edx*8 + 4]  ; bloco[i].size
    add [ebp-12], ebx         ; total_space += bloco[i].size
    inc dword [ebp-8]         ; i++
    jmp .phase1_loop

.verifica_espaco_total:
    mov eax, [ebp-12]         ; total_space
    cmp eax, [ebp-4]          ; se total_space < prog_size, erro
    jl .erro

    ; --- Fase 2: Alocação em partes (FIFO) ---
    mov dword [ebp-8], 0      ; reinicia i = 0
.phase2_loop:
    cmp dword [ebp-4], 0      ; enquanto remaining > 0
    jle .fim
    mov edx, [ebp-8]          ; i
    cmp edx, ecx            ; se i >= num_blocos, erro
    jge .erro
    mov esi, [edi + edx*8 + 4] ; tamanho do bloco atual
    cmp esi, 0
    jle .pular_bloco        ; se tamanho == 0, pula o bloco
    mov eax, [edi + edx*8]    ; endereço inicial do bloco
    cmp esi, [ebp-4]
    jle .usar_todo_bloco    ; se bloco inteiro <= remaining, usa ele
    mov esi, [ebp-4]         ; senão, usa apenas o restante necessário
.usar_todo_bloco:
    sub [ebp-4], esi         ; remaining -= quantidade usada
    lea ebx, [eax + esi - 1] ; endereço final = start + amount - 1
    ; Chama f2 com 4 parâmetros: msg_alocacao, (i+1), endereço inicial, endereço final
    push ebx                 ; endereço final
    push eax                 ; endereço inicial
    mov eax, [ebp-8]
    inc eax                  ; número do bloco = i + 1
    push eax
    push msg_alocacao
    call f2
    add esp, 16
.pular_bloco:
    inc dword [ebp-8]        ; passa para o próximo bloco
    jmp .phase2_loop

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
