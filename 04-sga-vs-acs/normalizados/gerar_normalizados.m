% Script para Normalizar Média e Desvio Padrão (Min-Max)
clc; clear;

% Lê os arquivos originais (ignora a linha 1 do cabeçalho)
aco_min = dlmread('aco_min_convergencia.csv', ',', 1, 0);
ag_min  = dlmread('ag_min_convergencia.csv', ',', 1, 0);

aco_max = dlmread('aco_max_convergencia.csv', ',', 1, 0);
ag_max  = dlmread('ag_max_convergencia.csv', ',', 1, 0);

% Ótimos Globais teóricos (Alvos = 1.0)
OPT_MIN = -6.5511;
OPT_MAX = 8.1062;

% Define o Pior Caso = 0.0 (O pior chute de inicialização entre os dois)
pior_min = max(max(aco_min(:,2)), max(ag_min(:,2)));
pior_max = min(min(aco_max(:,2)), min(ag_max(:,2)));

% Aplica a fórmula Min-Max para a MÉDIA
aco_min_norm_media = (aco_min(:,2) - pior_min) ./ (OPT_MIN - pior_min);
ag_min_norm_media  = (ag_min(:,2)  - pior_min) ./ (OPT_MIN - pior_min);

aco_max_norm_media = (aco_max(:,2) - pior_max) ./ (OPT_MAX - pior_max);
ag_max_norm_media  = (ag_max(:,2)  - pior_max) ./ (OPT_MAX - pior_max);

% Aplica a escala no DESVIO PADRÃO (divide pelo valor absoluto do intervalo)
intervalo_min = abs(OPT_MIN - pior_min);
aco_min_norm_desvio = aco_min(:,3) ./ intervalo_min;
ag_min_norm_desvio  = ag_min(:,3)  ./ intervalo_min;

intervalo_max = abs(OPT_MAX - pior_max);
aco_max_norm_desvio = aco_max(:,3) ./ intervalo_max;
ag_max_norm_desvio  = ag_max(:,3)  ./ intervalo_max;

% Função para salvar o CSV com as 3 colunas completas
function write_norm_csv(filename, iter, norm_media, norm_desvio)
    fid = fopen(filename, 'w');
    fprintf(fid, 'iteracao,media_norm,desvio_norm\n');
    for i = 1:length(iter)
        fprintf(fid, '%d,%.6f,%.6f\n', iter(i), norm_media(i), norm_desvio(i));
    end
    fclose(fid);
end

% Gera os novos arquivos CSV
write_norm_csv('aco_min_norm.csv', aco_min(:,1), aco_min_norm_media, aco_min_norm_desvio);
write_norm_csv('ag_min_norm.csv',  ag_min(:,1),  ag_min_norm_media,  ag_min_norm_desvio);

write_norm_csv('aco_max_norm.csv', aco_max(:,1), aco_max_norm_media, aco_max_norm_desvio);
write_norm_csv('ag_max_norm.csv',  ag_max(:,1),  ag_max_norm_media,  ag_max_norm_desvio);

fprintf('Pronto! CSVs gerados com as 3 colunas (Iteração, Média e Desvio)!\n');
