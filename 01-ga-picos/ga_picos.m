% ============================================================
% Algoritmo Genético - Função Picos (Peaks)
% IC - 2025 | Prof. Dr. Delmar Broglio Carvalho
%             Acad. Allany Victória Santos Araújo
% ============================================================

clc;      % limpa a tela
clear;    % limpa variáveis antigas
pkg load ga;

% Definição da função objetivo
fitness = @(x) 3*(1-x(1)).^2.*exp(-(x(1).^2) - (x(2)+1).^2) ...
    - 10*(x(1)/5 - x(1).^3 - x(2).^5).*exp(-x(1).^2 - x(2).^2) ...
    - 1/3*exp(-(x(1)+1).^2 - x(2).^2);

% Parâmetros do Problema
nv = 2;           % Número de variáveis de decisão (x e y)
lb = [-3, -3];    % Limites inferiores de busca
ub = [ 3,  3];    % Limites superiores de busca

% Parâmetros do Algoritmo Genético

options = gaoptimset( ...
    'PopulationSize',  50, ...
    'Generations',    100, ...
    'CrossoverFraction', 0.8, ...
    'EliteCount',       2, ...
    'CrossoverFcn',  @crossoverscattered, ...
    'MutationFcn',   {@mutationuniform, 0.05}, ...
    'SelectionFcn',  @selectionstochunif, ...
    'CreationFcn',   @gacreationuniform ...
);

% 100 Execuções independentes
n_exec = 100;
fitness_max = @(x) -fitness(x);

% Matrizes de resultados
resultados = zeros(n_exec, 7);
% Colunas: exec | x_min | y_min | fval_min | x_max | y_max | fval_max

for i = 1:n_exec
    fprintf('Execução %d/100...\n', i);

    [x_min, fval_min] = ga(fitness,     nv, [], [], [], [], lb, ub, options);
    [x_max, fval_max_neg] = ga(fitness_max, nv, [], [], [], [], lb, ub, options);
    fval_max = -fval_max_neg;

    resultados(i, :) = [i, x_min(1), x_min(2), fval_min, x_max(1), x_max(2), fval_max];
end

% Salvar CSV com todas as execuções
fid = fopen('resultados_execucoes.csv', 'w');
fprintf(fid, 'execucao,x_min,y_min,fval_min,x_max,y_max,fval_max\n');
for i = 1:n_exec
    fprintf(fid, '%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
        resultados(i,1), resultados(i,2), resultados(i,3), resultados(i,4), ...
        resultados(i,5), resultados(i,6), resultados(i,7));
end
fclose(fid);
fprintf('Arquivo salvo: resultados_execucoes.csv\n');

% Salvar CSV com médias e estatísticas
med_x_min  = mean(resultados(:,2));
med_y_min  = mean(resultados(:,3));
med_fmin   = mean(resultados(:,4));
std_x_min  = std(resultados(:,2));
std_y_min  = std(resultados(:,3));
std_fmin   = std(resultados(:,4));
best_fmin  = min(resultados(:,4));
worst_fmin = max(resultados(:,4));

med_x_max  = mean(resultados(:,5));
med_y_max  = mean(resultados(:,6));
med_fmax   = mean(resultados(:,7));
std_x_max  = std(resultados(:,5));
std_y_max  = std(resultados(:,6));
std_fmax   = std(resultados(:,7));
best_fmax  = max(resultados(:,7));
worst_fmax = min(resultados(:,7));

fid = fopen('resultados_medias.csv', 'w');
fprintf(fid, 'metrica,x_min,y_min,fval_min,x_max,y_max,fval_max\n');
fprintf(fid, 'media,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
    med_x_min, med_y_min, med_fmin, med_x_max, med_y_max, med_fmax);
fprintf(fid, 'desvio_padrao,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n', ...
    std_x_min, std_y_min, std_fmin, std_x_max, std_y_max, std_fmax);
fprintf(fid, 'melhor,,,%.6f,,,%.6f\n', best_fmin, best_fmax);
fprintf(fid, 'pior,,,%.6f,,,%.6f\n',  worst_fmin, worst_fmax);
fclose(fid);
fprintf('Arquivo salvo: resultados_medias.csv\n');

% Resumo no terminal
fprintf('\n========== RESUMO ==========\n');
fprintf('Mínimo global: fval = %.4f  em  x=%.4f, y=%.4f\n', best_fmin, ...
    resultados(resultados(:,4)==best_fmin, 2)(1), ...
    resultados(resultados(:,4)==best_fmin, 3)(1));
fprintf('Máximo global: fval = %.4f  em  x=%.4f, y=%.4f\n', best_fmax, ...
    resultados(resultados(:,7)==best_fmax, 5)(1), ...
    resultados(resultados(:,7)==best_fmax, 6)(1));
