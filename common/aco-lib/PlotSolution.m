%% @file PlotSolution.m
% @brief Plota a superfície 3D da função Picos e marca o melhor ponto encontrado.
%
% @details
% Renderiza a superfície da função Picos usando os dados do grid armazenados
% em model.X_grid, model.Y_grid e model.Z_grid. O melhor ponto encontrado
% pelo ACO (último ponto do caminho da melhor formiga) é marcado com um
% círculo vermelho sobre a superfície.
%
% Esta função deve ser chamada após a inicialização de uma figura (figure),
% pois não cria uma janela própria, permitindo atualização iterativa com drawnow().
%
% @param tour  Vetor de índices lineares representando o caminho percorrido
%              pela melhor formiga. O último elemento (tour(end)) é o melhor
%              ponto encontrado.
% @param model Struct do problema gerada por CreateModel(), utiliza os campos:
%              model.X_grid, model.Y_grid, model.Z_grid, model.cols
%
% @author Allany Victória Santos Araújo
% @date 2025

function PlotSolution(tour, model)

  % Plotar a superfície 3D com surf
  surf(model.X_grid, model.Y_grid, model.Z_grid);
  hold on;

  % Marcar o melhor ponto encontrado pelo ACO (último ponto do caminho)
  idx_best = tour(end);
  [best_x, best_y] = ind2sub([model.cols, model.cols], idx_best);
  best_z = model.Z_grid(best_x, best_y);

  % Plotar o ponto de melhor custo destacado em vermelho
  plot3(model.X_grid(best_x, best_y), model.Y_grid(best_x, best_y), best_z, ...
        'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10);

  % Rótulos e formatação
  title('Visualização da Função Picos - Melhor Ponto ACO');
  xlabel('X');
  ylabel('Y');
  zlabel('f(x,y)');
  shading interp;
  colorbar;
  view(3);
  grid on;
  hold off;

end
