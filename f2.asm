global f2

section .data
    msg_alocacao db "Bloco %d: Endereco %d a %d", 10, 0
    msg_erro     db "Erro: Nao ha espaco suficiente.", 10, 0
    prefix1      db "Bloco ", 0        ; "Bloco " com espaço no final
    prefix1_len  equ 6
    prefix2      db ": Endereco ", 0   ; ": Endereco " com espaço no final
    prefix2_len  equ 11
    infix        db " a ", 0
    infix_len    equ 3
    newline      db 10, 0
    space        db " ", 0           ; string contendo um espaço

section .text
f2:
    push ebp
    mov ebp, esp
    sub esp, 40             ; reserva 40 bytes para buffers
    push esi                ; preserva registradores
    push edi

    ; Lê o primeiro caractere da mensagem de formatação (parâmetro 1)
    mov eax, [ebp+8]
    mov al, byte [eax]
    cmp al, 'B'
    je .alloc_msg          ; se "Bloco", formata mensagem de alocação
    cmp al, 'E'
    je .error_msg          ; se "Erro", imprime mensagem de erro

.print_default:
    ; Imprime a string passada sem formatação
    mov esi, [ebp+8]
    xor ecx, ecx
.print_loop:
    cmp byte [esi+ecx], 0
    je .print_done
    inc ecx
    jmp .print_loop
.print_done:
    mov edx, ecx           ; tamanho da string
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, [ebp+8]
    int 0x80
    jmp .f2_end

.alloc_msg:
    ; --- Imprime "Bloco " ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prefix1
    mov edx, prefix1_len    ; imprime "Bloco " (inclui o espaço final)
    int 0x80

    ; --- Converte e imprime o número do bloco ---
    mov eax, [ebp+12]       ; número do bloco
    lea edi, [ebp-12]       ; buffer temporário para conversão
    call itoa               ; converte; comprimento retornado em EAX
    mov edx, eax            ; tamanho da string do número
    mov eax, 4
    mov ebx, 1
    lea ecx, [ebp-12]
    int 0x80

    ; --- Imprime um espaço extra para separar "Bloco " do número ---
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    ; --- Imprime ": Endereco " ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prefix2
    mov edx, prefix2_len    ; imprime ": Endereco " (com espaço final)
    int 0x80

    ; --- Converte e imprime o endereço inicial ---
    mov eax, [ebp+16]       ; endereço inicial
    lea edi, [ebp-24]       ; buffer temporário
    call itoa
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    lea ecx, [ebp-24]
    int 0x80

    ; --- Imprime " a " ---
    mov eax, 4
    mov ebx, 1
    mov ecx, infix
    mov edx, infix_len
    int 0x80

    ; --- Converte e imprime o endereço final ---
    mov eax, [ebp+20]       ; endereço final
    lea edi, [ebp-36]       ; buffer temporário
    call itoa
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    lea ecx, [ebp-36]
    int 0x80

    ; --- Imprime nova linha ---
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp .f2_end

.error_msg:
    ; Imprime a mensagem de erro diretamente
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
    pop edi               ; restaura registradores
    pop esi
    mov esp, ebp
    pop ebp
    ret

; itoa: Converte o inteiro (em EAX) para uma string decimal.
; O resultado é escrito no buffer apontado por EDI.
; Retorna em EAX o comprimento da string.
itoa:
    push ebp
    mov ebp, esp
    sub esp, 16           ; reserva 16 bytes para variável local
    push ebx
    push ecx
    push edx
    push esi

    cmp eax, 0
    jne .itoa_nonzero
    mov byte [edi], '0'   ; Se número for 0, escreve "0"
    mov eax, 1
    jmp .itoa_end

.itoa_nonzero:
    mov ebx, eax          ; copia do número
    mov ecx, 1            ; divisor inicial = 1
.compute_divisor:
    mov eax, ecx
    mov edx, 10
    mul edx               ; eax = ecx * 10
    test edx, edx         ; se ocorre overflow, usamos ecx atual
    jnz .divisor_found
    cmp eax, ebx
    jg .divisor_found
    mov ecx, eax
    jmp .compute_divisor

.divisor_found:
    mov dword [ebp-4], ecx  ; salva o divisor atual
    xor esi, esi          ; contador de dígitos = 0
.convert_loop:
    cmp ecx, 0
    je .itoa_done_loop    ; termina quando divisor = 0
    mov eax, ebx
    xor edx, edx
    div ecx               ; eax = dígito atual, edx = resto
    add al, '0'           ; converte dígito para ASCII
    mov [edi], al
    inc edi
    inc esi               ; contador++
    mov ebx, edx          ; atualiza número com o resto
    ; Atualiza divisor: divisor = divisor / 10
    mov eax, ecx
    xor edx, edx
    push 10
    div dword [esp]
    add esp, 4
    mov ecx, eax
    jmp .convert_loop
.itoa_done_loop:
    mov eax, esi          ; comprimento da string
.itoa_end:
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret
