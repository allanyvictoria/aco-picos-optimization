# Etapa de Algoritmo de Colônia de Formigas (ACO) aplicado à função Picos

Esta etapa adapta a meta-heurística de Otimização por Colônia de Formigas (ACO), originalmente pensada para o Problema do Caixeiro Viajante, para buscar o máximo e o mínimo globais da função Picos. O domínio contínuo [-3, 3] x [-3, 3] é discretizado em uma grade de 256x256 pontos (65.536 vértices), e as formigas se deslocam entre pontos vizinhos usando a vizinhança de Moore (8 direções).

## Arquivos

- `main_max.m`: busca do máximo global, execução única, com plotagem gráfica da solução a cada iteração e da curva de convergência ao final. Serve como demonstração ilustrada do funcionamento do algoritmo.
- `main_min.m`: mesma lógica de `main_max.m`, buscando o mínimo global.
- `acoMax.m`: versão do ACO atualizada, roda 100 execuções independentes em lote, com a grade e a vizinhança pré-calculadas uma única vez (para reduzir o tempo total de execução), e salva os resultados em CSV. É este script que sustenta os números da Tabela 2 do relatório (busca do máximo).
- `acoMin.m`: mesma lógica de `acoMax.m`, para a busca do mínimo global.

`main_max.m`/`main_min.m` e `acoMax.m`/`acoMin.m` implementam o mesmo algoritmo; a diferença é que os primeiros fazem uma única execução com visualização gráfica passo a passo (bons para entender e demonstrar o funcionamento do ACO), enquanto os segundos rodam o bloco de 100 execuções independentes e exportam os dados usados na análise estatística do relatório.

## Saída de `acoMax.m` e `acoMin.m`

Cada script gera três arquivos CSV:

- `aco_max_execucoes.csv` / `aco_min_execucoes.csv`: colunas `execucao, x, y, fval_max` (ou `fval_min`), uma linha por execução.
- `aco_max_medias.csv` / `aco_min_medias.csv`: colunas `metrica, x, y, fval_max` (ou `fval_min`), com as linhas `media`, `desvio_padrao`, `melhor` e `pior`.
- `aco_max_convergencia.csv` / `aco_min_convergencia.csv`: colunas `iteracao, media_fval, desvio_padrao`, usada para a curva de convergência.

## Dependências

Todos os quatro scripts chamam as funções `CreateModel.m`, `CalcCost.m`, `obter_vizinhos.m`, `RouletteWheelSelection.m` e `PlotSolution.m`, que estão em `../common/aco-lib/`. Copie esses cinco arquivos para esta pasta antes de executar, ou adicione a pasta ao caminho do Octave:

```
addpath('../common/aco-lib')
```

## Como executar

Demonstração com visualização gráfica (execução única):
```
main_max
main_min
```

```