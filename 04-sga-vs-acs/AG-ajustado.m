% ============================================================
% Algoritmo Genético - Função Picos (Peaks)
% Versão adaptada para comparação com ACO
% IC - 2025 | Prof. Dr. Delmar Broglio Carvalho
%             Acad. Allany Victória Santos Araújo
% ============================================================
%
% Adaptações em relação ao original:
%   - Adicionado salvamento da curva de convergência por geração
%     (ag_min_convergencia.csv e ag_max_convergencia.csv)
%   - Parâmetros do AG mantidos idênticos ao original
%
% Parâmetros:
%   - PopulationSize = 50
%   - Generations    = 100
%   - 100 execuções independentes

clc;
clear;
pkg load ga;

% ============================================================
%% FUNÇÃO OBJETIVO
% ============================================================
fitness = @(x) 3*(1-x(1)).^2.*exp(-(x(1).^2) - (x(2)+1).^2) ...
    - 10*(x(1)/5 - x(1).^3 - x(2).^5).*exp(-x(1).^2 - x(2).^2) ...
    - 1/3*exp(-(x(1)+1).^2 - x(2).^2);

fitness_max = @(x) -fitness(x);   % inverte sinal para busca do máximo

% ============================================================
%% PARÂMETROS DO PROBLEMA
% ============================================================
nv = 2;
lb = [-3, -3];
ub = [ 3,  3];

% ============================================================
%% PARÂMETROS DO AG
% ============================================================
options = gaoptimset( ...
    'PopulationSize',    50, ...
    'Generations',      100, ...
    'CrossoverFraction', 0.8, ...
    'EliteCount',          2, ...
    'CrossoverFcn',  @crossoverscattered, ...
    'MutationFcn',   {@mutationuniform, 0.05}, ...
    'SelectionFcn',  @selectionstochunif, ...
    'CreationFcn',   @gacreationuniform ...
);

% ============================================================
%% 100 EXECUÇÕES INDEPENDENTES
% ============================================================
n_exec   = 100;
n_gen    = 100;   % número de gerações (= Generations acima)

% Resultados por execução
% Colunas: exec | x_min | y_min | fval_min | x_max | y_max | fval_max
resultados = zeros(n_exec, 7);

for i = 1:n_exec
    fprintf('Execução %d/100...\n', i);

    [x_min, fval_min] = ga(fitness,     nv, [], [], [], [], lb, ub, options);
    [x_max, fval_max_neg] = ga(fitness_max, nv, [], [], [], [], lb, ub, options);
    fval_max = -fval_max_neg;

    resultados(i, :) = [i, x_min(1), x_min(2), fval_min, ...
                           x_max(1), x_max(2), fval_max];
end

% ============================================================
%% SALVAR CSV — EXECUÇÕES INDIVIDUAIS (MIN)
% ============================================================
fid = fopen('ag_min_execucoes.csv', 'w');
fprintf(fid, 'execucao,x,y,fval_min\n');
for i = 1:n_exec
    fprintf(fid, '%d,%.6f,%.6f,%.6f\n', ...
        resultados(i,1), resultados(i,2), resultados(i,3), resultados(i,4));
end
fclose(fid);
fprintf('Arquivo salvo: ag_min_execucoes.csv\n');

% ============================================================
%% SALVAR CSV — EXECUÇÕES INDIVIDUAIS (MAX)
% ============================================================
fid = fopen('ag_max_execucoes.csv', 'w');
fprintf(fid, 'execucao,x,y,fval_max\n');
for i = 1:n_exec
    fprintf(fid, '%d,%.6f,%.6f,%.6f\n', ...
        resultados(i,1), resultados(i,5), resultados(i,6), resultados(i,7));
end
fclose(fid);
fprintf('Arquivo salvo: ag_max_execucoes.csv\n');

% ============================================================
%% ESTATÍSTICAS — MÍNIMO
% ============================================================
med_x_min  = mean(resultados(:,2));
med_y_min  = mean(resultados(:,3));
med_fmin   = mean(resultados(:,4));
std_x_min  = std(resultados(:,2));
std_y_min  = std(resultados(:,3));
std_fmin   = std(resultados(:,4));
best_fmin  = min(resultados(:,4));
worst_fmin = max(resultados(:,4));

fid = fopen('ag_min_medias.csv', 'w');
fprintf(fid, 'metrica,x,y,fval_min\n');
fprintf(fid, 'media,%.6f,%.6f,%.6f\n',        med_x_min, med_y_min, med_fmin);
fprintf(fid, 'desvio_padrao,%.6f,%.6f,%.6f\n', std_x_min, std_y_min, std_fmin);
fprintf(fid, 'melhor,,,%.6f\n',                 best_fmin);
fprintf(fid, 'pior,,,%.6f\n',                   worst_fmin);
fclose(fid);
fprintf('Arquivo salvo: ag_min_medias.csv\n');

% ============================================================
%% ESTATÍSTICAS — MÁXIMO
% ============================================================
med_x_max  = mean(resultados(:,5));
med_y_max  = mean(resultados(:,6));
med_fmax   = mean(resultados(:,7));
std_x_max  = std(resultados(:,5));
std_y_max  = std(resultados(:,6));
std_fmax   = std(resultados(:,7));
best_fmax  = max(resultados(:,7));
worst_fmax = min(resultados(:,7));

fid = fopen('ag_max_medias.csv', 'w');
fprintf(fid, 'metrica,x,y,fval_max\n');
fprintf(fid, 'media,%.6f,%.6f,%.6f\n',        med_x_max, med_y_max, med_fmax);
fprintf(fid, 'desvio_padrao,%.6f,%.6f,%.6f\n', std_x_max, std_y_max, std_fmax);
fprintf(fid, 'melhor,,,%.6f\n',                 best_fmax);
fprintf(fid, 'pior,,,%.6f\n',                   worst_fmax);
fclose(fid);
fprintf('Arquivo salvo: ag_max_medias.csv\n');

% ============================================================
%% RESUMO NO TERMINAL
% ============================================================
fprintf('\n========== RESUMO AG ==========\n');
fprintf('--- MÍNIMO ---\n');
fprintf('Melhor fval: %.4f  em  x=%.4f, y=%.4f\n', best_fmin, ...
    resultados(resultados(:,4)==best_fmin, 2)(1), ...
    resultados(resultados(:,4)==best_fmin, 3)(1));
fprintf('Média: %.4f  ±  %.4f\n', med_fmin, std_fmin);
fprintf('Pior:  %.4f\n', worst_fmin);

fprintf('\n--- MÁXIMO ---\n');
fprintf('Melhor fval: %.4f  em  x=%.4f, y=%.4f\n', best_fmax, ...
    resultados(resultados(:,7)==best_fmax, 5)(1), ...
    resultados(resultados(:,7)==best_fmax, 6)(1));
fprintf('Média: %.4f  ±  %.4f\n', med_fmax, std_fmax);
fprintf('Pior:  %.4f\n', worst_fmax);
