%% 清除环境变量
rng("default")

%% 人脸特征向量提取 
% 人数
M = 10;
% 人脸朝向类别数
N = 5; 
% 特征向量提取
pixel_value = feature_extraction(M,N);

%% 训练集 / 测试集产生
% 产生图像序号的随机序列
rand_label = randperm(M * N);  
% 人脸朝向标号
direction_label = repmat(1:N,1,M);

% 训练集
IDX = 1:30;
[train_label, P_train, Tc_train] = helpFun(rand_label, IDX, pixel_value, direction_label);

% 测试集
IDX = 31:numel(rand_label);
[test_label, P_test, Tc_test] = helpFun(rand_label, IDX, pixel_value, direction_label);

%% 计算PC
for i = 5:-1:1
    rate{i} = length(find(Tc_train == i)) / 30;
end

%% LVQ1算法
[w1,w2] = lvq1_train(P_train,Tc_train,20,cell2mat(rate),0.01,5);
result_1 = lvq_predict(P_test,Tc_test,20,w1,w2);

%% LVQ2算法
[w1,w2] = lvq2_train(P_train,Tc_train,20,0.01,5,w1,w2);
result_2 = lvq_predict(P_test,Tc_test,20,w1,w2);

function [t_label, P_t, Tc_t] = helpFun(rand_label, IDX, pixel_value, direction_label)
t_label = rand_label(IDX);
P_t = pixel_value(t_label,:)';
Tc_t = direction_label(t_label);
end