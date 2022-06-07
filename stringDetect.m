function noteArray = stringDetect(input, Fs, noteArray)
    %POTENTIAL CAUSES OF ISSUE: Audio data is being recorded on different
    %equipment and doesn't compare to recording used for Barbancho paper, 
    %different guitar being used, bad inharmonicity coefficients from the 
    %Barbancho paper, FFT is not giving accurate enough harmonic positions,
    %not calculating inharmonic coefficient correctly. To fix, maybe try
    %deriving open string inharm coefficients from my strat and just use
    %the strat audio to see if that works? If not, likely a recording setup
    %or FFT processing/coefficient calculation issue

    %Process:
    
    %1. Generate a string-fret MIDI table that contains the MIDI value for
    %each string-fret combo.
    
    %Construct the midiToStringFret conversion. The value of each element
    %is the MIDI value at the string,fret index (note that the open note 
    %fret for each string is at 1, not 0, because of matlab indexing).
    %Assume the guitar has 22 frets.
    midiToStringFret = zeros(6,13);
    for i = 1:6
        if i == 5 || i == 6
            midiToStringFret(i,:) = [40+(i-1)*5-1:52+(i-1)*5-1];
        else
            midiToStringFret(i,:) = [40+(i-1)*5:52+(i-1)*5];
        end
    end
    
    
    %2. Generate a string-fret inharmonicity lookup table using the average
    %open string inharmonicity coefficients for the electric guitar from 
    %the Barbancho paper, as well as the equation for calculating each 
    %string-fret combo's inharmonicity coefficient
    
    %Defining inharmonicity coefficients from my calibration using a
    %stratocaster and the coefficients from barbancho's paper. My
    %strat_cal's accuracy is 0.653 and Barbancho's coefficients have 0.421
    %accuracy
    new_strat_cal_coefs = [1.1080*10.^-4; 1.5646*10.^-5; 5.6813*10^-7; 8.9632*10.^-5; 1.4110*10.^-5; -1.3497*10.^-5];
    strat_cal_coefs = [3.99822*10.^-4; -5.0594*10.^-5; 4.5293*10^-5; 9.9292*10.^-5; 5.43053*10.^-5; 9.7346*10.^-6];
    barbancho_coefs = [1.50*10.^-05; 5.02*10.^-05; 8.27*10.^-05; 5.30*10.^-05; 9.04*10.^-05; 1.56*10.^-04];
    
    stringFretToInharm = strat_cal_coefs*2.0.^([0:12]/6.0);
    
    
    for i = 1:length(noteArray)
        %3. Take the FFT of the note and use peak picking that is sectioned
        %into 10 regions centered around the even multiples of the fundamental
        %frequency to get 10 harmonic locations
        
        onset = noteArray(i).onset;
        %Get exact estimated pitch in Hz
        pitch = 440*2.^((noteArray(i).midi-69)/12);
        %Calculate FFT with 1 Hz resolution (lots of zero padding)
        onsetClip = [input((onset-.01)*Fs:(onset+.05)*Fs);zeros(2.^18-(.06*Fs)-1,1)];
        window = hamming(length(onsetClip));
        fftOnset = fft(onsetClip.*window);
%         plot(abs(fftOnset));
        %Divide fft into 10 regions where a harmonic will be in each one 
        %(except for the first region, which will contain the fundamental),
        %then find the max peak in each region and calculate the actual
        %frequency of the bin at that index. Center the regions around the
        %ideal (even multiple) frequencies of each harmonic
        harmonicArray = [];
        peakArray = [];
        for j = 1:10
            approxPitch = noteArray(i).pitch;
            minPitch = approxPitch*(j-0.5);
            minIndex = round(minPitch/Fs*length(fftOnset));
            maxIndex = minIndex + round(approxPitch/Fs*length(fftOnset));
            harmonicClip = fftOnset(minIndex:maxIndex);
%             plot(abs(harmonicClip));
            [~,peakIndex] = max(abs(harmonicClip));
            %Subtract 2 from peakIndex because we bounded it twice, once
            %when we calculated the fft and twice when we pulled a clip
            %using minIndex and maxIndex. Matlab's indexing starts at one,
            %so we have to subtract one twice to compensate when
            %calculating the actual frequency bin number. Also, add 0.5 to
            %the frequency bin number to get the frequency at the center of
            %the bin, not at the start of it
            harmonicArray(j) = (minIndex + peakIndex - 2 + 0.5)*Fs/length(fftOnset);
        end
        
        
        %4. Use these values to calculate the inharmonicity coefficient with the
        %matrix given in the Phillipines paper. Where A*x = B, solve for x.
        
        A = [1:10];
        A = [A.^4; A.^2];
        
        B = [];
        %TODO: Try using the fundamental derived in harmonicityArray, 
        %as well as the approximated fundamental from pitchDetect, 
        %to see which one performs better 
        for j = 1:10
            B(j) = (harmonicArray(j)/harmonicArray(1)).^2;
        end
        
        %Solve the matrix equation for x. x(1) contains the inharmonicity
        %coefficient
        x = A.'\B.';
        calcInharmCoef = x(1);

        
        %5. Find the strings that contain the MIDI value
        %for the given note, and only compare the inharmonicity coefficients
        %for those strings (may be able to reduce the number of possible
        %strings by only selecting strings where the previous note's fret is
        %within 6 frets of the string-fret combos of the possible strings bc 
        %being more frets away is pretty unreasonable and at that point most 
        %people would move up or down a string. Also make an exception for 
        %string-fret combos on the open string, because this is easy to play
        %no matter what fret you were on before. This would require calculating 
        %the previous string's fret before continuing to the next note's string
        %selection)
        
        %stringFretIndices is a 6x1 array of string-fret combos that have
        %pitches that match the pitch of our note. String is the index and
        %fret is the value. inharmCoefs is a 6x1 array with the
        %inharmonicity coefs of each valid string-fret combo. Index is the
        %string number. -1 is used if there is no valid string-fret combo
        %for the pitch of the given note on that string
        stringFretIndices = [];
        inharmCoefs = [];
        for j = 1:6
            [~,fretIdx] = find(noteArray(i).midi == midiToStringFret(j,:));
            if isempty(fretIdx)
                stringFretCombos(j) = -1;
                inharmCoefs(j) = -1;
            else
                stringFretCombos(j) = fretIdx;
                inharmCoefs(j) = stringFretToInharm(j,fretIdx);
            end
        end
            
        
        %6. Compare the inharmonicity coefficients of the potential string-fret
        %combos to the coefficient we calculated and select the string-fret
        %combo that is closest to our calculated coefficient. This will
        %actually do both string and fret detection at once, so we can delete
        %the fretDetect method
        
        %Find the string with the closest inharmonicity coefficient for
        %it's string-fret combo that matches our note's pitch
        [~,stringIdx] = min(abs(inharmCoefs-calcInharmCoef));
        
        %Write the string and fret values to noteArray. Remember to
        %subtract 1 to get the actual fret because of indexing starting at
        %one.
        noteArray(i).string = stringIdx;
        noteArray(i).fret = stringFretCombos(stringIdx) - 1;
    end
end