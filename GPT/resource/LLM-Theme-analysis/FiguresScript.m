%% Figures Script

set(0,'defaultFigurePosition',[0.15,0.22,0.67,0.6])
set(0,'defaultFigureUnits','normalized')

load SortedThemes.mat

n = dict2.numEntries;
dataHuman = makeData(sortedThemesNumericHumanOptimized,n);
dataGpt3 = makeData(sortedThemesNumericGpt3,n);
dataGpt4 = makeData(sortedThemesNumericGpt4,n);
dataLlama = makeData(sortedThemesNumericLlama4,n);
dataMixtral = makeData(sortedThemesNumericMixtral,n);

ax = axes(figure);
b = bar(ax,[dataHuman;dataGpt3;dataGpt4;dataLlama;dataMixtral]');
legend(ax,["Human","GPT3","GPT4","Llama","Mixtral"])
title(ax,"Frequency of Themes")
ylabel(ax,"Number of Mentionings (unique per file)")
xlabel(ax,"")
xticklabels(dict2.keys)

% processing = @rgb2gray;
processing = @(x)x;
b(1).FaceColor = processing([0.0941,0.9608,0.9608]);
b(2).FaceColor = processing([0.2275,0.3255,0.7294]);
b(3).FaceColor = processing([0.7176,0.2745,1.0000]);
b(4).FaceColor = processing([0.7882,0.3373,0.1725]);
b(5).FaceColor = processing([0.9412,0.3882,0.1137]);

set(b,'edgecolor','none')
set(b,'barwidth',1)

function data = makeData(sortedThemesNumericGpt3,n)
data = arrayfun(@(arg)sum(sortedThemesNumericGpt3 == arg),1:n);
end
