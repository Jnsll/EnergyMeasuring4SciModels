function res = loadMovieList_humanOptimized()
%GETMOVIELIST reads the fixed movie list in movie.txt and returns a
%cell array of the words
%   movieList = GETMOVIELIST() reads the fixed movie list in movie.txt 
%   and returns a cell array of the words in movieList.


%% Read the fixed movieulary list

movieList = readlines('movie_ids.txt');
movieList = convertStringsToChars(movieList(1:end-1));
movieList = strtrim(regexprep(movieList,'^\d+ *',''));

res = movieList;
end
