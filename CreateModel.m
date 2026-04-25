%% @file CreateModel.m
% @brief Cria o modelo do problema de otimização da função Picos.
%
% @details
% Gera uma grade discreta 256x256 no domínio [-3, 3] x [-3, 3],
% calcula o valor da função Picos em cada ponto da grade e
% empacota tudo numa struct 'model' utilizada pelo algoritmo ACO.
%
% A função Picos é definida por:
%   f(x,y) = 3*(1-x)^2 * exp(-x^2 - (y+1)^2)
%           - 10*(x/5 - x^3 - y^5) * exp(-x^2 - y^2)
%           - (1/3) * exp(-(x+1)^2 - y^2)
%
% @retval model Struct contendo os seguintes campos:
%   - model.n      : número total de pontos na grade (256^2 = 65536)
%   - model.cols   : número de colunas da grade (256)
%   - model.x      : vetor (n x 1) com coordenadas x de cada ponto
%   - model.y      : vetor (n x 1) com coordenadas y de cada ponto
%   - model.Cost   : vetor (n x 1) com o valor f(x,y) em cada ponto
%   - model.X_grid : matriz (256x256) de coordenadas x para plotagem
%   - model.Y_grid : matriz (256x256) de coordenadas y para plotagem
%   - model.Z_grid : matriz (256x256) de valores f(x,y) para plotagem
%   - model.tau    : vetor (1 x n) de feromônio inicial (todos iguais a 1)
%
% @author Allany Victória Santos Araújo
% @date 2025

function model = CreateModel()

  gridTamanho = 256;
  n = gridTamanho^2; % Número de pontos na grade (65.536)

  % Gerar as coordenadas x e y para todos os pontos da grade
  x = linspace(-3, 3, gridTamanho);
  y = linspace(-3, 3, gridTamanho);
  [x, y] = meshgrid(x, y);

  model.X_grid = x;  % matriz 256x256
  model.Y_grid = y;  % matriz 256x256

  % Transformar as coordenadas (x, y) em um vetor de índices
  model.x = x(:);
  model.y = y(:);

  % Função f(x, y) = peaks(x, y) calculada vetorialmente para todos os pontos
  model.Cost = 3*(1 - model.x).^2 .* exp(-(model.x.^2) - (model.y+1).^2) ...
             - 10*(model.x/5 - model.x.^3 - model.y.^5) .* exp(-model.x.^2 - model.y.^2) ...
             - (1/3)*exp(-(model.x+1).^2 - model.y.^2);

  model.Z_grid = reshape(model.Cost, gridTamanho, gridTamanho);

  % Inicializa o vetor de feromônio com um valor fixo
  model.tau = ones(1, n);  % Todos os pontos começam com o mesmo nível de feromônio

  model.n = n;
  model.cols = gridTamanho;
end
