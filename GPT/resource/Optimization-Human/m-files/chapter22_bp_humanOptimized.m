%% BP神经网络的预测——人脸识别

%% 清除环境变量

%% 人脸特征向量提取 
% 人数
M = 10;
% 人脸朝向类别数
N = 5; 
% 特征向量提取
pixel_value = feature_extraction(M,N);

%% 训练集 / 测试集产生
% 产生图像序号的随机序列
rng("default")
rand_label = randperm(M * N);  
% 人脸朝向标号
direction_label = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1];

% 训练集
IDX = 1:30;
[train_label, P_train, dtrain_label, T_train] = helpFun(rand_label, IDX, pixel_value, N, direction_label);

% 测试集
IDX = 31:numel(rand_label);
[test_label, P_test, dtest_label, T_test] = helpFun(rand_label, IDX, pixel_value, N, direction_label);

%% 创建BP网络
net = newff(minmax(P_train),[10,3],{'tansig','purelin'},'trainlm');

% 设置训练参数
net.trainParam.epochs = 1000;
net.trainParam.show = 10;
net.trainParam.goal = 1e-3;
net.trainParam.lr = 0.1;

%% 网络训练
net = train(net,P_train,T_train);

%% 仿真测试
T_sim = sim(net,P_test);
IDX = T_sim < 0.5;
T_sim(IDX) = 0;
T_sim(~IDX) = 1;

function [t_label, P_t, dt_label, T_train] = helpFun(rand_label, IDX, pixel_value, N, direction_label)
t_label = rand_label(IDX);
P_t = pixel_value(t_label,:)';
dt_label = t_label - floor(t_label / N) * N;
dt_label(dt_label == 0) = N;
T_train = direction_label(dt_label,:)';
end
