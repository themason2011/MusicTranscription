function tabOutput = main(fileName, testFileName)
    %Instantiate a noteArray. This will hold an array of Note objects,
    %which will each hold the values for the onset, offset, pitch, string, and
    %fret a single note. These empty note objects will all be appended by
    %onsetDetct and will then have the other values added later on by other
    %methods.
    noteArray = [];

    %Load music clip
    [input, Fs] = audioread(fileName);
    
    %Perform onset detection using spectral flux and peak picking. Save
    %spectral flux for potential use in tempo detection, if time permits
    [flux, noteArray] = onsetDetect(input, Fs, noteArray);

    %Perform offset detection using idk
    noteArray = offsetDetect(input, Fs, noteArray);
    
    %Perform monophonic pitch detection at all onsets, return a pitch in Hz
    %(may not need offsets, not sure)
    noteArray = pitchDetect(input, Fs, noteArray);
    
    %Perform inharmonicity analysis at each onset, return which string
    %was played.
    noteArray = stringDetect(input, Fs, noteArray);
    
    %Calculate which fret is being played for each onset based on pitch and
    %string number. Assume standard tuning (1st string open note is MIDI 44)
    %by default
    noteArray = fretDetect(input, Fs, noteArray);
    
    %Load testing method, which will take in onset, offset, pitch (in Hz,
    %convert to midi note number in testing method), string number, and 
    %fret number and test. Calculate accuracy, recall, and F-Score for the 
    %song overall (within some tolerance for onset and offset time). 
    %For results that just test individual components of the system, make
    %sure to re-run the individual components while being given the correct
    %results from the annotation. For example, correct pitch calculation is
    %dependent on correct onset detection, so give the correct onsets
    %before evaluating the pitch component individually.
    results = testResults(testFileName, noteArray);
    
    %Optional: Calculate tempo using spectral flux and FFT/autocorrelation.
    %If not enough time, just manually calculate tempo for each test file
    %and use that
    tempo = tempoDetect(input, Fs);
    
    %Write function that outputs ASCII tablature using onset, offset,
    %string number, fret number, and tempo. Return this to main as a txt
    %file or something similar
    tabOutput = tabWrite(noteArray, tempo, Fs);
end