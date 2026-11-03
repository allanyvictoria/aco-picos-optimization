# Iniciação Científica 2025/2026: Metaheurísticas Aplicadas à Função Picos

Repositório com os scripts em GNU Octave, dados de resultados e relatórios produzidos ao longo da Iniciação Científica, sob orientação do Prof. Dr. Delmar Broglio Carvalho, pela acadêmica Allany Victória Santos Araújo.

O trabalho investiga o comportamento de diferentes metaheurísticas (Algoritmo Genético e Otimização por Colônia de Formigas) na busca dos pontos de máximo e mínimo globais da função Picos, uma superfície multimodal amplamente usada como benchmark de otimização.

## Estrutura do repositório

```
.
├── 01-ga-picos/              Etapa 1: GA aplicado à função Picos no domínio completo
├── 02-qga-quadrantes/        Etapa 2: análise do GA por quadrantes (Q-GA)
├── 03-aco-picos/             Etapa 3: ACO aplicado à função Picos discretizada
├── 04-sga-vs-acs/            Etapa 4: comparação entre SGA e ACS
└── common/aco-lib/           Funções de apoio do ACO, reutilizadas nas etapas 3 e 4
```

Cada pasta numerada corresponde a uma etapa do projeto e a um relatório em `docs/`, na mesma ordem cronológica.

## Etapas do projeto

### 1. `01-ga-picos/`
Primeira aplicação do pacote `ga` do GNU Octave à função Picos, buscando o ponto de mínimo e o ponto de máximo no domínio completo [-3, 3] x [-3, 3], com 100 execuções independentes. Inclui também o script de derivadas simbólicas usado para validar analiticamente os pontos críticos encontrados.

### 2. `02-qga-quadrantes/`
Extensão do experimento anterior, dividindo o espaço de busca em quatro quadrantes e restringindo o GA a cada um deles (metodologia Q-GA), usando uma função de criação de população customizada e uma função de penalidade para forçar o confinamento. A pasta `preliminares/` guarda o teste inicial (restrito ao Quadrante IV) que evidenciou a necessidade da penalidade, conforme descrito no relatório.

### 3. `03-aco-picos/`
Implementação do Algoritmo de Colônia de Formigas (ACO) sobre a função Picos discretizada em uma malha de 256x256 pontos, com vizinhança de Moore. Depende das funções de apoio em `common/aco-lib/`.

### 4. `04-sga-vs-acs/`
Comparação estatística entre o Algoritmo Genético Simples (SGA) e o Ant Colony System (ACS) na mesma função de teste, com 100 execuções independentes para cada algoritmo. Contém os dados brutos, os dados normalizados e o script que gera essa normalização. Também depende das funções de apoio em `common/aco-lib/`.

## Como executar os scripts

Os scripts foram escritos e testados em GNU Octave, com o pacote `ga` instalado (`pkg load ga`) para os experimentos com Algoritmo Genético, e o pacote `symbolic` (`pkg load symbolic`) para o script de derivadas.

As pastas `03-aco-picos/` e `04-sga-vs-acs/` dependem das funções auxiliares do ACO reunidas em `common/aco-lib/` (`CalcCost.m`, `CreateModel.m`, `PlotSolution.m`, `RouletteWheelSelection.m`, `obter_vizinhos.m`). Antes de rodar `main_max.m`, `main_min.m`, `acoMax.m` ou `acoMin.m`, copie esses cinco arquivos para a mesma pasta do script que será executado, ou adicione `common/aco-lib` ao caminho do Octave com `addpath`.
