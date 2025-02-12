# README - Projeto Carregador

Este projeto implementa um programa chamado **Carregador**, que simula a alocação de um programa fictício em blocos de memória. O programa é desenvolvido em **C** e **Assembly NASM IA-32**, seguindo as especificações fornecidas.

---

## Especificações do Projeto

O programa **Carregador** deve:
1. Ser chamado pela linha de comando com o seguinte formato:
   ```
   ./carregador <tamanho-programa> <addr1> <size1> [<addr2> <size2>] ...
   ```
   - `<tamanho-programa>`: Tamanho do programa fictício a ser carregado.
   - `<addrX>`: Endereço inicial de um bloco de memória livre.
   - `<sizeX>`: Tamanho do bloco de memória livre.

2. Verificar se o programa cabe em um único bloco de memória. Se não couber, deve dividir o programa em partes, utilizando o máximo possível de cada bloco na ordem fornecida.

3. Exibir mensagens indicando os blocos de memória utilizados, com os endereços inicial e final de cada parte do programa.

4. Caso não haja espaço suficiente, exibir uma mensagem de erro.

---

## Como Compilar e Executar

### Pré-requisitos
- **NASM**: Assembler para compilar o código Assembly.
- **GCC**: Compilador para o código C.
- **Sistema Operacional**: Linux (testado em distribuições baseadas em Debian).

### Passos para Compilação

1. **Compilar o código Assembly:**
   ```bash
   nasm -f elf32 f1.asm -o f1.o
   nasm -f elf32 f2.asm -o f2.o
   ```

2. **Compilar o código C e linkar com o Assembly:**
   ```bash
   gcc -m32 main.c f1.o f2.o -o carregador
   ```

3. **Executar o programa:**
   ```bash
   ./carregador <tamanho-programa> <addr1> <size1> [<addr2> <size2>] ...
   ```

---

## Exemplos de Uso

### Exemplo 1: Alocação em um único bloco
**Entrada:**
```bash
./carregador 200 100 500
```
**Saída Esperada:**
```
Bloco 1: Endereco 100 a 299
```

### Exemplo 2: Alocação em múltiplos blocos
**Entrada:**
```bash
./carregador 600 100 300 500 400 1000 500
```
**Saída Esperada:**
```
Bloco 1: Endereco 100 a 399
Bloco 2: Endereco 500 a 699
```

### Exemplo 3: Espaço insuficiente
**Entrada:**
```bash
./carregador 1000 100 200 300 400
```
**Saída Esperada:**
```
Erro: Nao ha espaco suficiente.
```

---

## Detalhes de Implementação

### Estrutura do Projeto
- **main.c**: Programa principal em C que lê os argumentos da linha de comando e chama as funções em Assembly.
- **f1.asm**: Função em Assembly que realiza os cálculos de alocação de memória.
- **f2.asm**: Função em Assembly que imprime as mensagens na tela.

### Funcionamento
1. **Fase 1 (Alocação Única):**
   - O programa tenta alocar o programa inteiro em um único bloco de memória.
   - Se encontrar um bloco adequado, exibe o resultado e finaliza.

2. **Fase 2 (Alocação em Partes):**
   - Se o programa não couber em um único bloco, ele é dividido em partes, utilizando o máximo possível de cada bloco na ordem fornecida.
   - O programa exibe os endereços inicial e final de cada parte alocada.

3. **Mensagem de Erro:**
   - Caso não haja espaço suficiente, o programa exibe uma mensagem de erro.

---

## Observações
- **Ordem FIFO:** Os blocos são processados na ordem em que são fornecidos na linha de comando.
- **Mensagens de Saída:** As mensagens são formatadas para facilitar a interpretação dos resultados.
- **Restrições:** Nenhum parâmetro da linha de comando é salvo como variável global no programa em C. Todos os parâmetros são passados para as funções em Assembly pela pilha.

---

## Testes Realizados
O programa foi testado com diversos cenários, incluindo:
- Alocação em um único bloco.
- Alocação em múltiplos blocos.
- Casos com espaço insuficiente.
- Entradas inválidas (tamanho do programa zero ou número ímpar de argumentos).

---

## Autor
- [Arthur Silva Carneiro] - 202006321

---

## Contato
Para dúvidas ou sugestões, entre em contato:
- Email: [tutuscarneiro@gmail.com]
- Repositório: [https://github.com/Silva015/sb-carregador]

---
