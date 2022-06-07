function [flux, noteArray] = onsetDetect(input, Fs, noteArray)
    %TODO: Potentially adjust MinPeakDistance dynamically based on the
    %tempo of the song. Higher BPM means you need a smaller minpeakdistance
    %to account for notes being closer together. Also try adjusting other
    %parameters from the findpeaks method. Potentially use taylor window
    %instead of hamming window, it was the only other window that performed
    %similar to hamming. Maybe try normalizing the audio input or spectral
    %flux data so that the correct minpeakheight is more consistent. Look
    %into potential dynamic thresholding options for peak picking? Also
    %maybe adjust block size to increase frequency resolution, or add some
    %zero-padding somehow to do the same

    %Defining parameters for block-based processing     
    blockSize = 2048;
    hopSize = round(0.05*blockSize);
    
    %Applying the Spectral Flux to the original time signal, using a
    %hamming window and 75% overlap.
    flux = spectralFlux(input, Fs, "Window", hann(blockSize), "OverlapLength", blockSize-hopSize, "Range", [62.5,Fs/2]);
    cubed_flux = flux.^3;
    norm_flux = mat2gray(cubed_flux);
    plot(linspace(0,length(input)/Fs,length(norm_flux)),norm_flux);
    xlabel('Time (sec)');
    ylabel('Magnitude');
    %Perform peak picking on the spectral flux results (MinPeakDistance is
    %the number of spectral units calculated based on a minimum distance 
    %of 50 ms between notes, which is approximately a 1/32nd note at 180 
    %BPM. Can probably change this MinPeakDistance based on tempo to reduce
    %the chance of ghost notes being detected from transients)
    [~, onsets] = findpeaks(norm_flux, 'MinPeakHeight', 0.02, 'MinPeakDistance', 11);

    %Convert the onset location values from spectral flux units to time
    %units. One spectral flux unit is equal to hopSize number of time
    %samples
    onsets = (onsets*(hopSize)/Fs);
    
    %Create note objects, one for each onset, and append them to the note
    %array
    for i = 1:length(onsets)
        newNote = Note();
        newNote.onset = onsets(i);
        noteArray = [noteArray; newNote];
    end
end