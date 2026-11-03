%% @file acoMax.m
% @brief ACO para busca do MÁXIMO da função Picos — 100 execuções independentes.
% Versão Otimizada (Memória Pré-alocada e Grade Estática)

clc;
clear;
close all;

% ============================================================
%% PARÂMETROS DO ACO
% ============================================================
MaxIt  = 100;
nAnt   = 50;
Q      = 1;
tau0   = 1;
alpha  = 1;
beta   = 1;
rho    = 0.05;
nSteps = 50;

n_exec = 100;

% ============================================================
%% INICIALIZAÇÃO ESTÁTICA (RODA APENAS 1 VEZ)
% ============================================================
fprintf('Criando modelo e pré-calculando vizinhos (Aguarde...)...\n');
model = CreateModel();
nVar  = model.n;

% Heurística: desloca para positivo e atrai formigas para MAIOR valor
eta = model.Cost - min(model.Cost) + 1;

% Pré-cálculo de vizinhança na memória
model.Vizinhos = cell(nVar, 1);
for i = 1:nVar
    model.Vizinhos{i} = obter_vizinhos(i, model);
end
fprintf('Grade pronta! Iniciando as %d execuções...\n\n', n_exec);

% ============================================================
%% ESTRUTURAS DE RESULTADO
% ============================================================
resultados = zeros(n_exec, 4);
convergencia = zeros(n_exec, MaxIt);

% ============================================================
%% LOOP DE EXECUÇÕES INDEPENDENTES
% ============================================================
for exec = 1:n_exec
    fprintf('Execução %d/%d...\n', exec, n_exec);

    % RESET DO AMBIENTE PARA A NOVA EXECUÇÃO
    tau = tau0 * ones(nVar, 1);
    BestSol.Cost = -inf;
    BestSol.x    = NaN;
    BestSol.y    = NaN;

    empty_ant.Caminho  = [];
    empty_ant.Cost     = [];
    empty_ant.BestCost = [];
    ant = repmat(empty_ant, nAnt, 1);

    % Loop principal
    for it = 1:MaxIt

        % --- Mover cada formiga ---
        for k = 1:nAnt
            % PRÉ-ALOCAÇÃO DO VETOR DE CAMINHO
            ant(k).Caminho = zeros(1, nSteps + 1);

            % Início aleatório
            ant(k).Caminho(1)  = randi([1 nVar]);
            ant(k).BestCost = model.Cost(ant(k).Caminho(1));

            for l = 1:nSteps
                i        = ant(k).Caminho(l);
                vizinhos = model.Vizinhos{i}; % CONSULTA DIRETA NA MEMÓRIA

                P        = tau(vizinhos).^alpha .* eta(vizinhos).^beta;
                P        = P / sum(P);
                prox_local = RouletteWheelSelection(P);
                prox       = vizinhos(prox_local);

                % SALVA POR ÍNDICE
                ant(k).Caminho(l + 1) = prox;

                if model.Cost(prox) > ant(k).BestCost
                    ant(k).BestCost = model.Cost(prox);
                end
            end

            ant(k).Cost = ant(k).BestCost;

            if ant(k).Cost > BestSol.Cost
                BestSol.Cost = ant(k).Cost;
                idx          = ant(k).Caminho(end);
                BestSol.x    = model.x(idx);
                BestSol.y    = model.y(idx);
            end
        end

        % --- Deposição de feromônio ---
        for k = 1:nAnt
            caminho   = ant(k).Caminho;
            custo_dep = ant(k).Cost - min(model.Cost) + 1e-10;
            for s = 1:length(caminho)
                tau(caminho(s)) = tau(caminho(s)) + Q / custo_dep;
            end
        end

        % --- Evaporação ---
        tau = (1 - rho) * tau;

        % Registra convergência desta iteração
        convergencia(exec, it) = BestSol.Cost;

    end % fim iterações

    % Salva resultado desta execução
    resultados(exec, :) = [exec, BestSol.x, BestSol.y, BestSol.Cost];

end % fim execuções

fprintf('Execuções concluídas.\n');

% ============================================================
%% SALVAMENTO DE ARQUIVOS (MANTIDO)
% ============================================================
fid = fopen('aco_max_execucoes.csv', 'w');
fprintf(fid, 'execucao,x,y,fval_max\n');
for i = 1:n_exec
    fprintf(fid, '%d,%.6f,%.6f,%.6f\n', ...
        resultados(i,1), resultados(i,2), resultados(i,3), resultados(i,4));
end
fclose(fid);

med_x   = mean(resultados(:,2)); med_y   = mean(resultados(:,3)); med_f   = mean(resultados(:,4));
std_x   = std(resultados(:,2));  std_y   = std(resultados(:,3));  std_f   = std(resultados(:,4));
best_f  = max(resultados(:,4));  worst_f = min(resultados(:,4));

fid = fopen('aco_max_medias.csv', 'w');
fprintf(fid, 'metrica,x,y,fval_max\n');
fprintf(fid, 'media,%.6f,%.6f,%.6f\n',        med_x,   med_y,   med_f);
fprintf(fid, 'desvio_padrao,%.6f,%.6f,%.6f\n', std_x,   std_y,   std_f);
fprintf(fid, 'melhor,,,%.6f\n',                 best_f);
fprintf(fid, 'pior,,,%.6f\n',                   worst_f);
fclose(fid);

conv_media = mean(convergencia, 1); conv_std   = std(convergencia, 0, 1);
fid = fopen('aco_max_convergencia.csv', 'w');
fprintf(fid, 'iteracao,media_fval,desvio_padrao\n');
for it = 1:MaxIt
    fprintf(fid, '%d,%.6f,%.6f\n', it, conv_media(it), conv_std(it));
end
fclose(fid);

[~, idx_best] = max(resultados(:,4));
fprintf('\n========== RESUMO ACO — MÁXIMO ==========\n');
fprintf('Melhor fval : %.4f  em  x=%.4f, y=%.4f\n', resultados(idx_best,4), resultados(idx_best,2), resultados(idx_best,3));
fprintf('Média fval  : %.4f  ±  %.4f\n', med_f, std_f);
fprintf('Pior  fval  : %.4f\n', worst_f);
