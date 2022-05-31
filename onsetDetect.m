function [flux, noteArray] = onsetDetect(input, Fs, noteArray)
    flux = spectralFlux(input, Fs, "Window", hamming(round(0.025*Fs)), "OverlapLength", round(0.0125*Fs), "Range", [62.5,Fs/2]);
end