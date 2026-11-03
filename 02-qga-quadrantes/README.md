# Etapa de Análise por Quadrantes do GA (Q-GA)


## Arquivos

- `gaQ.m`: script final do experimento Q-GA. Divide o espaço de busca em quatro quadrantes, usa uma função de criação de população customizada (`criar_populacao_confinada`) e uma função de penalidade (`fitness_confinado`) para forçar o confinamento do GA em cada quadrante, e executa 100 rodadas independentes para cada uma das 16 combinações de quadrante, tamanho de população (10 ou 20) e número de gerações (25 ou 50). Calcula aptidão máxima, aptidão média, aptidão normalizada, aptidão média normalizada, variância dessas duas normalizações e o Z-Score do melhor indivíduo, exportando os resultados brutos e o resumo estatístico em CSV.
- `preliminares/testeIV.m`: teste inicial, restrito ao Quadrante IV, no qual os limites do quadrante foram passados diretamente nas opções `lb`/`ub` do `ga`. O relatório descreve que essa abordagem falhou em confinar o algoritmo (o GA encontrava o máximo global, que existe apenas nos Quadrantes I/II), o que motivou a criação da função de penalidade usada em `gaQ.m`. Este script é mantido como registro desse teste preliminar.

## Como executar

```
pkg load ga
gaQ
```
