%%  清空环境变量
function res = main_humanOptimized
warning off             % 关闭报警信息
close all               % 关闭开启的图窗

%%  导入数据
res = readmatrix('数据集.xlsx');

%%  划分训练集和测试集
rng("default")
temp = randperm(103);

IDX = 1: 80;
[P_train, T_train, M] = helpFun(res, temp, IDX);

IDX = 81:numel(temp);
[P_test, T_test, N] = helpFun(res, temp, IDX);

%%  数据归一化
[p_train, p_test,~] = helpFun2(P_train, P_test);
[t_train, t_test,ps_output] = helpFun2(T_train, T_test);

%%  创建模型
c = 4.0;    % 惩罚因子
g = 0.8;    % 径向基函数参数
cmd = [' -t 2',' -c ',num2str(c),' -g ',num2str(g),' -s 3 -p 0.01'];
model = svmtrain(t_train, p_train, cmd); %#ok<SVMTRAIN> uses mex-function svmtrain

%%  仿真预测
[T_sim1, error1] = helpFun3(t_train, p_train, model, ps_output, T_train, M);
[T_sim2, error2] = helpFun3(t_test, p_test, model, ps_output, T_test, N);

%%  绘图
plotFun(M, T_train, T_sim1, error1,'训练集预测结果对比');
plotFun(N, T_test, T_sim2, error2,'测试集预测结果对比');

%%  相关指标计算
% R2
[mae1, mbe1] = helpFun4(T_train, T_sim1, '训练集数据的R2为：', M, '训练集数据的MAE为：', '训练集数据的MBE为：');
[mae2, mbe2] = helpFun4(T_test, T_sim2, '测试集数据的R2为：', N, '测试集数据的MAE为：', '测试集数据的MBE为：');

%%  绘制散点图
sz = 25;
c = 'b';

plotFun2(T_train, T_sim1, sz, c, '训练集真实值', '训练集预测值');
plotFun2(T_test, T_sim2, sz, c, '测试集真实值', '测试集预测值');

%%
output.error1 = error1;
output.error2 = error2;
output.T_train = T_train;
output.T_sim1 = T_sim1;
output.T_test = T_test;
output.T_sim2 = T_sim2;
output.mae1 = mae1;
output.mae2 = mae2;
output.mbe1 = mbe1;
output.mbe2 = mbe2;

res = output;
end

function [P_t, T_t, M] = helpFun(res, temp, IDX)
P_t = res(temp(IDX), 1: 7)';
T_t = res(temp(IDX), 8)';
M = size(P_t, 2);
end

function [value_train, value_test,ps_value] = helpFun2(VALUE_train, VALUE_test)
[value_train, ps_value] = mapminmax(VALUE_train, 0, 1);
value_test = mapminmax('apply', VALUE_test, ps_value)';
value_train = value_train';
end

function [T_sim, error1] = helpFun3(t_t, p_t, model, ps_output, T_t, M)
[t_sim, ~] = svmpredict(t_t, p_t, model);
T_sim = mapminmax('reverse', t_sim, ps_output);
error1 = sqrt(sum((T_sim' - T_t).^2) ./ M);
end

function plotFun(M, T_train, T_sim1, error1,titleStr)
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {titleStr; ['RMSE=' num2str(error1)]};
title(string)
xlim([1, M])
grid
end

function [mae, mbe] = helpFun4(T_t, T_sim1, str1, M, str2, str3)
R = 1 - norm(T_t - T_sim1')^2 / norm(T_t - mean(T_t))^2;
disp([str1, num2str(R)])
mae = sum(abs(T_sim1' - T_t)) ./ M ;
disp([str2, num2str(mae)])
mbe = sum(T_sim1' - T_t) ./ M ;
disp([str3, num2str(mbe)])
end

function plotFun2(T_t, T_sim, sz, c, str1, str2)
figure
scatter(T_t, T_sim, sz, c)
hold on
plot(xlim, ylim, '--k')
xlabel(str1);
ylabel(str2);
xlim([min(T_t),max(T_t)])
ylim([min(T_sim),max(T_sim)])
title([str2,' vs. ',str1])
end
