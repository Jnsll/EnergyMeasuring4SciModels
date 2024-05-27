function vocabList = getVocabList()
%GETVOCABLIST reads the fixed vocabulary list in vocab.txt and returns a
%cell array of the words
%   vocabList = GETVOCABLIST() reads the fixed vocabulary list in vocab.txt 
%   and returns a cell array of the words in vocabList.

%% Read the fixed vocabulary list
fid = fopen('vocab.txt');

if fid == -1
    error('Cannot open vocab.txt');
end

% Read the entire file content
fileContent = textscan(fid, '%d %s', 'Delimiter', '\n');
fclose(fid);

% Extract the words
vocabList = fileContent{2};

end