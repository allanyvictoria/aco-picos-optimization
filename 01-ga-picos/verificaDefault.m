clc;
clear all;

pkg load ga

% Cria struct com opções padrão do GA
options = gaoptimset();

disp('Opções padrão do GA no Octave:');
fields = fieldnames(options);

for i = 1:length(fields)
    fname = fields{i};
    fvalue = options.(fname);

    % Se for function handle, converte para string com func2str
    if isa(fvalue, 'function_handle')
        fvalue_str = func2str(fvalue);
    else
        % Para outros tipos, tenta converter para string
        fvalue_str = mat2str(fvalue);
    end

    fprintf('%-20s : %s\n', fname, fvalue_str);
end

