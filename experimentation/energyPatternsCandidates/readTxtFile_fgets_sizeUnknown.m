function movieList = readTxtFile_fgets_sizeUnknown()

for count = 1:100
    fid = fopen('readTxtFile_movie_ids.txt');

    idx = 1;
    line = fgets(fid);
    while ~isequal(line,-1)
        movieList{idx,1} = strtrim(line); %#ok<AGROW>
        idx = idx + 1;
        % Read line
        line = fgets(fid);
    end
    fclose(fid);

end
end
