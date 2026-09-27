function cfg = get_ofdm_config_80211a()
%get_ofdm_config_80211a Параметры OFDM для IEEE 802.11a (канал 20 МГц)

    cfg.standardName = '802.11a';
    cfg.N = 64; % размер FFT
    cfg.cpLength = 16; % длина циклического префикса
    cfg.sampleRate = 20e6; % Гц

    k = -cfg.N/2 : cfg.N/2 - 1; % центрированные индексы поднесущих

    dataIdx = [-26:-22, -20:-8, -6:-1, 1:6, 8:20, 22:26];
    pilotIdx = [-21, -7, 7, 21];

    subcarrierMap = zeros(1, cfg.N);

    % ismember - функция, которая берет каждый элемент из k и проверяет, 
    % есть ли он в dataIdx. Если есть, то возвращает true, иначе false(булев массив длиной k)
    % далее если у нас true, то присваиваем 2 (данные)
    subcarrierMap(ismember(k, dataIdx)) = 2; 

    % Проверяем на пилоты и присваиваем 1 (пилоты) - ровно так же, как и для данных, только с другим индексом
    subcarrierMap(ismember(k, pilotIdx)) = 1;

    cfg.subcarrierMap = subcarrierMap; % 1xN, центрированный порядок
    
    % Закидываем индексы в cfg наши
    cfg.dataPositions = find(subcarrierMap == 2);
    cfg.pilotPositions = find(subcarrierMap == 1);
    cfg.numDataPerSymbol = numel(cfg.dataPositions);
    cfg.pilotValues = ones(numel(cfg.pilotPositions), 1); % упрощённые значения, закидываем 1
end