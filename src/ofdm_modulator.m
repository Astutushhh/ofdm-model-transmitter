% Setup path
scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);

% close all;
clear all;
clc;
%% Constants
N = 64; % Number of subcarriers
M = 16; % Modulation order for N-QAM (e.g., 4 for QPSK, 16 for 16-QAM, etc.)

%% Generate message 

txBits = str2bits('Hello, world!');

% Получаем конфиг
cfg = get_ofdm_config_80211a();

% Скремблирование - на сырых битах, ДО QAM
txBitsScrambled = scramble_bits(txBits, cfg.scramblerSeed);

% Modulate message bits into N-QAM symbols
[txQAMSymbols, padLen] = mqam_modulator(txBitsScrambled, M);

% Subcarrier mapping + IFFT + CP - всё уже готово
ofdmTimeSignal = ofdm_modulate(txQAMSymbols, cfg);


%% Output results
% Print message bits
fprintf('txBits: %s\n', num2str(txBits));

% Print modulated symbols
disp(txQAMSymbols);

idealPoints = qammod(0:M-1, M, 'gray', 'UnitAveragePower', true);

% Full paramreters of the constellation diagram can be found here: https://www.mathworks.com/help/comm/ref/comm.constellationdiagram-system-object.html
cd = comm.ConstellationDiagram( ...
    'ReferenceConstellation', idealPoints, ...
    'ReferenceMarker', 'O', ...
    'ReferenceColor', [0.576 0.439 0.859], ...
    'ShowReferenceConstellation', true);

% Plot the constellation diagram of the modulated symbols + the reference constellation
cd(txQAMSymbols(:)) 

%% Проверка корректности конфига через построения простейшего графика

% Построение карты поднесущих
% k - индексы поднесущих
% cfg.subcarrierMap - карта поднесущих
% cfg.dataPositions - индексы данных
% cfg.pilotPositions - индексы пилотов
k = -cfg.N/2 : cfg.N/2 - 1;

figure('Name', 'Проверка конфига: карта поднесущих');
stem(k, cfg.subcarrierMap, 'filled', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on;
xlabel('Индекс поднесущей (k)');
ylabel('Метка');
title('Карта поднесущих (0=пусто, 1=пилот, 2=данные)');
ylim([-0.5, 2.5]);
yticks([0, 1, 2]);
yticklabels({'0: Пусто (Guard/DC)', '1: Пилот', '2: Данные'});
xlim([-33, 32]);
xticks(-32:1:31); % Подписи каждые 1 точки

%% OFDM-сигнал во временной области
figure('Name', 'OFDM-сигнал во времени');
plot(real(ofdmTimeSignal), 'LineWidth', 1); hold on;
plot(imag(ofdmTimeSignal), 'LineWidth', 1); hold off;
grid on;
xlabel('Отсчёт'); ylabel('Амплитуда');
legend('Re', 'Im');
title('OFDM-сигнал во временной области');

%% Cпектр переданного сигнала
figure('Name', 'Спектр OFDM-сигнала');
pwelch(ofdmTimeSignal, [], [], [], cfg.sampleRate, 'centered');
title('Спектральная плотность мощности OFDM-сигнала');

% Достаём единственный OFDM-символ без CP (ядро длиной N)
coreSymbol = ofdmTimeSignal(cfg.cpLength+1 : cfg.cpLength+cfg.N);

% Обычный FFT (не Уэлча!) - ровно N=64 точки, в том же порядке, что и карта
spectrumCheck = fftshift(fft(coreSymbol, cfg.N));

figure('Name', 'Дискретный спектр одного OFDM-символа');
stem(k, abs(spectrumCheck), 'filled');
grid on;
xlabel('Индекс поднесущей (k)');
ylabel('|X(k)|');
title('FFT одного OFDM-символа (без CP) - должен повторять карту поднесущих');