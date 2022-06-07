function results = testResults(input, Fs, noteArray, testFileName, tempo)
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
    %Precision is the same as accuracy because precision = TP/(TP + FP) and
    %only "positives" are reported, not negatives, so this is the same as
    %TP/length(noteArray)
    precOverall = accOverall;
    recallOverall = calcRecall(noteArray, groundTruthArray, "overall");
    fOverall = calcF(precOverall, recallOverall);

    
    %3. Test the onsets
    accOnset = calcAcc(noteArray, groundTruthArray, "onset");
    %Precision is the same as accuracy here again
    precOnset = accOnset;
    recallOnset = calcRecall(noteArray, groundTruthArray, "onset");
    fOnset = calcF(precOnset, recallOnset);
    
    
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

    %Pitch detection doesn't have recall or precision because the absolute
    %true positives are given already
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
    
    %String-Fret Detection doesn't have recall or precision because the
    %absolute true positives are given already
    accString = calcAcc(testStringArray, groundTruthArray, "string");
    
    
    %6. Close test file and write to final return object
    fclose(fileID);
    
    results.overall = [accOverall, precOverall, recallOverall, fOverall];
    results.onset = [accOnset, precOnset, recallOnset, fOnset];
    results.pitch = accPitch;
    results.string = accString;
    
    %7. Optional: Write testNoteArray to a tab
%     tabWrite(input, Fs, groundTruthArray, tempo, 'tab_output_test.txt');
end