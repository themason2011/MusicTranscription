function tabWrite(input, Fs, noteArray, tempo, outputFileName)
    numMeasures = tempo/(4*60*Fs)*length(input);
    measuresPerRow = 2;
    numRows = floor(numMeasures/measuresPerRow) + 1;
    
    result = strings(numRows*6, measuresPerRow*33 + 2);
    result(:,:) = "-";
    
    for i = 1:numRows
        for j = 1:6
            for k = 1:measuresPerRow*32
            end
        end
    end
    
    
    
    
    writematrix(result, outputFileName, 'Delimiter',';');
    delimiters_removed = strrep(fileread(outputFileName),';','');
    fid = fopen(outputFileName);
    fprintf(fid,delimiters_removed);
    fclose(fid);
end