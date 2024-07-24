%% LVQ神经网络的预测——人脸识别
%
% <html>
% <table border ="0" width ="600px" id ="table1">	<tr>		<td><b><font size ="2">该案例作者申明：</ font></ b></ td>	</ tr>	<tr>		<td><span class ="comment"><font size ="2">1：本人长期驻扎在此<a target ="_blank" href ="http:// www.ilovematlab.cn / forum - 158 - 1.html"><font color ="#0000FF">板块</ font></ a>里，对<a target ="_blank" href ="http:// www.ilovematlab.cn / thread - 49221 - 1 - 1.html"><font color ="#0000FF">该案例</ font></ a>提问，做到有问必答。</ font></ span></ td></ tr><tr>	<td><span class ="comment"><font size ="2">2：此案例有配套的教学视频，配套的完整可运行Matlab程序。</ font></ span></ td>	</ tr>	<tr>		<td><span class ="comment"><font size ="2">		3：以下内容为该案例的部分内容（约占该案例完整内容的1 / 10）。</ font></ span></ td>	</ tr>		<tr>		<td><span class ="comment"><font size ="2">		4：此案例为原创案例，转载请注明出处（<a target ="_blank" href ="http:// www.ilovematlab.cn /">Matlab中文论坛</ a>，<a target ="_blank" href ="http:// www.ilovematlab.cn / forum - 158 - 1.html">《Matlab神经网络30个案例分析》</ a>）。</ font></ span></ td>	</ tr>		<tr>		<td><span class ="comment"><font size ="2">		5：若此案例碰巧与您的研究有关联，我们欢迎您提意见，要求等，我们考虑后可以加在案例里。</ font></ span></ td>	</ tr>		<tr>		<td><span class ="comment"><font size ="2">		6：您看到的以下内容为初稿，书籍的实际内容可能有少许出入，以书籍实际发行内容为准。</ font></ span></ td>	</ tr><tr>		<td><span class ="comment"><font size ="2">		7：此书其他常见问题、预定方式等，<a target ="_blank" href ="http:// www.ilovematlab.cn / thread - 47939 - 1 - 1.html">请点击这里</ a>。</ font></ span></ td>	</ tr></ table>
% </ html>
%
function res = crossvalind_lvq_humanOptimized
%% 清除环境变量

%% 人脸特征向量提取 

% 人数
M = 10;

% 人脸朝向类别数
N = 5; 
const1 = 5;

% 特征向量提取
pixel_value = feature_extraction(M,N);

%% 训练集 / 测试集产生
% 产生图像序号的随机序列
rng('default')
rand_label = randperm(M * N);  

% 人脸朝向标号
direction_label = repmat(1:N,1,M);

% 训练集
train_label = rand_label(1:30);
P_train = pixel_value(train_label,:)';
Tc_train = direction_label(train_label);
T_train = ind2vec(Tc_train);

% 测试集
test_label = rand_label(31:end);
P_test = pixel_value(test_label,:)';
Tc_test = direction_label(test_label);

%% K - fold交叉验证确定最佳神经元个数
k_fold = 10;
Indices = crossvalind('Kfold',size(P_train,2),k_fold);
error_min = 1e11;
best_number = 1;
best_input = [];
best_output = [];
best_train_set_index = [];
best_validation_set_index = [];
h = waitbar(0,'正在寻找最佳神经元个数.....');

for i = 1:k_fold
    % 验证集标号
    validation_set_index = (Indices == i);

    % 训练集标号
    train_set_index =~validation_set_index;

    % 验证集
    validation_set_input = P_train(:,validation_set_index);
    validation_set_output = T_train(:,validation_set_index);

    % 训练集
    train_set_input = P_train(:,train_set_index);
    train_set_output = T_train(:,train_set_index);

    for number = 10:30
        net = helpFun(Tc_train, train_set_index, train_set_input, number, train_set_output,10);

        waitbar(((i - 1) * 21 + number) / 219,h);

        %% 仿真测试
        T_sim = sim(net,validation_set_input);
        Tc_sim = vec2ind(T_sim);
        error = length(find(Tc_sim ~= Tc_train(:,validation_set_index)));
        if error<error_min
            error_min = error;
            best_number = number;
            best_input = train_set_input;
            best_output = train_set_output;
            best_train_set_index = train_set_index;
            best_validation_set_index = validation_set_index;
        end
    end
end
disp(['经过交叉验证，得到的最佳神经元个数为：' num2str(best_number)]);
close(h);

%% 创建LVQ网络
net = helpFun(Tc_train, best_train_set_index, best_input, best_number, best_output,[]);

%% 人脸识别测试
T_sim = sim(net,P_test);
Tc_sim = vec2ind(T_sim);
result = [Tc_test;Tc_sim];

%% 结果显示
% 训练集人脸标号
label = train_label(best_train_set_index);
[strain_label, htrain_label, dtrain_label] = helpFun2(label, N);

% 显示训练集图像序号
disp('训练集图像为：' );

maxIdx = length(find(best_train_set_index == 1));
forLoop2(maxIdx, htrain_label, dtrain_label,const1)

%%
% 验证集人脸标号
label = train_label(best_validation_set_index);
[svalidation_label, hvalidation_label, dvalidation_label] = helpFun2(label, N);

% 显示验证集图像序号
fprintf('\n');
disp('验证集图像为：' );

maxIdx = length(find(best_validation_set_index == 1));
forLoop2(maxIdx, hvalidation_label, dvalidation_label,const1)

%%
% 测试集人脸标号
[stest_label, htest_label, dtest_label] = helpFun2(test_label, N);

% 显示测试集图像序号
fprintf('\n');
disp('测试集图像为：');

maxIdx = 20;
forLoop2(maxIdx, htest_label, dtest_label,const1)

%%
% 显示识别出错图像
error = Tc_sim - Tc_test;
location = {'左方' '左前方' '前方' '右前方' '右方'};
for i = 1:length(error)
    if error(i) ~= 0
        % 识别出错图像人脸标号
        herror_label = ceil(test_label(i) / N);

        % 识别出错图像人脸朝向标号
        derror_label = test_label(i) - floor(test_label(i) / N) * N;
        derror_label(derror_label == 0) = N;

        % 图像原始朝向
        standard = location{Tc_test(i)};

        % 图像识别结果朝向
        identify = location{Tc_sim(i)};
        str_err = strcat(['图像' num2str(herror_label) '_'...
                        num2str(derror_label) '识别出错.']);
        disp([str_err '(正确结果：朝向' standard...
                      '；识别结果：朝向' identify ')']);
    end
end
% 显示识别率
disp(['识别率为：' num2str(length(find(error == 0)) / 20 * 100) '%']);

%%
% 
% <html>
% <table align ="center" >	<tr>		<td align ="center"><font size ="2">版权所有：</ font><a
% href ="http:// www.ilovematlab.cn /">Matlab中文论坛</ a>&nbsp;&nbsp; <script
% src ="http:// s3.cnzz.com / stat.php?id = 971931&web_id = 971931&show = pic" language ="JavaScript" ></ script>&nbsp;</ td>	</ tr></ table>
% </ html>
% 

res.best_number = best_number;
res.net = net;
res.T_sim = T_sim;
res.Tc_sim = Tc_sim;
res.result = result;
res.strain_label = strain_label;
res.htrain_label = htrain_label;
res.dtrain_label = dtrain_label;
res.svalidation_label = svalidation_label;
res.hvalidation_label = hvalidation_label;
res.dvalidation_label = dvalidation_label;
res.stest_label = stest_label;
res.htest_label = htest_label;
res.dtest_label = dtest_label;
end

function forLoop2(maxIdx, h_label, d_label,const1)
for i = 1:maxIdx
    str = [num2str(h_label(i)) '_'...
        num2str(d_label(i)) '  '];
    fprintf('%s',str)
    if mod(i,const1) == 0
        fprintf('\n');
    end
end
end

function net = helpFun(Tc_train, best_train_set_index, best_input, best_number, best_output,show)
for i = 5:-1:1
    rate(i) = length(find(Tc_train(:,best_train_set_index) == i)) / length(find(best_train_set_index == 1));
end
net = newlvq(minmax(best_input),best_number,rate,0.01);

% 设置训练参数
net.trainParam.epochs = 100;
if ~isempty(show)
    net.trainParam.show = show;
end
net.trainParam.goal = 0.001;
net.trainParam.lr = 0.1;

%% 训练网络
net = train(net,best_input,best_output);
end

function [s_label, h_label, d_label] = helpFun2(label, N)
s_label = sort(label);
h_label = ceil(s_label / N);

% 验证集人脸朝向标号
d_label = s_label - floor(s_label / N) * N;
d_label(d_label == 0) = N;
end
