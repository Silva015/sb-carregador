global f2
extern printf

section .text
f2:
    enter 0, 0
    ; Parâmetros: [ebp+8] = msg, [ebp+12] = num_bloco, [ebp+16] = start, [ebp+20] = end
    push dword [ebp+20]      ; end
    push dword [ebp+16]      ; start
    push dword [ebp+12]      ; num_bloco
    push dword [ebp+8]       ; msg
    call printf
    add esp, 16
    leave
    ret