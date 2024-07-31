%% Figures Script

warning off MATLAB:table:ModifiedAndSavedVarnames

set(0,'defaultFigurePosition',[0.15,0.2,0.67,0.6])
set(0,'defaultFigureUnits','normalized')

colorsBoldAndBasic = {'#1e2b45','#40578f','#a9c6d9','#e55f3f','#f1a845'};
% colorsGracefullyModern = {'#faac77','#c9c9bd','#f0efee','#606b6f','#333c3e'};
colorsClassicAndTrustworthy = {'#ca3542','#27647b','#849fad','#aec0c9','#57575f'};
% colorsPooja = {'#f29962','#57c8fa','#a3e3fc','#69bb88','#b4dec1'};
selectedColors = colorsClassicAndTrustworthy;
selectedColors(4:5) = colorsBoldAndBasic(4:5);
selectedColors = selectedColors([1,4,5,2,3]);

yLabel = "Number of Mentions (unique per file)";

%% plot including human optimized files

[xTickLabel, dataForPlot, legendItems] = prepareData("DataForComparisonPlot.csv");
colors = selectedColors;
titleStr = "Frequency of Themes (50 files)";

createPlot(dataForPlot, legendItems, titleStr, yLabel, xTickLabel, colors);
exportFileName = 'themes50Files.pdf';

%% plot including all files

% data = readtable("Combined_Themes_Frequency.csv");
[xTickLabel, dataForPlot, legendItems] = prepareData("DataForComparisonPlotAllFiles.csv");
colors = selectedColors(2:end);
titleStr = "Frequency of Themes (400 files)";

createPlot(dataForPlot, legendItems, titleStr, yLabel, xTickLabel, colors);
exportFileName = 'themesAllFiles.pdf';

%% export as pdf

exportgraphics(gcf,exportFileName)

%% local functions

function createPlot(dataForPlot, legendItems, ~, yLabel, xTickLabel, colors)

ax = axes(figure);
b = bar(ax,dataForPlot');
legend(ax,legendItems,'FontSize',20);
% title(ax,titleStr)
ylabel(ax,yLabel)
xlabel(ax,"")
xticklabels(xTickLabel)

% processing = @rgb2gray;
processing = @(x)x;
for idx = 1:numel(colors)
    b(idx).FaceColor = processing(hex2rgb(colors{idx}));
end

set(b,'edgecolor','none')
set(b,'barwidth',1)

ax.FontSize = 17;
ax.Title.FontSize = 36;
ax.FontName = 'Times New Roman';
ax.YGrid = 'on';

% shorten first item of tick label
ax.XTickLabel{1} = 'Improved Code R & M';
end

function [xTickLabel, dataForPlot, legendItems] = prepareData(fileName)
data = readtable(fileName);
data = data([1:11,13,14,12],:); % permute last three items so that "others" appears last
xTickLabel = data.ThemeCategory;
dataForPlot = [data.gpt3';data.gpt4';data.llama';data.mixtral'];
legendItems = ["GPT3","GPT4","Llama","Mixtral"];
if ismember('human',data.Properties.VariableNames)
    dataForPlot = [data.human';dataForPlot];
    legendItems = ["Human",legendItems];
end
end
