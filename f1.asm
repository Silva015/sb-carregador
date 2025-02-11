global f1
extern f2

section .data
    msg_alocacao db "Bloco %d: Endereco %d a %d", 10, 0
    msg_erro db "Erro: Nao ha espaco suficiente.", 10, 0

section .text
f1:
    enter 16, 0
    mov eax, [ebp+8]          ; Tamanho do programa
    mov [ebp-4], eax          ; remaining
    mov ecx, [ebp+12]         ; num_blocos
    mov edi, [ebp+16]         ; blocos
    mov dword [ebp-8], 0      ; Índice do bloco (Fase 1)
    mov dword [ebp-12], 0     ; Acumulador de espaço total

    ; Fase 1: Verifica se cabe em um bloco e acumula espaço total
.phase1_loop:
    mov edx, [ebp-8]
    cmp edx, ecx
    jge .verifica_espaco_total
    
    ; Acumula espaço do bloco atual
    mov ebx, [edi + edx*8 + 4]
    add [ebp-12], ebx
    
    ; Verifica se cabe no bloco atual
    cmp ebx, [ebp-4]
    jl .phase1_next
    
    ; Cabe no bloco atual (alocação única)
    mov eax, [edi + edx*8]
    mov edx, [ebp-4]
    lea ebx, [eax + edx - 1]
    push ebx
    push eax
    mov eax, [ebp-8]
    inc eax
    push eax
    push msg_alocacao
    call f2
    add esp, 16
    jmp .fim

.phase1_next:
    inc dword [ebp-8]
    jmp .phase1_loop

.verifica_espaco_total:
    ; Verifica se o espaço total é suficiente
    mov eax, [ebp-12]
    cmp eax, [ebp-4]
    jl .erro

    ; Fase 2: Alocação em partes (FIFO)
    mov dword [ebp-8], 0      ; Reinicia o índice
.phase2_loop:
    cmp dword [ebp-4], 0
    jle .fim
    
    mov edx, [ebp-8]
    cmp edx, ecx
    jge .erro
    
    mov eax, [edi + edx*8]     ; Endereço do bloco
    mov esi, [edi + edx*8 + 4] ; Tamanho do bloco
    
    ; Determina quanto usar deste bloco
    mov edx, [ebp-4]
    cmp esi, edx
    jl .usar_todo_bloco
    mov esi, edx

.usar_todo_bloco:
    sub [ebp-4], esi           ; Atualiza remaining
    lea ebx, [eax + esi - 1]   ; Endereço final
    
    ; Imprime a alocação
    push ebx
    push eax
    mov eax, [ebp-8]
    inc eax
    push eax
    push msg_alocacao
    call f2
    add esp, 16
    
    inc dword [ebp-8]          ; Próximo bloco
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