function noteArray = pyOnsetDetect(fileName)
    %For now, just call a python function that detects onsets using an
    %aubio algorithm
    pyOnsets = py.onsetDetect.detectOnset(fileName);
    %Convert to cell array
    onsets = cell(pyOnsets);
end