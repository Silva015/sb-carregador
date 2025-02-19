; f2.asm – Responsável apenas por fazer o print via sys_write.
; f2 recebe os parâmetros:
;   [ebp+8]  = ponteiro para a mensagem de formatação (pode ser msg_alocacao ou msg_erro)
;   [ebp+12] = número do bloco (em caso de msg_alocacao)
;   [ebp+16] = endereço inicial
;   [ebp+20] = endereço final
; Em caso de mensagem de erro, os outros parâmetros são ignorados.

global f2

section .data
    msg_alocacao db "Bloco %d: Endereco %d a %d", 10, 0
    msg_erro     db "Erro: Nao ha espaco suficiente.", 10, 0
    prefix1      db "Bloco ", 0
    prefix1_len  equ 6
    prefix2      db ": Endereco ", 0
    prefix2_len  equ 11
    infix        db " a ", 0
    infix_len    equ 3
    newline      db 10, 0

section .text
f2:
    push ebp
    mov ebp, esp
    sub esp, 40         ; reserva espaço para buffers de conversão
    push esi            ; Save callee-saved registers
    push edi

    ; Obtém o ponteiro da string (parâmetro 1)
    mov eax, [ebp+8]
    mov al, byte [eax]
    cmp al, 'B'         ; se começa com 'B' (Bloco) → formata mensagem de alocação
    je .alloc_msg
    cmp al, 'E'         ; se começa com 'E' (Erro) → mensagem de erro
    je .error_msg

.print_default:
    ; Imprime a string passada sem formatação
    mov esi, [ebp+8]
    xor ecx, ecx
.len_loop:
    cmp byte [esi+ecx], 0
    je .len_done
    inc ecx
    jmp .len_loop
.len_done:
    mov edx, ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, [ebp+8]
    int 0x80
    jmp .f2_end

.alloc_msg:
    ; Formata e imprime a mensagem de alocação:
    ; "Bloco " + <número do bloco> + ": Endereco " + <endereço inicial> + " a " + <endereço final> + newline
    ; Imprime "Bloco "
    mov eax, 4
    mov ebx, 1
    mov ecx, prefix1
    mov edx, prefix1_len
    int 0x80

    ; Converte o número do bloco ([ebp+12]) para string
    mov eax, [ebp+12]
    lea edi, [ebp-12]
    call itoa           ; itoa retorna tamanho em EAX
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    lea ecx, [ebp-12]
    int 0x80

    ; Imprime ": Endereco "
    mov eax, 4
    mov ebx, 1
    mov ecx, prefix2
    mov edx, prefix2_len
    int 0x80

    ; Converte o endereço inicial ([ebp+16]) para string
    mov eax, [ebp+16]
    lea edi, [ebp-24]
    call itoa
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    lea ecx, [ebp-24]
    int 0x80

    ; Imprime " a "
    mov eax, 4
    mov ebx, 1
    mov ecx, infix
    mov edx, infix_len
    int 0x80

    ; Converte o endereço final ([ebp+20]) para string
    mov eax, [ebp+20]
    lea edi, [ebp-36]
    call itoa
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    lea ecx, [ebp-36]
    int 0x80

    ; Imprime a nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp .f2_end

.error_msg:
    ; Imprime a mensagem de erro (msg_erro)
    lea esi, [msg_erro]
    xor ecx, ecx
.err_len_loop:
    cmp byte [esi+ecx], 0
    je .err_len_done
    inc ecx
    jmp .err_len_loop
.err_len_done:
    mov edx, ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_erro
    int 0x80

.f2_end:
    pop edi             ; Restore callee-saved registers
    pop esi
    mov esp, ebp
    pop ebp
    ret

;-------------------------------------------------------
; itoa: Converte um inteiro (em EAX) para uma string decimal em buffer apontado por EDI.
; Retorna o comprimento da string em EAX.
; Essa implementação:
;   - Se o número for zero, escreve "0" e retorna 1.
;   - Caso contrário, determina o maior divisor (potência de 10) e extrai cada dígito.
itoa:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi

    cmp eax, 0
    jne .itoa_nonzero
    mov byte [edi], '0'
    mov eax, 1
    jmp .itoa_end

.itoa_nonzero:
    mov ebx, eax        ; cópia do número
    mov ecx, 1          ; divisor inicial = 1
.compute_divisor:
    mov eax, ecx
    mov edx, 10
    mul edx             ; eax = ecx*10, edx = parte alta
    test edx, edx       ; verifica overflow (edx != 0)
    jnz .divisor_found  ; se overflow, usa ecx atual
    cmp eax, ebx
    jg .divisor_found
    mov ecx, eax
    jmp .compute_divisor
.divisor_found:
    mov dword [ebp-4], ecx
    xor esi, esi        ; contador de dígitos

.convert_loop:
    cmp ecx, 0
    je .itoa_done_loop
    mov eax, ebx
    xor edx, edx
    div ecx             ; eax = dígito atual, edx = resto
    add al, '0'
    mov [edi], al
    inc edi
    inc esi
    mov ebx, edx        ; Atualiza o número com o resto
    
    ; Atualiza divisor: divisor = divisor / 10 (CORREÇÃO)
    mov eax, ecx        ; eax = divisor atual
    xor edx, edx        ; Limpa edx para a divisão
    push 10             ; Armazena 10 na pilha
    div dword [esp]     ; Divide eax por 10 (usando o valor na pilha)
    add esp, 4          ; Restaura a pilha
    mov ecx, eax        ; Atualiza o divisor
    
    jmp .convert_loop

.itoa_done_loop:
    mov eax, esi      ; retorna o número de dígitos em EAX
.itoa_end:
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret
