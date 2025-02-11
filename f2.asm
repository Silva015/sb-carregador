; f2.asm
; Compile com: nasm -f elf32 f2.asm -o f2.o
global f2

section .text
f2:
    ; Prologo padrão cdecl
    push ebp
    mov ebp, esp

    ; f2 espera receber um parâmetro: ponteiro para a mensagem (char *)
    ; O parâmetro estará em [ebp+8]
    mov edi, [ebp+8]  ; EDI recebe o ponteiro para a mensagem

    ; Calcula o tamanho da string (procura o terminador 0)
    mov ecx, 0        ; ECX será usado como contador de caracteres
.len_loop:
    cmp byte [edi+ecx], 0
    je .len_done
    inc ecx
    jmp .len_loop
.len_done:
    ; Prepara e faz a chamada de sistema sys_write
    ; Sys_write: eax = 4, ebx = file descriptor, ecx = buffer, edx = tamanho
    mov eax, 4        ; número da syscall write
    mov ebx, 1        ; file descriptor 1 = stdout
    mov edx, ecx      ; tamanho da string
    mov ecx, edi      ; ponteiro para a string
    int 0x80          ; chama o kernel

    ; Epilogo
    mov esp, ebp
    pop ebp
    ret
