function tabOutput = main(fileName, testFileName)
    fileNameArray = ["audio/FS_Lick1_KN.wav","audio/FS_Lick2_KN.wav","audio/FS_Lick3_KN.wav","audio/FS_Lick4_KN.wav","audio/FS_Lick5_KN.wav","audio/FS_Lick6_KN.wav"];
    testFileNameArray = ["annotation/FS_Lick1_KN.txt","annotation/FS_Lick2_KN.txt","annotation/FS_Lick3_KN.txt","annotation/FS_Lick4_KN.txt","annotation/FS_Lick5_KN.txt","annotation/FS_Lick6_KN.txt"];
    
    totalOverall = [0,0,0,0];
    totalOnset = [0,0,0,0];
    totalPitch = 0;
    totalString = 0;
    
    for i = 1:length(fileNameArray) 

        currFileName = fileNameArray(i);
        currTestFileName = testFileNameArray(i);
        
        %TODO: Write tabWrite method, finish re-recording and annotating audio
        %clips on my strat, improve onsetDetect, improve stringDetect and add
        %the heuristic feature that limits possible string-fret combos to be
        %less than 6 frets up or down from previous note. Will require
        %labelling the first note's string-fret combo manually to prevent
        %starting with incorrect combo

        %Inharm coefficients derived from my calculations with
        %strat_calibrate.wav
        %[0.000399822297265766],[-5.05941634697558e-05],[4.52935840780666e-05],[9.92920743028479e-05],[5.43053997699722e-05][9.73461504665579e-06]

        %Inharm coefficients derived from my calculations with 

        %Instantiate a noteArray. This will hold an array of Note objects,
        %which will each hold the values for the onset, offset, pitch, string, and
        %fret a single note. These empty note objects will all be appended by
        %onsetDetct and will then have the other values added later on by other
        %methods.
        noteArray = [];

        %Load music clip
        [input, Fs] = audioread(currFileName);
        %Grabbing only one channel
        input = input(:,1);

        %Optional: Calculate tempo using spectral flux and FFT/autocorrelation.
        %If not enough time, just manually calculate tempo for each test file
        %and use that
        tempo = tempoDetect(fileName);

        %Perform onset detection using spectral flux and peak picking.
        [flux, noteArray] = onsetDetect(input, Fs, noteArray);

        %Perform monophonic pitch detection at all onsets and save the
        %estimated pitch into the note objects in noteArray as both Hz and MIDI
        %values
        noteArray = pitchDetect(input, Fs, noteArray);

        %Perform inharmonicity analysis at each onset, return which string-fret
        %combo was played
        noteArray = stringDetect(input, Fs, noteArray);

        %Load testing method, which will take in onset, offset, pitch (in Hz,
        %convert to midi note number in testing method), string number, and 
        %fret number and test. Calculate accuracy, recall, and F-Score for the 
        %song overall (within some tolerance for onset and offset time). 
        %For results that just test individual components of the system, make
        %sure to re-run the individual components while being given the correct
        %results from the annotation. For example, correct pitch calculation is
        %dependent on correct onset detection, so give the correct onsets
        %before evaluating the pitch component individually.
        results = testResults(input, Fs, noteArray, currTestFileName, tempo);
        
        totalOverall = totalOverall + results.overall;
        totalOnset = totalOnset + results.onset;
        totalPitch = totalPitch + results.pitch;
        totalString = totalString + results.string;
        
        disp("Overall Accuracy, Precision, Recall, and F-Measure: ");
        disp(string(results.overall));
        disp("Onset Accuracy, Precision, Recall, and F-Measure: ");
        disp(string(results.onset));
        disp("Pitch Accuracy: " + string(results.pitch));
        disp("String Accuracy: " + string(results.string));

        %Write function that outputs ASCII tablature using onset, offset,
        %string number, fret number, and tempo. Return this to main as a txt
        %file or something similar. Assume 4/4 time sig for now, may want to 
        %add ability to change time sig later
    %     tabWrite(input, Fs, noteArray, tempo, "tab_output_final.txt");
    end
    
    totalOverall = totalOverall/length(fileNameArray)
    totalOnset = totalOnset/length(fileNameArray)
    totalPitch = totalPitch/length(fileNameArray)
    totalString = totalString/length(fileNameArray)
end