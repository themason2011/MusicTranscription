[input,Fs] = audioread('audio/AR_Lick1_KN.wav');

blockSize = 2048;
hopSize = round(0.25*blockSize);

flux = spectralFlux(input, Fs, "Window", hamming(blockSize), "OverlapLength", blockSize-hopSize, "Range", [62.5,Fs/2]);

[~, onsets] = findpeaks(flux, 'MinPeakHeight', 0.9*10.^-3, 'MinPeakDistance', 6)

onsets = (onsets*(hopSize)/Fs)

xlabel(linspace(0,length(input)/Fs, length(input)/Fs))

fluxClip = flux(round(2*Fs/441):round(2.75*Fs/441));

[y, lags] = xcorr(fluxClip);

x_vec = linspace(0,size(input,1)/Fs,size(flux,1));
% subplot(1,2,1)
% plot(x_vec,flux);
% xlabel('Time (Seconds)');
% 
% subplot(1,2,2)
% plot(lags, y);
% xlabel('Lag (Spectral Flux Samples)');
