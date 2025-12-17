clc; clear; close all;

Nbits = 1e6;                 % Number of bits
SNR_dB = 0:1:15;             % SNR range
BER_sim = zeros(size(SNR_dB));
BER_theory = zeros(size(SNR_dB));

bits = randi([0 1], Nbits, 1);
symbols = 2*bits - 1;        % BPSK mapping

for i = 1:length(SNR_dB)
    snr = 10^(SNR_dB(i)/10);

    noise = sqrt(1/(2*snr)) * randn(Nbits,1);
    rx = symbols + noise;

    bits_rx = rx > 0;
    BER_sim(i) = sum(bits ~= bits_rx) / Nbits;
    BER_theory(i) = 0.5 * erfc(sqrt(snr));
end

semilogy(SNR_dB, BER_sim, 'o-');
hold on;
semilogy(SNR_dB, BER_theory, 'r');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
legend('Simulated BER','Theoretical BER');
title('BER Performance of BPSK over AWGN');
