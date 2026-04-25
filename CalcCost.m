%% @file CalcCost.m
% @brief Retorna o valor da função Picos em um ponto do grid.
%
% @details
% Acessa o vetor de custos pré-calculados no modelo e retorna
% o valor de f(x,y) correspondente ao ponto de índice i.
% O custo é calculado uma única vez no CreateModel e armazenado
% em model.Cost para evitar recálculo durante o algoritmo.
%
% @param i     Índice linear do ponto no grid (1 a model.n)
% @param model Struct do problema gerada por CreateModel()
%
% @retval cost Valor da função Picos f(x,y) no ponto i
%
% @author Allany Victória Santos Araújo
% @date 2025

function cost = CalcCost(i, model)
    % Retorna o custo do ponto i usando o vetor de custos model.Cost
    cost = model.Cost(i);
end
