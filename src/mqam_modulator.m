%% mqam_modulator - function to modulate a bit stream into M-QAM symbols
% M - modulation order (e.g., 4 for QPSK, 16 for 16-QAM, etc.)

function [symbols, padLen] = mqam_modulator(bits, M) 

    %mqam_modulator Maps a bit stream onto M-QAM symbols (Gray-coded, unit power)
    bitsPerSymbol = log2(M);

    % Ищем ближайшую длину, кратную bitsPerSymbol (округляя вверх), 
    % и вычисляем разницу с текущей длиной.
    padLen = mod(-length(bits), bitsPerSymbol);

    % Склеиваем нули в конец потока битов, чтобы получить длину, кратную bitsPerSymbol
    bitsPadded = [bits, zeros(1, padLen)];

    symbols = qammod(bitsPadded.', M, 'gray', ...
        'InputType', 'bit', ...
        'UnitAveragePower', true); % Нормализация мощности символов

end 