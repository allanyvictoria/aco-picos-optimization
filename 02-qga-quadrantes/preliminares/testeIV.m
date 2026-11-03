% Teste focado no Quadrante IV
% Usando um "wrapper" de penalidade para FORÇAR
% o confinamento no quadrante.

clc;
clear all;
pkg load ga;

% Função Objetivo "Invólucro" (Wrapper) 
function f = fitness_confinado_q4(x)
    % Limites do Quadrante IV
    lb_q4 = [0, -3];
    ub_q4 = [3, 0];

    % Verifica se o indivíduo 'x' está DENTRO dos limites
    if (x(1) >= lb_q4(1) && x(1) <= ub_q4(1) && ...
        x(2) >= lb_q4(2) && x(2) <= ub_q4(2))

        % Se ESTÁ DENTRO, calcula a aptidão real (para MAXIMIZAR)
        % (Note: a função 'ga' minimiza, então retornamos o negativo)
        f = - ( 3*(1-x(1)).^2.*exp(-(x(1).^2) - (x(2)+1).^2) ...
              - 10*(x(1)/5 - x(1).^3 - x(2).^5).*exp(-x(1).^2 - x(2).^2) ...
              - 1/3*exp(-(x(1)+1).^2 - x(2).^2) );
    else
        % Se ESTÁ FORA, retorna uma penalidade GIGANTE.
        % Como o GA está minimizando, ele fugirá desse valor.
        f = 1e10;
    endif
endfunction

% PARÂMETROS DO CENÁRIO A (Pop 10, Gen 25)
nv = 2;
pop_size = 10;
gen_count = 25;
num_execucoes = 10; % Teste rápido com 10 execuções

% Limites TOTAIS - Damos ao GA o espaço todo para ele "bater na parede"
lb_total = [-3, -3];
ub_total = [3, 3];

% Opções do GA 
options = gaoptimset( ...
    'PopulationSize', pop_size, ...
    'Generations', gen_count, ...
    'CrossoverFraction', 0.8, ...
    'EliteCount', 2, ...
    'CrossoverFcn', @crossoverscattered, ...
    'MutationFcn', {@mutationuniform, 0.05}, ...
    'SelectionFcn', @selectionstochunif ...
    % Não precisamos mais da CreationFcn customizada, pois a
    % penalidade vai matar qualquer indivíduo criado fora.
);

% Loop de Teste (Focado no Q4)
printf("Iniciando teste focado no Quadrante IV (Método de Penalidade)...\n");

vec_melhor_aptidao = zeros(num_execucoes, 1);
vec_var_apt_norm = zeros(num_execucoes, 1);

for exec = 1:num_execucoes

    [x_opt, fval_opt, exitflag, output, population, scores] = ...
        ga(@fitness_confinado_q4, nv, [], [], [], [], lb_total, ub_total, options);

    % scores da população final (são os valores minimizados)
    % Convertemos de volta para a aptidão real (positiva)
    aptidoes = -scores;

    % Ignora os indivíduos penalizados (com -1e10)
    aptidoes_validas = aptidoes(aptidoes > -1e9);

    if isempty(aptidoes_validas)
        apt_max = -Inf; % Todos foram penalizados
        apt_normalizada = [0];
    else
        apt_max = max(aptidoes_validas);
        if apt_max <= 1e-6
           apt_normalizada = zeros(size(aptidoes_validas));
        else
           apt_normalizada = aptidoes_validas / apt_max;
        endif
    endif

    vec_var_apt_norm(exec) = var(apt_normalizada);
    vec_melhor_aptidao(exec) = apt_max;

    printf("Exec %d: Melhor Aptidão = %.4f, VarNorm = %.4f\n", exec, apt_max, var(apt_normalizada));
endfor

% Resultados Finais do Teste

printf("\n--- Resultados Finais (Quadrante IV - Confinado) ---\n");
printf("Cenário | Pop | Gen | Média (Melhor Aptidão) | Média (Var Apt Norm)\n");
printf("-------------------------------------------------------------------\n");
printf("   A    | %3d | %3d | %22.4f | %22.4f\n", ...
       pop_size, gen_count, ...
       mean(vec_melhor_aptidao), mean(vec_var_apt_norm));
