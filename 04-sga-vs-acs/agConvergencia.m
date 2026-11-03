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

function ag_run()
    clc;
    clear;
    pkg load ga;

    % Variáveis globais para as funções objetivo rastrear o AG
    global best_so_far;
    global eval_count;
    global history_curve;

    % ============================================================
    %% PARÂMETROS DO PROBLEMA E DO AG
    % ============================================================
    nv = 2;
    lb = [-3, -3];
    ub = [ 3,  3];

    n_exec   = 100;
    n_gen    = 100;
    pop_size = 50;

    options = gaoptimset( ...
        'PopulationSize',    pop_size, ...
        'Generations',       n_gen, ...
        'CrossoverFraction', 0.8, ...
        'EliteCount',        2, ...
        'CrossoverFcn',      @crossoverscattered, ...
        'MutationFcn',       {@mutationuniform, 0.05}, ...
        'SelectionFcn',      @selectionstochunif, ...
        'CreationFcn',       @gacreationuniform ...
    );

    % ============================================================
    %% ESTRUTURAS DE RESULTADO
    % ============================================================
    resultados = zeros(n_exec, 7);
    convergencia_min = zeros(n_exec, n_gen);
    convergencia_max = zeros(n_exec, n_gen);

    % ============================================================
    %% LOOP DE 100 EXECUÇÕES INDEPENDENTES
    % ============================================================
    for i = 1:n_exec
        fprintf('Execução AG %d/%d...\n', i, n_exec);

        % --- 1. BUSCA DO MÍNIMO ---
        best_so_far   = inf;
        eval_count    = 0;
        history_curve = zeros(1, (n_gen + 2) * pop_size); % Aloca espaço com folga

        [x_min, fval_min] = ga(@fitness_min_tracker, nv, [], [], [], [], lb, ub, options);

        % Transforma as avaliações (evals) em gerações
        curva_gen = zeros(1, n_gen);
        for g = 1:n_gen
            eval_idx = g * pop_size;
            if eval_idx <= eval_count
                curva_gen(g) = history_curve(eval_idx);
            else
                curva_gen(g) = history_curve(eval_count); % Repete se convergiu antes
            end
        end
        convergencia_min(i, :) = curva_gen;

        % --- 2. BUSCA DO MÁXIMO ---
        best_so_far   = -inf;
        eval_count    = 0;
        history_curve = zeros(1, (n_gen + 2) * pop_size);

        [x_max, fval_max_neg] = ga(@fitness_max_tracker, nv, [], [], [], [], lb, ub, options);
        fval_max = -fval_max_neg; % Corrige o sinal final

        % Transforma as avaliações em gerações
        curva_gen = zeros(1, n_gen);
        for g = 1:n_gen
            eval_idx = g * pop_size;
            if eval_idx <= eval_count
                curva_gen(g) = history_curve(eval_idx);
            else
                curva_gen(g) = history_curve(eval_count);
            end
        end
        convergencia_max(i, :) = curva_gen;

        % Salva o resultado final na matriz
        resultados(i, :) = [i, x_min(1), x_min(2), fval_min, ...
                               x_max(1), x_max(2), fval_max];
    end

    % ============================================================
    %% SALVAR CSVs
    % ============================================================
    % Execuções Individuais
    fid = fopen('ag_min_execucoes.csv', 'w');
    fprintf(fid, 'execucao,x,y,fval_min\n');
    for i = 1:n_exec, fprintf(fid, '%d,%.6f,%.6f,%.6f\n', resultados(i,1), resultados(i,2), resultados(i,3), resultados(i,4)); end
    fclose(fid);

    fid = fopen('ag_max_execucoes.csv', 'w');
    fprintf(fid, 'execucao,x,y,fval_max\n');
    for i = 1:n_exec, fprintf(fid, '%d,%.6f,%.6f,%.6f\n', resultados(i,1), resultados(i,5), resultados(i,6), resultados(i,7)); end
    fclose(fid);

    % Convergência
    conv_min_media = mean(convergencia_min, 1); conv_min_std = std(convergencia_min, 0, 1);
    fid = fopen('ag_min_convergencia.csv', 'w');
    fprintf(fid, 'geracao,media_fval,desvio_padrao\n');
    for it = 1:n_gen, fprintf(fid, '%d,%.6f,%.6f\n', it, conv_min_media(it), conv_min_std(it)); end
    fclose(fid);

    conv_max_media = mean(convergencia_max, 1); conv_max_std = std(convergencia_max, 0, 1);
    fid = fopen('ag_max_convergencia.csv', 'w');
    fprintf(fid, 'geracao,media_fval,desvio_padrao\n');
    for it = 1:n_gen, fprintf(fid, '%d,%.6f,%.6f\n', it, conv_max_media(it), conv_max_std(it)); end
    fclose(fid);

    % Médias
    med_fmin = mean(resultados(:,4)); std_fmin = std(resultados(:,4));
    fid = fopen('ag_min_medias.csv', 'w');
    fprintf(fid, 'metrica,x,y,fval_min\n');
    fprintf(fid, 'media,%.6f,%.6f,%.6f\n', mean(resultados(:,2)), mean(resultados(:,3)), med_fmin);
    fprintf(fid, 'desvio_padrao,%.6f,%.6f,%.6f\n', std(resultados(:,2)), std(resultados(:,3)), std_fmin);
    fprintf(fid, 'melhor,,,%.6f\n', min(resultados(:,4)));
    fprintf(fid, 'pior,,,%.6f\n', max(resultados(:,4)));
    fclose(fid);

    med_fmax = mean(resultados(:,7)); std_fmax = std(resultados(:,7));
    fid = fopen('ag_max_medias.csv', 'w');
    fprintf(fid, 'metrica,x,y,fval_max\n');
    fprintf(fid, 'media,%.6f,%.6f,%.6f\n', mean(resultados(:,5)), mean(resultados(:,6)), med_fmax);
    fprintf(fid, 'desvio_padrao,%.6f,%.6f,%.6f\n', std(resultados(:,5)), std(resultados(:,6)), std_fmax);
    fprintf(fid, 'melhor,,,%.6f\n', max(resultados(:,7)));
    fprintf(fid, 'pior,,,%.6f\n', min(resultados(:,7)));
    fclose(fid);

    fprintf('\n========== RESUMO AG ==========\n');
    fprintf('Execuções concluídas. Curvas de convergência salvas!\n');

end

% ============================================================
%% FUNÇÕES OBJETIVO
% ============================================================

function val = fitness_min_tracker(x)
    global best_so_far eval_count history_curve
    val = 3*(1-x(1))^2*exp(-(x(1)^2) - (x(2)+1)^2) ...
        - 10*(x(1)/5 - x(1)^3 - x(2)^5)*exp(-x(1)^2 - x(2)^2) ...
        - 1/3*exp(-(x(1)+1)^2 - x(2)^2);

    if val < best_so_far
        best_so_far = val;
    end

    eval_count = eval_count + 1;
    history_curve(eval_count) = best_so_far;
end

function val = fitness_max_tracker(x)
    global best_so_far eval_count history_curve
    f_val = 3*(1-x(1))^2*exp(-(x(1)^2) - (x(2)+1)^2) ...
        - 10*(x(1)/5 - x(1)^3 - x(2)^5)*exp(-x(1)^2 - x(2)^2) ...
        - 1/3*exp(-(x(1)+1)^2 - x(2)^2);

    val = -f_val;

    if f_val > best_so_far
        best_so_far = f_val;
    end

    eval_count = eval_count + 1;
    history_curve(eval_count) = best_so_far;
end
