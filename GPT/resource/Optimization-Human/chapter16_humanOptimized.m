%% 案例16：单层竞争神经网络的数据分类—患者癌症发病预测
% 

%% 清空环境变量

%% 录入输入数据
% 载入数据并将数据分成训练和预测两类
function res = chapter16_humanOptimized
rng("default")

data = load('gene.mat').gene;
P = data(1:40,:)';
T = data(41:60,:)';

% 取输入元素的最大值和最小值Q：
Q = minmax(P);

%% 网络建立和训练
% 利用newc( )命令建立竞争网络：2代表竞争层的神经元个数，也就是要分类的个数。0.1代表学习速率。
net = newc(Q,2,0.1);

% 初始化网络及设定网络参数：
net = init(net);
net.trainparam.epochs = 20;

% 训练网络：
net = train(net,P);


%% 网络的效果验证

% 将原数据回带，测试网络效果：
[a, ac] = helpFun(net, P);

% 这里使用了变换函数vec2ind()，用于将单值向量组变换成下标向量。其调用的格式为：
%  ind = vec2ind(vec);
% 其中，
% vec：为m行n列的向量矩阵x，x中的每个列向量i，除包含一个1外，其余元素均为0。
% ind：为n个元素值为1所在的行下标值构成的一个行向量。



%% 网络作分类的预测
% 下面将后20个数据带入神经网络模型中，观察网络输出：
% sim( )来做网络仿真
[Y, yc] = helpFun(net, T);

res.P = P;
res.T = T;
res.Q = Q;
res.data = data;
res.Y = Y;
res.yc = yc;
res.a = a;
res.ac = ac;
res.net = net;
end

function [val, val_c] = helpFun(net, arg)
val = sim(net,arg);
val_c = vec2ind(val);
end