global f2
extern printf

section .text
f2:
    ; Esta função agora é redundante, mas mantida para compatibilidade
    ; A impressão é feita diretamente em f1 via printf
    ret
