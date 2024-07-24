function res = getVocabList()
%GETVOCABLIST reads the fixed vocabulary list in vocab.txt and returns a
%cell array of the words
%   vocabList = GETVOCABLIST() reads the fixed vocabulary list in vocab.txt 
%   and returns a cell array of the words in vocabList.


%% Read the fixed vocabulary list
fid = fopen('vocab.txt');

% For ease of implementation, we use a struct to map the strings => integers
% In practice, you'll want to use some form of hashmap

res = readlines('vocab.txt');
res = regexpi(res,'[a-z]*','match','once');
res = res(1:end-1);
res = convertStringsToChars(res);

fclose(fid);

end
