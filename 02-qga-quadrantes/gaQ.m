clc;
clear all;
pkg load ga;

% Cria a população DENTRO dos limites do quadrante.
function pop = criar_populacao_confinada(nvars, fitnessfcn, options, lb_quad, ub_quad)
    pop_size_local = options.PopulationSize;
    pop = zeros(pop_size_local, nvars);

    min_x = lb_quad(1); max_x = ub_quad(1);
    min_y = lb_quad(2); max_y = ub_quad(2);

    for i = 1:pop_size_local
        pop(i, 1) = min_x + (max_x - min_x) * rand(); % X confinado
        pop(i, 2) = min_y + (max_y - min_y) * rand(); % Y confinado
    endfor
endfunction

% Verifica se o GA (mutação/crossover) tentou escapar.
function f = fitness_confinado(x, lb_quad, ub_quad)

    if (x(1) >= lb_quad(1) && x(1) <= ub_quad(1) && ...
        x(2) >= lb_quad(2) && x(2) <= ub_quad(2))

        % DENTRO: Retorna a aptidão real (negativa, pois o GA minimiza)
        f = - ( 3*(1-x(1)).^2.*exp(-(x(1).^2) - (x(2)+1).^2) ...
              - 10*(x(1)/5 - x(1).^3 - x(2).^5).*exp(-x(1).^2 - x(2).^2) ...
              - 1/3*exp(-(x(1)+1).^2 - x(2).^2) );
    else
        % FORA: Retorna a penalidade
        f = 1e10;
    endif
endfunction

% Parâmetros do Experimento
nv = 2;
num_execucoes = 100; %
pop_sizes = [10, 20]; %
gen_counts = [25, 50]; %

% Limites TOTAIS 
lb_total = [-3, -3];
ub_total = [3, 3];

% Definição dos 4 Quadrantes 
quadrantes = {};
quadrantes{1}.nome = "I (Sup-Esq)";
quadrantes{1}.lb = [-3, 0];
quadrantes{1}.ub = [0, 3];

quadrantes{2}.nome = "II (Sup-Dir)";
quadrantes{2}.lb = [0, 0];
quadrantes{2}.ub = [3, 3];

quadrantes{3}.nome = "III (Inf-Esq)";
quadrantes{3}.lb = [-3, -3];
quadrantes{3}.ub = [0, 0];

quadrantes{4}.nome = "IV (Inf-Dir)";
quadrantes{4}.lb = [0, -3];
quadrantes{4}.ub = [3, 0];

% Estrutura para armazenar TODOS os resultados
resultados = cell(length(quadrantes), length(pop_sizes), length(gen_counts));

% Execução dos Testes (Loops)
printf("Iniciando simulação completa com Z-SCORE (%d execuções no total)...\n", ...
       length(quadrantes) * length(pop_sizes) * length(gen_counts) * num_execucoes);

% Loop 1: Quadrantes
for q_idx = 1:length(quadrantes)
    current_lb = quadrantes{q_idx}.lb;
    current_ub = quadrantes{q_idx}.ub;

    % CRIA AS FUNÇÕES DE FITNESS E CRIAÇÃO PARA ESTE QUADRANTE
    fitness_para_ga = @(x) fitness_confinado(x, current_lb, current_ub);
    creation_para_ga = @(nvars, fitnessfcn, options) criar_populacao_confinada(nvars, fitnessfcn, options, current_lb, current_ub);

    % Loop 2: Tamanhos de População
    for p_idx = 1:length(pop_sizes)
        current_pop = pop_sizes(p_idx);

        % Loop 3: Número de Gerações
        for g_idx = 1:length(gen_counts)
            current_gen = gen_counts(g_idx);

            printf("Rodando: Q=%s, Pop=%d, Gen=%d (%d execuções)...\n", ...
                   quadrantes{q_idx}.nome, current_pop, current_gen, num_execucoes);

            % Define as 'options'
            options = gaoptimset( ...
                'PopulationSize', current_pop, ...
                'Generations', current_gen, ...
                'CrossoverFraction', 0.8, ...
                'EliteCount', 2, ...
                'CrossoverFcn', @crossoverscattered, ...
                'MutationFcn', {@mutationuniform, 0.05}, ...
                'SelectionFcn', @selectionstochunif, ...
                'CreationFcn', creation_para_ga ... % <-- NOSSA "FÁBRICA"
            );

            % Vetores para armazenar as métricas das 100 execuções
            % (Mantendo os originais e adicionando Z-Score)
            vec_var_apt_norm = zeros(num_execucoes, 1);
            vec_var_apt_media_norm = zeros(num_execucoes, 1);
            vec_melhor_aptidao = zeros(num_execucoes, 1);
            vec_aptidao_media = zeros(num_execucoes, 1);

            % --- NOVO: Vetor para o Z-Score do melhor indivíduo ---
            vec_max_z_score = zeros(num_execucoes, 1);

            % Loop 4: 100 Execuções
            for exec = 1:num_execucoes

                % Chama o GA com a função "GUARDA" e os limites TOTAIS
                [~, ~, ~, ~, ~, final_scores] = ...
                    ga(fitness_para_ga, nv, [], [], [], [], lb_total, ub_total, options);

                aptidoes = -final_scores; % Inverte para ficar positivo (Maximização)
                aptidoes_validas = aptidoes(aptidoes > -1e9); % Ignora os penalizados

                % Inicializa variáveis seguras
                apt_max = 0;
                apt_media = 0;
                apt_std = 0;
                z_score_max = 0;
                apt_normalizada = [0];
                apt_media_normalizada = [0];

                if ~isempty(aptidoes_validas)
                    apt_max = max(aptidoes_validas);
                    apt_media = mean(aptidoes_validas);
                    apt_std = std(aptidoes_validas); % Desvio Padrão da população final

                    % --- CÁLCULO DO Z-SCORE ---
                    % Fórmula: (X - Média) / DesvioPadrão
                    % Calculamos para o MELHOR indivíduo (apt_max)
                    if apt_std > 1e-9
                        z_score_max = (apt_max - apt_media) / apt_std;
                    else
                        z_score_max = 0; % População convergiu, todos iguais
                    endif

                    % --- CÁLCULO DAS OUTRAS MÉTRICAS (MANTIDO DA V4) ---
                    if apt_max > 1e-6
                       apt_normalizada = aptidoes_validas / apt_max;
                    else
                       apt_normalizada = zeros(size(aptidoes_validas));
                    endif

                    if abs(apt_media) > 1e-6
                       apt_media_normalizada = aptidoes_validas / apt_media;
                    else
                       apt_media_normalizada = zeros(size(aptidoes_validas));
                    endif
                endif

                % Armazena nos vetores
                vec_var_apt_norm(exec) = var(apt_normalizada);
                vec_var_apt_media_norm(exec) = var(apt_media_normalizada);
                vec_melhor_aptidao(exec) = apt_max;
                vec_aptidao_media(exec) = apt_media;
                vec_max_z_score(exec) = z_score_max; % <--- Salva Z-Score

            endfor % Fim das 100 execuções

            % Armazena os vetores na estrutura de resultados
            resultados{q_idx, p_idx, g_idx}.quadrante = quadrantes{q_idx}.nome;
            resultados{q_idx, p_idx, g_idx}.pop_size = current_pop;
            resultados{q_idx, p_idx, g_idx}.gen_count = current_gen;
            resultados{q_idx, p_idx, g_idx}.var_apt_norm = vec_var_apt_norm;
            resultados{q_idx, p_idx, g_idx}.var_apt_media_norm = vec_var_apt_media_norm;
            resultados{q_idx, p_idx, g_idx}.melhor_aptidao = vec_melhor_aptidao;
            resultados{q_idx, p_idx, g_idx}.aptidao_media = vec_aptidao_media;
            resultados{q_idx, p_idx, g_idx}.max_z_score = vec_max_z_score; % <--- Salva na estrutura

        endfor % Fim do loop de Gerações
    endfor % Fim do loop de População
endfor % Fim do loop de Quadrantes

printf("\n--- Simulação Concluída! ---\n");

%  Resultados no Terminal
cenarios_label = {"A", "B", "C", "D"};
idx = 1;

for q = 1:length(quadrantes)
    q_nome = quadrantes{q}.nome;
    printf("\n--- Resultados (%s) ---\n", q_nome);
    % Atualizei o cabeçalho para incluir o Z-Score
    printf("Cenário | Pop | Gen | Media(MelhorApt) | Media(VarNorm) | Media(Z-Score)\n");
    printf("------------------------------------------------------------------------\n");

    idx = 1; % Reseta o contador de cenário (A, B, C, D)
    for p = 1:length(pop_sizes)
        for g = 1:length(gen_counts)
            dados = resultados{q, p, g};
            printf("   %s    | %3d | %3d | %16.4f | %14.4f | %14.4f\n", ...
                   cenarios_label{idx}, ...
                   dados.pop_size, dados.gen_count, ...
                   mean(dados.melhor_aptidao), ...
                   mean(dados.var_apt_norm), ...
                   mean(dados.max_z_score)); % Mostra Z-Score
            idx = idx + 1;
        end
    end
end

%  Salvamento em CSV (RESUMO / MÉDIAS)
printf("\nSalvando resultados de RESUMO (médias) em arquivos CSV...\n");

for q = 1:length(quadrantes)
    q_nome = quadrantes{q}.nome;
    q_nome_arquivo = strrep(strrep(strrep(q_nome, " ", "_"), "(", ""), ")", "");
    nome_base = sprintf("resultados_RESUMO_quadrante_%s.csv", q_nome_arquivo);

    fid = fopen(nome_base, "w");

    % Cabeçalho do CSV (Adicionadas colunas de Z-Score)
    fprintf(fid, "Quadrante,Pop,Gen,Media_MelhorApt,Desvio_MelhorApt,Media_AptMedia,Media_VarNorm,Desvio_VarNorm,Media_VarMediaNorm,Media_ZScoreMax,Desvio_ZScoreMax\n");

    for p = 1:length(pop_sizes)
        for g = 1:length(gen_counts)
            dados = resultados{q, p, g};

            % Calcula as estatísticas das 100 execuções
            media_melhor = mean(dados.melhor_aptidao);
            desvio_melhor = std(dados.melhor_aptidao);
            media_apt_media = mean(dados.aptidao_media);
            media_var = mean(dados.var_apt_norm);
            desvio_var = std(dados.var_apt_norm);
            media_var_med = mean(dados.var_apt_media_norm);

            % Estatísticas do Z-Score
            media_z = mean(dados.max_z_score);
            desvio_z = std(dados.max_z_score);

            % Linha do CSV
            fprintf(fid, "%s,%d,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n", ...
                    q_nome, dados.pop_size, dados.gen_count, ...
                    media_melhor, desvio_melhor, media_apt_media, ...
                    media_var, desvio_var, media_var_med, ...
                    media_z, desvio_z);
        endfor
    endfor

    fclose(fid);
    printf("Arquivo de resumo salvo: %s\n", nome_base);
endfor

printf("\n--- Todos os resumos foram exportados para CSV! ---\n");

% Salvamento em CSV (DADOS BRUTOS, 100 execuções)
printf("\nSalvando dados BRUTOS (100 execuções) em arquivos CSV...\n");

for q = 1:length(quadrantes)
    q_nome = quadrantes{q}.nome;
    q_nome_arquivo = strrep(strrep(strrep(q_nome, " ", "_"), "(", ""), ")", "");
    nome_base_bruto = sprintf("resultados_BRUTOS_quadrante_%s.csv", q_nome_arquivo);

    fid_bruto = fopen(nome_base_bruto, "w");

    % Pegar os dados dos 4 cenários para este quadrante
    dados_A = resultados{q, 1, 1}; % Pop10, Gen25
    dados_B = resultados{q, 1, 2}; % Pop10, Gen50
    dados_C = resultados{q, 2, 1}; % Pop20, Gen25
    dados_D = resultados{q, 2, 2}; % Pop20, Gen50

    % Cabeçalho do CSV (Expandido com Z-Score para A, B, C, D)
    % Mantive VarNorm e adicionei ZScore
    fprintf(fid_bruto, "Exec,MelhorApt_A,MelhorApt_B,MelhorApt_C,MelhorApt_D,VarNorm_A,VarNorm_B,VarNorm_C,VarNorm_D,ZScore_A,ZScore_B,ZScore_C,ZScore_D\n");

    % Loop das 100 execuções
    for i = 1:num_execucoes
        fprintf(fid_bruto, "%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n", ...
                i, ...
                dados_A.melhor_aptidao(i), dados_B.melhor_aptidao(i), dados_C.melhor_aptidao(i), dados_D.melhor_aptidao(i), ...
                dados_A.var_apt_norm(i),   dados_B.var_apt_norm(i),   dados_C.var_apt_norm(i),   dados_D.var_apt_norm(i), ...
                dados_A.max_z_score(i),    dados_B.max_z_score(i),    dados_C.max_z_score(i),    dados_D.max_z_score(i) ...
        );
    endfor

    fclose(fid_bruto);
    printf("Arquivo de dados brutos salvo: %s\n", nome_base_bruto);
endfor

printf("\n--- Todos os dados brutos foram exportados para CSV! ---\n");
