%% OFDMMODULATE Раскладывает QAM-символы по карте cfg, делает IFFT и добавляет CP
function ofdmTimeSignal = ofdm_modulate(txQAMSymbols, cfg)
    % Вычисляем количество нулей для добивки сообщерния до кратного числа поднесущих
    padSymbols = mod(-length(txQAMSymbols), cfg.numDataPerSymbol);

    % Добиваем нулями поток QAM-символов, чтобы получить длину, кратную числу поднесущих
    txQAMPadded = [txQAMSymbols, zeros(1, padSymbols)];

    % Вычисляем количество OFDM-символов, которые мы будем передавать
    numOFDMSymbols = length(txQAMPadded) / cfg.numDataPerSymbol;

    % Раскладываем QAM-символы по колонкам (каждая колонка - один OFDM-символ)
    %  и сначало колонки потом строки в матрице размером cfg.numDataPerSymbol строк и numOFDMSymbols колонок.
    %  Каждая колонка - один OFDM-символ, каждая строка - один QAM-символ на поднесущей.
    dataMatrix = reshape(txQAMPadded, cfg.numDataPerSymbol, numOFDMSymbols); 

    % Создаем матрицу спектра с нулями для всех поднесущих всех символов офдм
    centeredSpectrum = zeros(cfg.N, numOFDMSymbols);

    % Заполняем матрицу спектра данными, которые мы получили(48 строк на n столбцов, где n - количество OFDM-символов)
    centeredSpectrum(cfg.dataPositions, :)  = dataMatrix;

    %% Форимируем пилотики

    % При помощи функции mod(x, y) вычисляем полярность пилотов в зависимости от порядка символов
    % если дошли до 128 символа последовательность зациклилась и берем первый символ а не 128
    pilotIdxSeq = mod((0:numOFDMSymbols-1), 127) + 1;

    % Достали нужный индекс из нашего вектора полярности для пилотиков
    pilotPolarityPerSymbol = cfg.pilotPolaritySeq(pilotIdxSeq).';   % 1 x numOFDMSymbols

    % Умножили базовую пилотную последовательность на символ полярности
    % (каждый символ полярности умножаем на базовую последовательность и вписываем в матрицу спектра)
    centeredSpectrum(cfg.pilotPositions, :) = cfg.pilotBasePattern * pilotPolarityPerSymbol;

    %% Проведем преобразование Фурье

    % Сдвинули наш центрированный спектр для подачи на IFFT
    % (сначала от нуля в положительную област, потом отрицательные частоты)
    freqDomainMatrix = ifftshift(centeredSpectrum, 1);

    % Делаем ifft по столбцам, размер ifft - N
    timeDomainMatrix = ifft(freqDomainMatrix, cfg.N, 1);

    % Приклеиваем хвост нашего сообщения в начало в 2х мерной матрице, где столбцы - символы офдм
    cpMatrix = [timeDomainMatrix(end-cfg.cpLength+1:end, :); timeDomainMatrix];

    % Развернули нашу двумерную матрицу в непрерывный поток во времени, 
    % где офдм символы идут друг за другом
    ofdmTimeSignal = reshape(cpMatrix, 1, []);
end