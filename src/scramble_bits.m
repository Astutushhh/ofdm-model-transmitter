%% SCRAMBLEBITS Скремблирует поток бит по 802.11a (x^7+x^4+1)
%   seed - 7x1 ненулевой начальный вектор регистра скремблера
function scrambledBits = scramble_bits(bits, seed)
    if nargin < 2 % nargin  - количество входных аргументов(если не передан seed, то используем стандартный seed)
        seed = ones(7, 1);   % в своей симуляции можно любой ненулевой
    end
    scrambledBits = wlanScramble(bits(:), seed);
    scrambledBits = scrambledBits.';   % возвращаем строкой
end