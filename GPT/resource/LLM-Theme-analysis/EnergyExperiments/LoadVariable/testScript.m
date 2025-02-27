%% test setup

% Turn-off wire-less!

% Close Firefox and other applications!

% Only plug to electricity (no docking-station) and dim screen!

addpath(genpath('/home/jan-andrea-bard/GitLab/general-matlab-files'))
addpath(genpath('/home/jan-andrea-bard/GitLab/matlab-tools'))
clear
numRepetitions = 30;
pauseDuration = 5;
order = [ones(1,numRepetitions),ones(1,numRepetitions) * 2];
order = order(randperm(numRepetitions * 2));
count1 = 1;
count2 = 1;
energy1Brutto = zeros(numRepetitions,1);
energy1Net = zeros(numRepetitions,1);
energy2Brutto = zeros(numRepetitions,1);
energy2Net = zeros(numRepetitions,1);
time1 = zeros(numRepetitions,1);
time2 = zeros(numRepetitions,1);

fun1 = 'loadIntoWorkspace3';
fun2 = 'loadIntoVariable3';

%% test all
for idx = 1:numRepetitions * 2
    disp("Measurement: " + idx)
    % pause
    pause(pauseDuration)
    if order(idx) == 1
        loadIntoWorkspace3 % warm up

        tic
        ticke
        loadIntoWorkspace3 % measurement
        [energy1Brutto(count1),energy1Net(count1)] = tocke;
        time1(count1) = toc;

        count1 = count1 + 1;
    elseif order(idx) == 2
        loadIntoVariable3 % warm up

        tic
        ticke
        loadIntoVariable3 % measurement
        [energy2Brutto(count2),energy2Net(count2)] = tocke;
        time2(count2) = toc;
        
        count2 = count2 + 1;
    end

    % close open matlab figures
    close all
    % clear variables
    clearExcept A B numRepetitions pauseDuration order count1 count2 energy1Brutto energy1Net energy2Brutto energy2Net time1 time2 fun1 fun2
end

date = replace(char(datetime('now')),":","_");
save(['measurement_',date,'_original.mat'])

disp '---'
disp 'Experiment done'

%% post-processing

IDX = energy1Brutto ~= 0;
energy1Net = energy1Net(IDX);
energy1Brutto = energy1Brutto(IDX);
IDX = energy2Brutto ~= 0;
energy2Net = energy2Net(IDX);
energy2Brutto = energy2Brutto(IDX);

%% standard deviations / remove outliers
nstd = 3;
std1 = std(energy1Brutto);
std2 = std(energy2Brutto);
IDX = abs(energy1Brutto - mean(energy1Brutto)) > nstd * std1;
energy1Brutto(IDX) = [];
energy1Net(IDX) = [];
time1(IDX) = [];
IDX = abs(energy2Brutto - mean(energy2Brutto)) > nstd * std2;
energy2Brutto(IDX) = [];
energy2Net(IDX) = [];
time2(IDX) = [];

%% mean values
mean1_b = mean(energy1Brutto);
mean2_b = mean(energy2Brutto);
mean1_n = mean(energy1Net);
mean2_n = mean(energy2Net);
mean1_t = mean(time1);
mean2_t = mean(time2);

%% Lilliefors-Test for normality
% if the h-value is 0 the data is normally distributed at an alpha level
alpha_lillie = 0.05;
[h1,p1] = lillietest(energy1Brutto,'Alpha',alpha_lillie);
[h2,p2] = lillietest(energy2Brutto,'Alpha',alpha_lillie);

%% Welch's t-test
% -H0: The means of energy consumption of versions A and B are equal
% -H1: The means of energy consumption of versions A and B are different
alpha_welch = 0.05;
[h_w,p_w,ci,stats] = ttest2(energy1Brutto,energy2Brutto,"Alpha",alpha_welch);

%% histograms
ax1 = axes(figure);
ax2 = axes(figure);
nbins = 17;
histogram(ax1,energy1Brutto,nbins)
histogram(ax2,energy2Brutto,nbins)

%% histograms 2
ax1 = axes(figure);
nbins = 17;
histogram(ax1,energy1Brutto,nbins)
hold on
histogram(ax1,energy2Brutto,nbins)

%% save processed data
clear ax1 ax2
save(['measurement_',date,'_processed.mat'])
