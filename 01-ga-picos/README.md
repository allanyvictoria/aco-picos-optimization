# Etapa de Algoritmo Genético aplicado à função Picos

Relatório correspondente: `../docs/2025-09_relatorio_ga-picos-octave.pdf`.

## Arquivos

- `ga_picos.m`: script principal. Define a função Picos como função objetivo, configura o pacote `ga` do Octave e executa 100 rodadas independentes de busca do mínimo e do máximo, salvando os resultados em CSV.
- `derivadas_simbolicas.m`: calcula as derivadas parciais da função Picos com o pacote `symbolic` e tenta resolver o sistema de derivadas nulas, usado para validar analiticamente os pontos críticos encontrados pelo GA.
- `verificaDefault.m`: script auxiliar que lista as opções padrão do GA no Octave (`gaoptimset`), usado para documentar quais parâmetros foram deixados no valor padrão.
- `resultados_execucoes.csv`: resultado de cada uma das 100 execuções (coordenadas e valor de fitness do mínimo e do máximo encontrados).
- `resultados_medias.csv`: estatísticas agregadas (média, desvio padrão, melhor e pior caso) das 100 execuções.

## Como executar

```
pkg load ga
ga_picos
```

Para a análise simbólica:

```
pkg load symbolic
derivadas_simbolicas
```
