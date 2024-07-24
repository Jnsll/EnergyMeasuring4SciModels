rng("default")


%% 训练数据预测数据提取及归一化

%下载四类语音信号
load data1 c1
load data2 c2
load data3 c3
load data4 c4

%四个特征信号矩阵合成一个矩阵
data(1:500,:) = c1(1:500,:);
data(501:1000,:) = c2(1:500,:);
data(1001:1500,:) = c3(1:500,:);
data(1501:2000,:) = c4(1:500,:);

%从1到2000间随机排序
k = rand(1,2000);
[m,n] = sort(k);

%输入输出数据
input = data(:,2:25);
output1 = data(:,1);

%把输出从1维变成4维
output = zeros(2000,4);
for idx = 1:4
    output(output1 == idx,idx) = 1;
end

%随机提取1500个样本为训练样本，500个样本为预测样本
input_train = input(n(1:1500),:)';
output_train = output(n(1:1500),:)';
input_test = input(n(1501:2000),:)';
output_test = output(n(1501:2000),:)';

%输入数据归一化
[inputn,inputps] = mapminmax(input_train);

%% 网络结构初始化
innum = 24;
midnum = 25;
outnum = 4;


%权值初始化
[w1, w1_1, w1_2] = helpFun6(midnum, innum);
[b1, b1_1, b1_2] = helpFun6(midnum, 1);
[w2, w2_1, w2_2] = helpFun6(midnum, outnum);
[b2, b2_1, b2_2] = helpFun6(outnum, 1);

%学习率
xite = 0.1;
alfa = 0.01;

%% 网络训练
for ii = 10:-1:1
    E(ii) = 0;
    for i = 1:1500

        x = inputn(:,i);

        [I,Iout,yn] = helpFun3(inputn,w1,w2,b1,b2,i,midnum);

        e = output_train(:,i) - yn;
        E(ii) = E(ii) + sum(abs(e));

        dw2 = e * Iout;
        db2 = e';

        for j = midnum:-1:1
            S = expFun(I,j);
            FI(j) = S * (1 - S);
        end

        for j = midnum:-1:1
            for k = 1:innum
                dw1(k,j) = helpFun4(FI,x(k),e,w2,j);
            end
            db1(j) = helpFun4(FI,1,e,w2,j);
        end

        [w1,w1_1,w1_2] = helpFun5(w1_1,xite,dw1,alfa,w1_2);
        [w2,w2_1,w2_2] = helpFun5(w2_1,xite,dw2,alfa,w2_2);
        [b1,b1_1,b1_2] = helpFun5(b1_1,xite,db1,alfa,b1_2);
        [b2,b2_1,b2_2] = helpFun5(b2_1,xite,db2,alfa,b2_2);
    end
end


%% 语音特征信号分类
inputn_test = mapminmax('apply',input_test,inputps);

for i = 500:-1:1
    [~,~,val] = helpFun3(inputn_test,w1,w2,b1,b2,i,midnum);
    output_fore(i) = find(val == max(val));
end

error = output_fore - output1(n(1501:2000))';



%画出预测语音种类和实际语音种类的分类图
figure(1)
plot(output_fore,'r')
hold on
plot(output1(n(1501:2000))','b')
legend('预测语音类别','实际语音类别')

%画出误差图
figure(2)
plot(error)
title('BP网络分类误差','fontsize',12)
xlabel('语音信号','fontsize',12)
ylabel('分类误差','fontsize',12)

k = zeros(1,4);
kk = k;
for i = 1:500
    if error(i) ~= 0
        k = helpFun(output_test(:,i),k);
    end
    kk = helpFun(output_test(:,i),kk);
end

function kk = helpFun(output_test,kk)
[~,c] = max(output_test);
switch c
    case 1
        kk(1) = kk(1) + 1;
    case 2
        kk(2) = kk(2) + 1;
    case 3
        kk(3) = kk(3) + 1;
    case 4
        kk(4) = kk(4) + 1;
end
end

function res = helpFun2(inputn,w1,b1,i,j)
res = inputn(:,i)' * w1(j,:)' + b1(j);
end

function [I,Iout,yn] = helpFun3(inputn,w1,w2,b1,b2,i,midnum)
for j = midnum:-1:1
    I(j) = helpFun2(inputn,w1,b1,i,j);
    Iout(j) = expFun(I,j);
end

yn = w2' * Iout' + b2;
end

function res = helpFun4(FI,x,e,w2,j)
res = FI(j) * x * (e(1) * w2(j,1) + e(2) * w2(j,2) + e(3) * w2(j,3) + e(4) * w2(j,4));
end

function [w1,w1_1,w1_2] = helpFun5(w1_1,xite,dw1,alfa,w1_2)
w1 = w1_1 + xite * dw1' + alfa * (w1_1 - w1_2);
w1_2 = w1_1;
w1_1 = w1;
end

function res = expFun(I,j)
res = 1 / (1 + exp(-I(j)));
end

function [w1, w1_1, w1_2] = helpFun6(midnum, innum)
w1 = rands(midnum,innum);
w1_1 = w1;
w1_2 = w1_1;
end