clc; clear; close all;

Nbits = 4e4;                 % Must be multiple of 4
SNR_dB = 0:1:12;

BER_uncoded = zeros(size(SNR_dB));
BER_coded = zeros(size(SNR_dB));

%% Generate data
data = randi([0 1], Nbits, 1);

%% Hamming (7,4) Generator Matrix
G = [1 0 0 0 1 1 0;
     0 1 0 0 1 0 1;
     0 0 1 0 0 1 1;
     0 0 0 1 1 1 1];

%% Hamming Parity Check Matrix
H = [1 1 0 1 1 0 0;
     1 0 1 1 0 1 0;
     0 1 1 1 0 0 1];

for i = 1:length(SNR_dB)

    snr = 10^(SNR_dB(i)/10);

    %% -------- Uncoded BPSK --------
    bpsk = 2*data - 1;
    noise = sqrt(1/(2*snr)) * randn(length(bpsk),1);
    rx = bpsk + noise;
    data_rx = rx > 0;
    BER_uncoded(i) = mean(data ~= data_rx);

    %% -------- Hamming (7,4) Coded --------
    data_blocks = reshape(data, 4, []).';
    coded = mod(data_blocks * G, 2);
    coded = coded.';
    coded = coded(:);

    bpsk_c = 2*coded - 1;

    noise_c = sqrt(1/(2*snr)) * randn(length(bpsk_c),1);
    rx_c = bpsk_c + noise_c;
    rx_bits = rx_c > 0;

    % Decode
    rx_blocks = reshape(rx_bits, 7, []).';
    syndrome = mod(rx_blocks * H.', 2);

    for k = 1:size(rx_blocks,1)
        s = syndrome(k,:);
        if any(s)
            err_pos = bi2de(s,'left-msb');
            if err_pos >=1 && err_pos <=7
                rx_blocks(k,err_pos) = ~rx_blocks(k,err_pos);
            end
        end
    end

    decoded = rx_blocks(:,1:4);
    decoded = decoded.';
    decoded = decoded(:);

    BER_coded(i) = mean(data ~= decoded);
end

%% -------- Plot --------
figure;
semilogy(SNR_dB, BER_uncoded,'o-'); hold on;
semilogy(SNR_dB, BER_coded,'s-');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
legend('Uncoded BPSK','Hamming (7,4) Coded BPSK');
title('BER Performance with and without Hamming Coding');
