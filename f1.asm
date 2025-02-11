global f1
extern printf

section .data
    msg_sucesso db "Bloco %d: Endereco %d a %d", 10, 0
    msg_erro db "Erro: Nao ha espaco suficiente.", 10, 0

section .text
f1:
    enter 0, 0
    mov eax, [ebp+8]    ; prog_size
    mov ecx, [ebp+12]   ; num_blocos
    mov edi, [ebp+16]   ; blocos

    xor edx, edx        ; índice do bloco
.check_block:
    mov ebx, [edi + edx*8]     ; endereço do bloco
    mov esi, [edi + edx*8 + 4] ; tamanho do bloco
    cmp eax, esi
    jle .allocate
    inc edx
    cmp edx, ecx
    jl .check_block

    ; Caso erro
    push msg_erro
    call printf
    add esp, 4
    jmp .end

.allocate:
    inc edx             ; bloco indexado a partir de 1
    mov ecx, ebx        ; salva endereço inicial
    lea ebx, [ecx + eax - 1] ; endereço final

    ; Passa parâmetros para printf via f2
    push ebx            ; fim
    push ecx            ; inicio
    push edx            ; num_bloco
    push msg_sucesso    ; formato
    call printf
    add esp, 16

.end:
    leave
    ret
