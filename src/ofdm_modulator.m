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

% Modulate message bits into N-QAM symbols
[txQAMSymbols, ~] = mqam_modulator(txBits, M);


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
cd(txQAMSymbols) 

%% Проверка корректности конфига через построения простейшего графика

% Получаем конфиг
cfg = get_ofdm_config_80211a();

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