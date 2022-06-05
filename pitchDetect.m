function noteArray = pitchDetect(input, Fs, noteArray)
    %TODO: Maybe add some zero-padding to the clips I'm taking to increase
    %accuracy of the frequency detection by adding more bins to the FFT? 
    %It seems pretty good already (+- a few Hz) but it might help to
    %improve it, note sure. Also, try messing with the start time for the
    %onset clip (maybe move the start back a bit more, 30-40 ms instead of
    %10 ms) and the overall length of the clip (50 ms after the onset
    %should be good to prevent other notes from leaking into the clip, but
    %can try experimenting)
    
    %Define midiArray and midiToHz
    
    %Lowest note in standard tuning on guitar is MIDI = 40 and highest
    %is MIDI = 86 (assuming 22-fret guitar).
    midiArray = [40:86];

    %Equation for converting MIDI to approximate Hz values
    midiToHz = 2.^((midiArray-69)/12)*440;
    
    
    %For each onset in noteArray
    for i = 1:length(noteArray)
        %Set window size to 60 ms, overlap to 0 ms (because we want pitch
        %to only calculate one window in total)
        winDur = 0.065;
        overlapDur = 0.00;

        %Calculate window length in samples and overlap length in samples
        %using Fs
        winLength = round(winDur*Fs);
        overlapLength = round(overlapDur*Fs);
        
        %Calculate the starting and stopping point of the clip we want to
        %analyze for a particular onset (end time is based on minimum
        %distance of 50 ms between notes to prevent overlap with next note)
        samplesStart = round(noteArray(i).onset*Fs)-.015*Fs;
        samplesEnd = samplesStart + .065*Fs;
        
        %Approximate the pitch of the onset clip using the Cepstral method.
        %Max frequency range is set to 1300 Hz, which is the highest
        %fundamental you can make on a standard tuning guitar.
        approxPitch = pitch(input(samplesStart:samplesEnd), Fs, ...
            'Method', 'NCF', ...
            'Range', [62.5, 1300], ...
            'WindowLength', winLength, ...
            'OverlapLength', overlapLength);
        
        %Add the new pitch approximation to the corresponding note
        noteArray(i).pitch = approxPitch;
        
        
        %Convert approximated pitch to the nearest MIDI value using
        %midiArray and midiToHz
        
        %Find the index of the MIDI-to-Hz value that is closest to the 
        %approximated pitch and grab the corresponding MIDI value from the 
        %midiArray using the index, then append to noteArray
        [~, midiIdx] = min(abs(midiToHz-approxPitch));
        approxMidi = midiArray(midiIdx);
        noteArray(i).midi = approxMidi;
    end
end