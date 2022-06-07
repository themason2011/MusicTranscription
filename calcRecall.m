function result = calcRecall(noteArray, testNoteArray, type)
    truePositive = 0;
    falseNegative = 0;
    if type == "overall"
        %For a note in noteArray to be classified as correct in overall
        %mode, it must have the correct onset (within a certain range), a
        %correct midi note, and a correct string
        for i = 1:length(testNoteArray)
            for j = 1:length(noteArray)
                minOnset = testNoteArray(i).onset - 0.02;
                maxOnset = testNoteArray(i).onset + 0.0375;
                if (noteArray(j).onset > minOnset & noteArray(j).onset < maxOnset) & noteArray(j).midi == testNoteArray(i).midi & noteArray(j).string == testNoteArray(i).string
                    truePositive = truePositive + 1;
                    falseNegative = falseNegative - 1;
                    break
                end
            end
            %If this line is reached, it means no positives were found for
            %this true note, meaning that this is a false negative (i.e. no
            %note has been detected when there should have been).
            falseNegative = falseNegative + 1;
        end
        
        %Recall is the same as accuracy in this case, because only
        %"positives" are reported
        falsePositive = length(noteArray) - truePositive;

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
                minOnset = testNoteArray(i).onset - 0.02;
                maxOnset = testNoteArray(i).onset + 0.0375;
                if (noteArray(j).onset > minOnset & noteArray(j).onset < maxOnset)
                    truePositive = truePositive + 1;
                    falseNegative = falseNegative - 1;
                    break
                end
            end
            
            %If this line is reached, it means no positives were found for
            %this true note, meaning that this is a false negative (i.e. no
            %note has been detected when there should have been).
            falseNegative = falseNegative + 1;
        end
    end
    
    result = truePositive/(truePositive + falseNegative);