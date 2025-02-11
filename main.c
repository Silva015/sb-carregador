#include <stdio.h>
#include <stdlib.h>

extern void f1(int prog_size, int num_blocos, int *blocos);
extern void f2(void);

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <tamanho-programa> <addr1> <size1> [<addr2> <size2>] ...\n", argv[0]);
        return 1;
    }

    int prog_size = atoi(argv[1]);
    int num_blocos = (argc - 2) / 2;
    int blocos[num_blocos * 2];
    for (int i = 0; i < num_blocos * 2; i++) {
        blocos[i] = atoi(argv[i + 2]);
    }

    f1(prog_size, num_blocos, blocos);
    f2();

    return 0;
}
