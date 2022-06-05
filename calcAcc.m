function result = calcAcc(noteArray, testNoteArray, type)
    numCorrect = 0;
    if type == "overall"
        %For a note in noteArray to be classified as correct in overall
        %mode, it must have the correct onset (within a certain range), a
        %correct midi note, and a correct string
        for i = 1:length(testNoteArray)
            for j = 1:length(noteArray)
                minOnset = testNoteArray(i).onset - 0.04;
                maxOnset = testNoteArray(i).onset + 0.02;
                if (noteArray(j).onset > minOnset & noteArray(j).onset < maxOnset) & noteArray(j).midi == testNoteArray(i).midi & noteArray(j).string == testNoteArray(i).string
                    numCorrect = numCorrect + 1;
                    break
                end
            end
        end

    elseif type == "onset"
        %For each onset in testNoteArray, check if one of the onsets in
        %noteArray is close enough to count as a correct onset. If so, mark
        %it as one correct value and move to the next ground truth onset.
        %Note that the same onset being detected multiple times will still
        %only count as one correct detection. Also, the minOnset range is
        %shifted to the left by .01 because the onset tends to be detected
        %slightly after the actual onset
        for i = 1:length(testNoteArray)
            for j = 1:length(noteArray)
                minOnset = testNoteArray(i).onset - 0.04;
                maxOnset = testNoteArray(i).onset + 0.02;
                if (noteArray(j).onset > minOnset & noteArray(j).onset < maxOnset)
                    numCorrect = numCorrect + 1;
                    break
                end
            end
        end

    elseif type == "pitch"
        %noteArray is the same length as testNoteArray, because the ground
        %truth onsets are given for this calculation
        for i = 1:length(testNoteArray)
            if noteArray(i).midi == testNoteArray(i).midi
                numCorrect = numCorrect + 1;
            end
        end

    elseif type == "string"
        %Same thing as in pitch mode, except both ground truth onset AND
        %midi pitch are given
        for i = 1:length(testNoteArray)
            if noteArray(i).string == testNoteArray(i).string
                numCorrect = numCorrect + 1;
            end
        end
    end
    
    result = numCorrect/length(noteArray);
end