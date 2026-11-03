# Etapa de Comparação entre Algoritmo Genético (SGA) e Ant Colony System (ACS)

Esta etapa compara o desempenho do Algoritmo Genético Simples (SGA), operando em domínio contínuo, com o Ant Colony System (ACS), operando em uma malha discretizada de 256x256 pontos, na busca do mínimo e do máximo globais da função Picos. Cada algoritmo foi executado 100 vezes de forma independente.

## Scripts principais

- `AG-ajustado.m`: versão inicial do AG adaptado para este experimento (100 execuções, mesmos parâmetros do AG original). Não salva a curva de convergência por geração, apenas os resultados finais de cada execução. Foi a base a partir da qual `agConvergencia.m` foi construído.
- `agConvergencia.m`: versão final do AG usada neste experimento. Mantém os mesmos parâmetros de `AG-ajustado.m`, mas adiciona o rastreamento do melhor valor encontrado a cada geração, usando variáveis globais dentro das funções de fitness (`fitness_min_tracker` e `fitness_max_tracker`). Está organizado como uma função (`ag_run()`), então para executar é necessário chamar `ag_run` no console do Octave.
- `acoMin.m`: ACS buscando o mínimo global, 100 execuções independentes, com grade e vizinhança pré-calculadas para reduzir o tempo de execução.
- `acoMax.m`: mesma lógica de `acoMin.m`, mas buscando o máximo global.


## Dependências

`acoMin.m` e `acoMax.m` chamam as funções `CreateModel.m`, `CalcCost.m` e `obter_vizinhos.m`, que estão em `../common/aco-lib/`. Copie esses arquivos para esta pasta antes de executar, ou adicione a pasta ao caminho do Octave:

```
addpath('../common/aco-lib')
```

`agConvergencia.m` e `AG-ajustado.m` dependem apenas do pacote `ga` do Octave (`pkg load ga`).

## Estrutura de resultados

```
resultados/
├── AG-resultados(min_max)/          saída de agConvergencia.m
│   ├── ag_min_execucoes.csv         execucao, x, y, fval_min (uma linha por execução)
│   ├── ag_min_medias.csv            metrica, x, y, fval_min (media, desvio_padrao, melhor, pior)
│   ├── ag_min_convergencia.csv      geracao, media_fval, desvio_padrao
│   ├── ag_max_execucoes.csv
│   ├── ag_max_medias.csv
│   └── ag_max_convergencia.csv
├── acoMAX-resultados/                saída de acoMax.m
│   ├── aco_max_execucoes.csv        execucao, x, y, fval_max
│   ├── aco_max_medias.csv           metrica, x, y, fval_max
│   └── aco_max_convergencia.csv     iteracao, media_fval, desvio_padrao
└── acoMIN-resultados/                saída de acoMin.m (execução de maio de 2026)
    ├── aco_min_execucoes.csv
    ├── aco_min_medias.csv
    └── aco_min_convergencia.csv

```



## Normalização para as figuras do artigo (`normalizados/`)

- `gerar_normalizados.m`: lê os quatro arquivos de convergência (`aco_min_convergencia.csv`, `aco_max_convergencia.csv`, `ag_min_convergencia.csv`, `ag_max_convergencia.csv`) e aplica normalização min-max, usando os ótimos teóricos (-6.5511 para o mínimo e 8.1062 para o máximo) como referência de valor 1.0. 
- `aco_min_norm.csv`, `aco_max_norm.csv`, `ag_min_norm.csv`, `ag_max_norm.csv`: saída já gerada, com as colunas `iteracao, media_norm, desvio_norm`.

Importante: este script espera encontrar os quatro arquivos `*_convergencia.csv` na mesma pasta em que é executado. Como esses arquivos já existem em `resultados/`, copie os quatro `*_convergencia.csv` correspondentes para dentro de `normalizados/` antes de rodar `gerar_normalizados`, ou ajuste os caminhos de leitura no início do script.

## Ordem de execução sugerida

```
1. pkg load ga
2. agConvergencia         (roda ag_run() e gera os CSVs do AG)
3. acoMin                 (depende de common/aco-lib)
4. acoMax                 (depende de common/aco-lib)
5. copiar os quatro *_convergencia.csv gerados para normalizados/
6. gerar_normalizados      (gera os *_norm.csv usados nas figuras do artigo)
```
```