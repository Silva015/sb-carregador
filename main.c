/* main.c */
#include <stdio.h>
#include <stdlib.h>

// Declaração das funções Assembly
extern void f1(int prog_size, int num_blocos, int *blocos);
extern void f2(void);

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <tamanho-programa> <addr1> <size1> [<addr2> <size2>] ...\n", argv[0]);
        return 1;
    }

    // Converte o primeiro argumento para inteiro (tamanho do programa fictício)
    int prog_size = atoi(argv[1]);

    // Verifica quantos blocos foram passados (pares de parâmetros)
    int num_blocos = (argc - 2) / 2;

    // Cria um array para armazenar os blocos
    int blocos[num_blocos * 2];
    for (int i = 0; i < num_blocos * 2; i++) {
        blocos[i] = atoi(argv[i + 2]);
    }

    // Imprime os parâmetros lidos da linha de comando
    printf("Tamanho do programa: %d\n", prog_size);
    printf("Número de blocos: %d\n", num_blocos);
    for (int i = 0; i < num_blocos; i++) {
        printf("Bloco %d - Endereço: %d, Tamanho: %d\n", i + 1, blocos[i * 2], blocos[i * 2 + 1]);
    }

    // Passa o ponteiro do array blocos para a função f1 em Assembly
    f1(prog_size, num_blocos, blocos);

    // Chama a função f2 para imprimir o resultado
    f2();

    return 0;
}
