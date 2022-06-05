function results = testResults(input, Fs, testFileName, noteArray)
    %NOTE: For each test, calculate accuracy, precision, recall, and
    %F-measure. Also, don't need to explicitly test fretDetect because it's
    %just a formula and don't need to test tempo because tempo isn't
    %given in test files. Maybe I could label it myself and test it? Don't
    %mind but not sure if necessary
    
    %1. Prepare the ground truth array to compare against using testFileName
    fileID = fopen(testFileName);
    cellArray = textscan(fileID, '%n %n %n %n');
    groundTruthArray = [];
    for i = 1:length(cellArray{1})
        testNote = Note();
        testNote.onset = cellArray{1}(i);
        testNote.midi = cellArray{2}(i);
        testNote.string = cellArray{3}(i);
        testNote.fret = cellArray{4}(i);
        groundTruthArray = [groundTruthArray; testNote];
    end
    
    
    %2. Test the entire process (i.e. perfect notes)
    accOverall = calcAcc(noteArray, groundTruthArray, "overall");

    
    %3. Test the onsets
    accOnset = calcAcc(noteArray, groundTruthArray, "onset");
    
    
    %4. Test the pitch detection (re-run pitchDetect using the ground-truth
    %onset values)
    %Populate a noteArray with the ground truth onsets and re-calculate the
    %pitches using this
    testPitchArray = [];
    for i = 1:length(cellArray{1})
        testNote = Note();
        testNote.onset = cellArray{1}(i);
        testPitchArray = [testPitchArray; testNote];
    end
    
    %Re-run pitch detection with ground-truth onsets
    testPitchArray = pitchDetect(input, Fs, testPitchArray);

    accPitch = calcAcc(testPitchArray, groundTruthArray, "pitch");
    
    
    %5. Test the string detection (re-run stringDetect using the ground-truth
    %onset and pitch values)
    testStringArray = [];
    for i = 1:length(cellArray{1})
        testNote = Note();
        testNote.onset = cellArray{1}(i);
        testNote.midi = cellArray{2}(i);
        testNote.pitch = 2.^((testNote.midi-69)/12)*440;
        testStringArray = [testStringArray; testNote];
    end
    
    testStringArray = stringDetect(input, Fs, testStringArray);
    
    accString = calcAcc(testStringArray, groundTruthArray, "string");
    
    
    %6. Close test file and write to final return object
    fclose(fileID);
    
    results.overall = accOverall;
    results.onset = accOnset;
    results.pitch = accPitch;
    results.string = accString;
end