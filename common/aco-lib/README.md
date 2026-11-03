# Funções de apoio do ACO

Funções auxiliares usadas pela implementação do Algoritmo de Colônia de Formigas (ACO), compartilhadas pelos projetos `03-aco-picos/` e `04-sga-vs-acs/`. Eram arquivos idênticos duplicados nas duas pastas originais; foram unificados aqui para evitar redundância.

- `CreateModel.m`: cria o modelo do espaço de busca (grade discretizada da função Picos).
- `CalcCost.m`: calcula o valor da função objetivo em um ponto da grade.
- `obter_vizinhos.m`: define a vizinhança de Moore usada no deslocamento das formigas.
- `RouletteWheelSelection.m`: seleção probabilística do próximo passo, ponderada por feromônio e heurística.
- `PlotSolution.m`: visualização da solução encontrada.

## Como usar

Antes de executar `main_max.m` ou `main_min.m` (em `03-aco-picos/`) ou `acoMax.m` ou `acoMin.m` (em `04-sga-vs-acs/`), copie estes cinco arquivos para a mesma pasta do script, ou adicione esta pasta ao caminho do Octave:

```
addpath('../common/aco-lib')
```
