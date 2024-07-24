%%  清空环境变量
function res = main_humanOptimized
warning off             % 关闭报警信息
close all               % 关闭开启的图窗

%%  导入数据
res = readmatrix('数据集.xlsx');

%%  划分训练集和测试集
rng("default")
temp = randperm(357);

[P_train, T_train, M] = prepareData(res, temp,1:240);
[P_test, T_test, N] = prepareData(res, temp,241:numel(temp));

%%  数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test  = mapminmax('apply', P_test, ps_input)';
t_train = ind2vec(T_train)';

%%  转置以适应模型
p_train = p_train';

%%  创建模型
[~, ~, ~, ~, betaPLS, ~, ~, ~] = plsregress(p_train, t_train, 6);
% https://blog.csdn.net/linping_/article/details/110193946

[T_sim1, T_train, error1] = processData(M, p_train, betaPLS, T_train);
[T_sim2, T_test, error2] = processData(N, p_test, betaPLS, T_test);

output.T_train = T_train;
output.T_sim1 = T_sim1;
output.T_test = T_test;
output.T_sim2 = T_sim2;
output.error1 = error1;
output.error2 = error2;
res = output;
end

function makeConfusionChart(T_train, T_sim1,type)
figure
cm = confusionchart(T_train, T_sim1);
cm.Title = ['Confusion Matrix for ',type,' Data'];
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
end

function makePlot1(M, T_train, T_sim1, error1,type)
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {type; ['准确率=' num2str(error1) '%']};
title(string)
grid
end

function errorRes = calculateError(T_sim, T_type, M)
errorRes = sum((T_sim == T_type)) / M * 100 ;
end

function [T_sim1, T_train, error1] = processData(M, p_train, betaPLS, T_train)
t_sim1 = [ones(M, 1), p_train] * betaPLS;
T_sim1 = vec2ind(t_sim1');
[T_train, index_1] = sort(T_train);
T_sim1 = T_sim1(index_1);
error1 = calculateError(T_sim1, T_train, M);
makePlot1(M, T_train, T_sim1, error1,'训练集预测结果对比');
makeConfusionChart(T_train, T_sim1,'Train');
end

function [P_train, T_train, M] = prepareData(res, temp,IDX)
P_train = res(temp(IDX), 1: 12)';
T_train = res(temp(IDX), 13)';
M = size(P_train, 2);
end