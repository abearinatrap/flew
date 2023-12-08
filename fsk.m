M = 2;         % Modulation order
k = log2(M);   % Bits per symbol
EbNo = 5;      % Eb/No (dB)
Fs = 16;       % Sample rate (Hz)
nsamp = 8;     % Number of samples per symbol
freqsep = 10;  % Frequency separation (Hz)
data = randi([0 M-1],5000,1);

txsig = fskmod(data,M,freqsep,nsamp,Fs);

time = (0:length(txsig)-1) / Fs;
figure;
plot(time, real(txsig), 'b', time, imag(txsig), 'r');
title('IEEE 802.11b Time-Domain Waveform');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Real', 'Imaginary');


rxSig  = awgn(txsig,EbNo+10*log10(k)-10*log10(nsamp),...
    'measured',[],'dB');
dataOut = fskdemod(rxSig,M,freqsep,nsamp,Fs);
[num,BER] = biterr(data,dataOut);