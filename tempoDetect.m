function tempo = tempoDetect(fileName)
    %For now, just call a python function that detects tempo using a
    %librosa algorithm
    tempo = py.tempoDetect.detectTempo(fileName);
end