clc;      % limpa a tela
clear;    % limpa variáveis antigas

% Carrega o pacote simbólico
pkg load symbolic;

% Define as variáveis simbólicas
syms x y

% Define a equação
f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ...
    - 10*(x/5 - x^3 - y^5)*exp(-(x^2) - (y^2)) ...
    - (1/3)*exp(-((x+1)^2) - (y^2));

% Calcula as derivadas parciais
dfdx = diff(f, x);
dfdy = diff(f, y);

% Mostra os resultados
disp('Derivada parcial em relação a x:');
disp(dfdx);
disp('Derivada parcial em relação a y:');
disp(dfdy);

% Gera as expressões em LaTeX
disp('--- LaTeX ---');
latex_dfdx = latex(dfdx);
latex_dfdy = latex(dfdy);
disp('df/dx em LaTeX:');
disp(latex_dfdx);
disp('df/dy em LaTeX:');
disp(latex_dfdy);

% Avaliar derivadas em (0,0)
val_dfdx_0 = subs(dfdx, [x, y], [0, 0]);
val_dfdy_0 = subs(dfdy, [x, y], [0, 0]);
disp('Avaliação das derivadas em (0,0):');
disp(['df/dx (0,0) = ', char(val_dfdx_0)]);
disp(['df/dy (0,0) = ', char(val_dfdy_0)]);

% Tentar resolver o sistema de equações df/dx = 0, df/dy = 0
sol = solve([dfdx == 0, dfdy == 0], [x, y]);
disp('Soluções do sistema df/dx = 0, df/dy = 0:');
disp(sol);
