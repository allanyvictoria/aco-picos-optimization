%% @file main_min.m
% @brief Script principal do ACO para busca do mínimo da função Picos.
%
% @details
% Implementa o Algoritmo de Colônia de Formigas (ACO) adaptado para
% espaço contínuo via grid discreto 256x256, com o objetivo de encontrar
% o ponto de mínimo global da função Picos no domínio [-3,3] x [-3,3].
%
% Diferenças em relação ao main_max.m:
%   - BestSol.Cost inicializado com +inf (busca mínimo)
%   - Comparação invertida: aceita ponto se Cost < BestCost
%   - Heurística eta invertida: atrai formigas para regiões de menor valor
%
% Parâmetros principais:
%   - MaxIt  = 300  : número de iterações
%   - nAnt   = 40   : número de formigas
%   - nSteps = 50   : passos por formiga por iteração
%   - alpha  = 1    : peso do feromônio
%   - beta   = 1    : peso da heurística
%   - rho    = 0.05 : taxa de evaporação
%
% @see CreateModel, obter_vizinhos, RouletteWheelSelection, PlotSolution
%
% @author Allany Victória Santos Araújo
% @date 2025

clc;        % Limpa o console
clear;      % Apaga todas as variáveis da memória
close all;  % Fecha todas as janelas de gráfico

% ---------------------------------------------------------
%% PASSO 1 - Definição do Problema
% ---------------------------------------------------------

% Cria o modelo para a função Picos com a grade 256x256
model = CreateModel();

% nVar = número de pontos na grade
nVar = model.n;


% ---------------------------------------------------------
%% PASSO 2 - Parâmetros do ACO
% ---------------------------------------------------------

MaxIt = 300;    % Número máximo de iterações
nAnt = 40;      % Número de formigas (tamanho da população)
Q = 1;          % Constante usada na deposição de feromônio
tau0 = 1;       % Valor inicial do feromônio em todos os pontos
alpha = 1;      % Peso do feromônio
beta  = 1;      % Peso da heurística
rho   = 0.05;   % Taxa de evaporação do feromônio (5% por iteração)
nSteps = 50;    % Número de passos que cada formiga dá por iteração

% ---------------------------------------------------------
%% PASSO 3 - Inicialização
% ---------------------------------------------------------

% Heurística invertida: desloca para positivo e inverte para atrair
% formigas para regiões de menor valor da função Picos
eta = 1 ./ (model.Cost - min(model.Cost) + 1);

% Vetor de feromônio: começa uniforme (tau0 em todos os pontos)
tau = tau0 * ones(nVar, 1);

% Vetor para guardar o melhor custo de cada iteração
BestCost = zeros(MaxIt, 1);

% Estrutura de uma formiga vazia
empty_ant.Caminho = [];
empty_ant.Cost = [];

% Cria vetor com nAnt formigas vazias
ant = repmat(empty_ant, nAnt, 1);

% Melhor solução global inicializada com +inf (busca mínimo)
BestSol.Cost = inf;


% ---------------------------------------------------------
%% PASSO 4 - Loop Principal do ACO
% ---------------------------------------------------------

for it = 1:MaxIt

    % --- 4.1: Mover cada formiga ---
    for k = 1:nAnt

        % Cada formiga começa em um ponto aleatório do grid
        ant(k).Caminho = randi([1 nVar]);
        ant(k).BestCost = model.Cost(ant(k).Caminho);

        % A formiga dá nSteps passos, movendo-se entre vizinhos
        for l = 1:nSteps

            i = ant(k).Caminho(end); % ponto atual

            % Obtém os índices dos 8 vizinhos do ponto atual
            vizinhos = obter_vizinhos(i, model);

            % Probabilidade de ir para cada vizinho (feromônio x heurística)
            P = tau(vizinhos).^alpha .* eta(vizinhos).^beta;

            % Normaliza as probabilidades
            P = P / sum(P);

            % Seleciona o próximo ponto pela roleta
            prox_local = RouletteWheelSelection(P);
            prox = vizinhos(prox_local); % índice global do vizinho escolhido

            % Adiciona o ponto ao caminho da formiga
            ant(k).Caminho = [ant(k).Caminho prox];

            % Atualiza o melhor ponto da formiga (busca mínimo)
            if model.Cost(prox) < ant(k).BestCost
              ant(k).BestCost = model.Cost(prox);
            endif
        end

        % O custo da formiga é o menor valor encontrado no caminho
        ant(k).Cost = ant(k).BestCost;

        % Atualiza a melhor solução global
        if ant(k).Cost < BestSol.Cost
            BestSol = ant(k);
        end

    end

    % --- 4.2: Deposição de feromônio ---
    % Cada formiga deposita feromônio nos pontos visitados,
    % proporcional à qualidade da solução encontrada
    for k = 1:nAnt
      caminho = ant(k).Caminho;
      for i = 1:length(caminho)
          idx = caminho(i);
          tau(idx) = tau(idx) + Q / ant(k).Cost;
      end
    end

    % --- 4.3: Evaporação do feromônio ---
    tau = (1 - rho) * tau;

    % Registra e exibe o melhor custo da iteração
    BestCost(it) = BestSol.Cost;
    disp(['Iteração ' num2str(it) ': Melhor Custo = ' num2str(BestCost(it))]);

    % Atualiza o gráfico com a melhor solução atual
    figure(1);
    PlotSolution(BestSol.Caminho, model);
    drawnow();

end


% ---------------------------------------------------------
%% PASSO 5 - Resultados Finais
% ---------------------------------------------------------

% Exibe as coordenadas do melhor ponto encontrado
disp(['Melhor ponto: x = ' num2str(model.x(BestSol.Caminho(end))) ...
      ', y = ' num2str(model.y(BestSol.Caminho(end)))]);

% Plota a curva de convergência
figure;
plot(BestCost, 'LineWidth', 2);
xlabel('Iteração');
ylabel('Melhor Valor f(x,y)');
title('Convergência do ACO - Busca do Mínimo');
grid on;
