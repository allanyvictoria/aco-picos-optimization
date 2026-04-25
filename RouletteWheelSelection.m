%% @file RouletteWheelSelection.m
% @brief Seleciona um índice aleatório com base em probabilidades (método da roleta).
%
% @details
% Implementa o método de seleção proporcional por roleta (roulette wheel selection),
% amplamente utilizado em algoritmos evolutivos e de colônia de formigas.
% Cada índice tem probabilidade de ser selecionado proporcional ao seu valor em P.
%
% O método funciona da seguinte forma:
%   1. Gera um número aleatório r em [0, 1]
%   2. Calcula a soma cumulativa de P
%   3. Retorna o primeiro índice onde a soma cumulativa supera r
%
% Exemplo:
%   P = [0.1  0.4  0.3  0.2]
%   C = [0.1  0.5  0.8  1.0]
%   Se r = 0.35 → C(2) = 0.5 >= 0.35 → retorna j = 2
%
% @param P Vetor de probabilidades (deve somar 1 e ter todos valores >= 0)
%
% @retval j Índice selecionado (1 a length(P))
%
% @author Baseado no código de Yarpiz (www.yarpiz.com)
% @date 2025

function j = RouletteWheelSelection(P)

    % Gera um número aleatório uniforme entre 0 e 1
    r = rand;

    % Calcula a soma cumulativa das probabilidades
    C = cumsum(P);

    % Retorna o primeiro índice onde a soma cumulativa ultrapassa r
    j = find(r <= C, 1, 'first');

end
