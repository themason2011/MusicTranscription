[input,Fs] = audioread('AR_Lick4_KN.wav');

flux = spectralFlux(input, Fs, "Window", hamming(round(0.025*Fs)), "OverlapLength", round(0.0125*Fs), "Range", [62.5,Fs/2]);

fluxClip = flux(round(2*Fs/441):round(2.75*Fs/441));

[y, lags] = xcorr(fluxClip);

x_vec = linspace(0,size(input,1)/Fs,size(flux,1));
subplot(1,2,1)
plot(x_vec,flux);
xlabel('Time (Seconds)');

subplot(1,2,2)
plot(lags, y);
xlabel('Lag (Spectral Flux Samples)');
