function noteArray = fretDetect(input, Fs, noteArray)
    %Construct the midiToStringFret conversion. The value of each element
    %is the MIDI value at the string,fret index (note that the open note 
    %fret for each string is at 1, not 0, because of matlab indexing).
    %Assume the guitar has 22 frets.
    midiToStringFret = zeros(6,23);
    for i = 1:6
        if i == 5 || i == 6
            midiToStringFret(i,:) = [40+(i-1)*5-1:62+(i-1)*5-1];
        else
            midiToStringFret(i,:) = [40+(i-1)*5:62+(i-1)*5];
        end
    end
    
    %For each note, find the fret by finding the index of the element that
    %matches the note's midi to a midi in the "midiToStringFret" array 
    %by selecting only one row in the array based on the string the note 
    %was played on. If there is no corresponding fret for string and MIDI
    %note given, it is likely that the note is either a ghost note or
    %stringDetect returned the wrong string, so set fret equal to -1.
    for i = 1:length(noteArray)
        fretIdx = find(noteArray(i).midi == midiToStringFret(noteArray(i).string,:));
        if isempty(fretIdx)
            noteArray(i).fret = -1;
        else
            noteArray(i).fret = fretIdx - 1;
        end
    end
end