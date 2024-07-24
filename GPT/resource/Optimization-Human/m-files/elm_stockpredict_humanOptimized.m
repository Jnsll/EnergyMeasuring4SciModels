% elm_stockpredict.m

%% 清除工作空间中的变量和图形
function res = elm_stockpredict_humanOptimized
close all

%% 1.加载337期上证指数开盘价格
price = load('elm_stock').price;

rng("default")

%% 2.构造样本集
% 数据个数
n = numel(price);

% x(n) 由x(n - 1),x(n - 2),...,x(n - L)共L个数预测得到.
L = 6;

% price_n：每列为一个构造完毕的样本，共n - L个样本
price_n = zeros(L + 1, n - L);
for i = 1:n - L
    price_n(:,i) = price(i:i + L);
end

%% 划分训练、测试样本
% 将前280份数据划分为训练样本
% 后51份数据划分为测试样本

IDX = 1:280;
[trainx, trainy] = prepareData(price_n,IDX);

IDX = 281:size(price_n,2);
[testx, testy] = prepareData(price_n,IDX);

%% 创建Elman神经网络

% 包含15个神经元，训练函数为traingdx
net = elmannet(1:2,15,'traingdx');

% 设置显示级别
net.trainParam.show = 1;

% 最大迭代次数为2000次
net.trainParam.epochs = 2000;

% 误差容限，达到此误差就可以停止训练
net.trainParam.goal = 0.00001;

% 最多验证失败次数
net.trainParam.max_fail = 5;

% 对网络进行初始化
net = init(net);

%% 网络训练

%训练数据归一化
[trainx1, st1] = mapminmax(trainx);
[trainy1, st2] = mapminmax(trainy);

% 测试数据做与训练数据相同的归一化操作
testx1 = mapminmax('apply',testx,st1);

% 输入训练样本进行训练
[net,~] = train(net,trainx1,trainy1);

%% 测试。输入归一化后的数据，再对实际输出进行反归一化

% 将训练数据输入网络进行测试
train_ty = helpFun(net, trainx1, st2);

% 将测试数据输入网络进行测试
test_ty = helpFun(net, testx1, st2);

%% 显示结果
%% 1.显示训练数据的测试结果
title1 = '训练数据的测试结果';
title2 = '训练数据测试结果的残差';

mse1 = helpFun2(train_ty, trainy, title1, title2);

%% 2.显示测试数据的测试结果
title1 = '测试数据测试结果的残差';
title2 = '测试数据的测试结果';

mse2 = helpFun2(test_ty, testy, title1, title2);

%%
res.train_ty = train_ty;
res.trainy = trainy;
res.mse1 = mse1;
res.test_ty = test_ty;
res.testy = testy;
res.mse2 = mse2;
end

function [trainx, trainy] = prepareData(price_n,IDX)
trainx = price_n(1:6, IDX);
trainy = price_n(7, IDX);
end

function train_ty = helpFun(net, trainx1, st2)
train_ty1 = sim(net, trainx1);
train_ty = mapminmax('reverse', train_ty1, st2);
end

function mse1 = helpFun2(train_ty, trainy, title1, title2)
figure
x = 1:length(train_ty);

% 显示真实值
plot(x,trainy,'b-');
hold on
% 显示神经网络的输出值
plot(x,train_ty,'r--')

legend('股价真实值','Elman网络输出值')
title(title1);

% 显示残差
figure
plot(x, train_ty - trainy)
title(title2)

% 显示均方误差
mse1 = mse(train_ty - trainy);
fprintf('    mse = \n     %f\n', mse1)

% 显示相对误差
disp('    相对误差：')
fprintf('%f  ', (train_ty - trainy) ./ trainy );
fprintf('\n')
end