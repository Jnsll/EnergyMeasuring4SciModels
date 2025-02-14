%% Theme-analysis-script

load SortedThemes.mat dict2;
load LLMThemeAnalysis.mat dict;

%% create unique themes

% fullPath = fullfile('..','Optimization-Human','reasoning.csv');
% splitStr = newline;
% field = 'Themes';

fileName = 'Detailed_OptimizedMatlabScripts_reasonings.csv';

LLM_Name = 'gpt-3';
% LLM_Name = 'gpt-4';
% LLM_Name = 'llama';
% LLM_Name = 'mixtral';

fullPath = fullfile(LLM_Name,fileName);

splitStr = ', ';
field = 'Theme_Human';

data = readtable(fullPath);
% data = data(IDX,:); % only for LLM optimization
themes = string(data.(field));
themes = arrayfun(@(arg)split(arg,splitStr),themes,'UniformOutput',false);
% themes = cellfun(@(arg)dict(arg),themes,'UniformOutput',false); % only for human optimized themes
themes = cellfun(@unique,themes,'UniformOutput',false);
themes = cellfun(@transpose,themes,'UniformOutput',false);
themes = [themes{:}]';
themes(themes == "nan") = "No Manual Inspection";
themes(themes == "") = [];
sortedThemes = sort(themes);
sortedThemesNumeric = dict2(sortedThemes);

%%

sortedThemesHumanOptimized = sortedThemes;
sortedThemesNumericHumanOptimized = dict2(sortedThemesHumanOptimized);

sortedThemesGpt3 = sortedThemes;
sortedThemesNumericGpt3 = dict2(sortedThemesGpt3);

sortedThemesGpt4 = sortedThemes;
sortedThemesNumericGpt4 = dict2(sortedThemesGpt4);

sortedThemesLlama = sortedThemes;
sortedThemesNumericLlama4 = dict2(sortedThemesLlama);

sortedThemesMixtral = sortedThemes;
sortedThemesNumericMixtral = dict2(sortedThemesMixtral);

%% work on themes

themes = load("LLMThemeAnalysis.mat").themes;
mapping = strings(numel(themes),2);
mapping(:,1) = themes;

%% work on mapping

mapping = load("LLMThemeAnalysis.mat").mapping;
dict = dictionary(mapping(:,1),mapping(:,2));

%% extract themes from csv file human

data = readtable(fullfile('..','Optimization-Human','reasoning.csv'));
rawThemes = load("LLMThemeAnalysis.mat").rawThemes;

mappedThemesHuman = arrayfun(@(arg)dict(arg),rawThemes);
[uniqueMappedThemes,~,IDX] = unique(mappedThemesHuman);
origFile = data.OriginalScriptPath;

%% extract themes from csv file gpt3

fileName = 'Detailed_OptimizedMatlabScripts_reasonings.csv';
dataLLM = readtable(fullfile('gpt-3',fileName));
themesHuman = dataLLM.Theme_Human;
themesHuman = arrayfun(@(arg)string(split(arg,', ')),themesHuman,'UniformOutput',false);
origFile2 = dataLLM.OriginalScriptPath;
[~,~,IDX] = intersect(origFile,origFile2);

themesHuman = themesHuman(IDX);

%%
 
load SortedThemes.mat
load SortedThemes.mat dict2;
load SortedThemesAllFiles.mat

dataGpt3 = sortedThemesNumericAllFilesGpt3;
dataGpt4 = sortedThemesNumericAllFilesGpt4;
dataLlama = sortedThemesNumericAllFilesLlama;
dataMixtral = sortedThemesNumericAllFilesMixtral;

n = dict2.numEntries;

%%

dataHuman = makeData(sortedThemesNumericHumanOptimized,n);
dataGpt3 = makeData(dataGpt3,n);
dataGpt4 = makeData(dataGpt4,n);
dataLlama = makeData(dataLlama,n);
dataMixtral = makeData(dataMixtral,n);

%%

function data = makeData(sortedThemesNumericGpt3,n)
data = arrayfun(@(arg)sum(sortedThemesNumericGpt3 == arg),1:n);
end
