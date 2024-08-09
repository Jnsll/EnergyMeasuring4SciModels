function movieList = readTxtFile_fgets_sizeKnown()
for count = 1:100
    fid = fopen('readTxtFile_movie_ids.txt');

    n = 1682;  % Total number of movies

    movieList = cell(n, 1);
    for i = 1:n
        % Read line
        line = fgets(fid);
        % Actual Word
        movieList{i} = strtrim(line);
    end
    fclose(fid);
end
end
