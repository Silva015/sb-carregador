/* main.c */
#include <stdio.h>
#include <stdlib.h>

// Declaração das funções Assembly.
// f1 recebe: (int prog_size, int num_blocos, int *blocos)
// f2 será chamada internamente por f1.
extern void f1(int prog_size, int num_blocos, int *blocos);

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <tamanho-programa> [<addr1> <size1> ...]\n", argv[0]);
        return 1;
    }
    
    // Converte o primeiro argumento para inteiro (tamanho do programa fictício)
    int prog_size = atoi(argv[1]);
    
    // Se houverem argumentos adicionais, eles representam pares (endereço, tamanho)
    int num_blocos = 0;
    if (argc > 2) {
        num_blocos = (argc - 2) / 2; // cada bloco tem 2 parâmetros
    }
    
    // Armazena os valores dos blocos em um vetor local (nunca globais)
    // Aqui assumimos que o máximo é 4 blocos (8 inteiros), mas você pode ajustar conforme a necessidade.
    int blocos[8] = {0};
    for (int i = 0; i < num_blocos * 2; i++) {
        blocos[i] = atoi(argv[i + 2]);
    }
    
    // Chama a função f1 em Assembly.
    // Para esse teste de "Hello World", f1 ignorará os parâmetros e chamará f2 para imprimir.
    f1(prog_size, num_blocos, blocos);
    
    return 0;
}
