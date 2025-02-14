%% Human Theme Analysis

cd C:\GitHub\EnergyMeasuring4SciModels3\GPT\resource\LLM-Theme-analysis
cd 'C:\GitLab\green-coding-project\Human Optimization'

load LLMThemeAnalysis.mat dict;
data = readtable(fullfile('..','Optimization-Human','reasoning.csv'));
themes = data.Themes;
splitThemes = cellfun(@(arg)split(arg,newline),themes,'UniformOutput',false);
mappedSplitThemes = cellfun(@(arg)unique(dict(arg)),splitThemes,'UniformOutput',false);

scriptNames = regexp(data.OriginalScriptPath,'[^/]*\.m','match','once');
[~,IDX] = sort(upper(scriptNames));
sortedScriptNames = scriptNames(IDX);
sortedSplitThemes = splitThemes(IDX);
sortedMappedThemes = mappedSplitThemes(IDX);

% files to be investigated - see file updated_averages_results_v1.xlsx
% column "Sorted according to humanThemeAnalysis.m
IDX = [2,7,11,20,26,29,31,35,39,41,47];
filesToBeInspected = sortedScriptNames(IDX);
themesToBeInspected = sortedMappedThemes(IDX);
