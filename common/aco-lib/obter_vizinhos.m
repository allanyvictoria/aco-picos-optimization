%% @file obter_vizinhos.m
% @brief Retorna os índices lineares dos vizinhos adjacentes de um ponto no grid.
%
% @details
% Dado um ponto de índice linear i num grid de tamanho cols x cols,
% calcula as coordenadas 2D (linha, coluna) do ponto e verifica os
% 8 vizinhos ao redor (vizinhança de Moore). Pontos fora dos limites
% do grid são descartados, de modo que pontos de borda retornam
% menos de 8 vizinhos.
%
% O índice linear i segue a convenção do MATLAB/Octave:
%   i = (linha) * cols + coluna + 1  (base 1)
%
% @param i     Índice linear do ponto atual no grid (1 a model.n)
% @param model Struct do problema gerada por CreateModel(),
%              utiliza o campo model.cols para dimensão do grid
%
% @retval vizinhos Vetor linha com os índices lineares dos vizinhos válidos
%
% @author Allany Victória Santos Araújo
% @date 2025

function vizinhos = obter_vizinhos(i, model)

  linha = floor((i - 1) / model.cols); % linha no grid (base 0)
  col = mod(i - 1, model.cols);        % coluna no grid (base 0)

  vizinhos = zeros(1, 8); % pré-aloca espaço para no máximo 8 vizinhos
  count = 0;

  % Verifica os 8 vizinhos na vizinhança de Moore
  for dLinha = -1:1
    for dCol = -1:1
      if dLinha == 0 && dCol == 0
        continue; % ignora o próprio ponto
      endif

      % Calcular coordenadas do vizinho
      nova_linha = linha + dLinha;
      nova_coluna = col + dCol;

      % Verifica se o vizinho está dentro dos limites do grid
      if nova_linha >= 0 && nova_linha < model.cols && nova_coluna >= 0 && nova_coluna < model.cols

        % Converte as coordenadas 2D de volta para o índice linear
        vizinho_id = nova_linha * model.cols + nova_coluna + 1;
        count = count + 1;
        vizinhos(count) = vizinho_id; % armazena o vizinho

      endif
    endfor
  endfor

  % Ajusta o tamanho do vetor para o número real de vizinhos encontrados
  vizinhos = vizinhos(1:count);
end
