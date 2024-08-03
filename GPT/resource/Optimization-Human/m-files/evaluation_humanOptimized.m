
% load data
% load('../ results / LightenedCNN_A_lfw.mat');      % model A
% load('../ results / LightenedCNN_B_lfw.mat');      % model B
features = load(fullfile('..','results','LightenedCNN_C_lfw.mat')).features;      % model C
lfwPairs = load('lfw_pairs.mat');
pos_pair = lfwPairs.pos_pair;
neg_pair = lfwPairs.neg_pair;

% pos
[pos_scores, pos_label] = helpFun(pos_pair, features, 1);

%neg
[neg_scores, neg_label] = helpFun(neg_pair, features,-1);

scores = [pos_scores, neg_scores];
label = [pos_label,neg_label];

% ap
ap = evaluation.evaluate('ap', scores, label);

% roc
roc = evaluation.evaluate('roc', scores, label);


%% output
fprintf('ap:           %f\n', ap.measure);
fprintf('eer:          %f\n', roc.measure);
fprintf('tpr001:       %f\n', roc.extra.tpr001 * 100);
fprintf('tpr0001:      %f\n', roc.extra.tpr0001 * 100);
fprintf('tpr00001:     %f\n', roc.extra.tpr00001 * 100);
fprintf('tpr000001:    %f\n', roc.extra.tpr000001 * 100);
fprintf('tpr0:         %f\n', roc.extra.tpr0 * 100);
result = [ap.measure / 100,roc.measure / 100,roc.extra.tpr001,roc.extra.tpr0001,roc.extra.tpr00001,roc.extra.tpr000001,roc.extra.tpr0];

function [scores, label] = helpFun(pair, features, direction)
length_pair = length(pair);
for i = length_pair:-1:1
    feat1 = features(pair(1, i), :)';
    feat2 = features(pair(2, i), :)';
    scores(i) = distance.compute_cosine_score(feat1, feat2);
end
label = direction * ones(1, length_pair);
end