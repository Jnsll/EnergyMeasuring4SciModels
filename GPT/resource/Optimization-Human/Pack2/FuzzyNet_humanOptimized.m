rng("default")

%% 参数初始化
xite = 0.001;
alfa = 0.05;

%网络节点
I = 6;   %输入节点数
M = 12;  %隐含节点数
O = 1;   %输出节点数

%系数初始化
onesArray = 0.3 * ones(M,1);
p0 = onesArray;
p0_1 = onesArray;
p0_2 = onesArray;
p1 = onesArray;
p1_1 = onesArray;
p1_2 = onesArray;
p2 = onesArray;
p2_1 = onesArray;
p2_2 = onesArray;
p3 = onesArray;
p3_1 = onesArray;
p3_2 = onesArray;
p4 = onesArray;
p4_1 = onesArray;
p4_2 = onesArray;
p5 = onesArray;
p5_1 = onesArray;
p5_2 = onesArray;
p6 = onesArray;
p6_1 = onesArray;
p6_2 = onesArray;

%参数初始化
[c, c_1, c_2] = helpFun(M, I);
[b, b_1, b_2] = helpFun(M, I);

maxgen = 100; %进化次数

%网络测试数据，并对数据归一化
load data1 input_train output_train input_test output_test

%选连样本输入输出数据归一化
[inputn,inputps] = mapminmax(input_train);
[outputn,outputps] = mapminmax(output_train);

m = size(input_train,2);

%% 网络训练
%循环开始，进化网络
for iii = maxgen:-1:1
    for k = m:-1:1
        x = inputn(:,k);
        [addw,addyw,yn(k),w,yi] = insideForLoop(I,inputn(:,k),b,c,p0_1,p1_1,p2_1,p3_1,p4_1,p5_1,p6_1);



        e(k) = outputn(k) - yn(k);
        
        %计算p的变化值
        d_p = xite * e(k) * w ./ addw;
        d_p = d_p';
        
        %计算b变化值
        d_b = zeros(size(b_1));
        for i = 1:M
            factor1 = xite * e(k) * (yi(i) * addw - addyw) * w(i) / addw^2;
            factor2 = (x(:) - c(i,:)') ./ b(i,:)';
            d_b(i,:) = factor1 *     factor2.^2;
            d_c(i,:) = factor1 * 2 * factor2;
        end
        
        [p0,p0_1,p0_2] = helpFun2(p0_1,d_p,1,alfa,p0_2);
        [p1,p1_1,p1_2] = helpFun2(p1_1,d_p,x(1),alfa,p1_2);
        [p2,p2_1,p2_2] = helpFun2(p2_1,d_p,x(2),alfa,p2_2);
        [p3,p3_1,p3_2] = helpFun2(p3_1,d_p,x(3),alfa,p3_2);
        [p4,p4_1,p4_2] = helpFun2(p4_1,d_p,x(4),alfa,p4_2);
        [p5,p5_1,p5_2] = helpFun2(p5_1,d_p,x(5),alfa,p5_2);
        [p6,p6_1,p6_2] = helpFun2(p6_1,d_p,x(6),alfa,p6_2);
            
        [b,b_1,b_2] = helpFun2(b_1,d_b,1,alfa,b_2);
        [c,c_1,c_2] = helpFun2(c_1,d_c,1,alfa,c_2);
    end   
end

%% 网络预测

load  data2 hgsc gjhy dxg

[x, test_simu] = forLoop(input_test, inputps, x, I, b, c, p0_1, p1_1, p2_1, p3_1, p4_1, p5_1, p6_1, outputps);
[x, szzbz1] = forLoop(hgsc, inputps, x, I, b, c, p0_1, p1_1, p2_1, p3_1, p4_1, p5_1, p6_1, outputps);
[x, szzbz2] = forLoop(gjhy, inputps, x, I, b, c, p0_1, p1_1, p2_1, p3_1, p4_1, p5_1, p6_1, outputps);
[x, szzbz3] = forLoop(dxg, inputps, x, I, b, c, p0_1, p1_1, p2_1, p3_1, p4_1, p5_1, p6_1, outputps);

figure(1);
plot(outputn,'r')
hold on
plot(yn,'b')
plot(outputn - yn,'g');
helpFun3('训练数据预测');

figure(2)
plot(output_test,'r')
hold on
plot(test_simu,'b')
plot(test_simu - output_test,'g')
helpFun3('测试数据预测');

figure(3)
plot(szzbz1,'o-r')
hold on
plot(szzbz2,'*-g')
plot(szzbz3,'*:b')

xlabel('时间','fontsize',12)
ylabel('预测水质','fontsize',12)
legend('红工水厂','高家花园水厂','大溪沟水厂','fontsize',12)

function [var, var_1, var_2] = helpFun(M, I)
var = 1 + rands(M,I);
var_1 = var;
var_2 = var;
end

function [pn,pn_1,pn_2] = helpFun2(pn_1,d_p,fact,alfa,pn_2)
pn = pn_1 + d_p * fact + alfa * (pn_1 - pn_2);
pn_2 = pn_1;
pn_1 = pn;
end

function helpFun3(newTitle)
legend('实际输出','预测输出','误差','fontsize',12)
title('训练数据预测','fontsize',12)
xlabel(newTitle,'fontsize',12)
ylabel('水质等级','fontsize',12)
end

function [addw,addyw,helpVar,w,yi] = insideForLoop(I,x,b,c,p0_1,p1_1,p2_1,p3_1,p4_1,p5_1,p6_1)
u = helpFun5(I,x,b,c);
w = multiProd(u);
addw = sum(w);
yi = helpFun4(p0_1,p1_1,p2_1,p3_1,p4_1,p5_1,p6_1,x);
addyw = yi * w';
helpVar = addyw / addw;
end

function u = helpFun5(I,x,b,c)
for i = I:-1:1
    u(i,:) = exp(-(x(i) - c(:,i)).^2 ./ b(:,i));
end
end

function [x, szzbz3] = forLoop(zssz, inputps, x, I, b, c, p0_1, p1_1, p2_1, p3_1, p4_1, p5_1, p6_1, outputps)
inputn_test = mapminmax('apply',zssz,inputps);
m = size(zssz,2);

szzb = zeros(1,m);
for k = 1:m
    x = inputn_test(:,k);
    [~,~,szzb(k)] = insideForLoop(I,x,b,c,p0_1,p1_1,p2_1,p3_1,p4_1,p5_1,p6_1);
end
szzbz3 = mapminmax('reverse',szzb,outputps);
end

function w = multiProd(u)
w = u(1,:) .* u(2,:) .* u(3,:) .* u(4,:) .* u(5,:) .* u(6,:);
end

function yi = helpFun4(p0_1,p1_1,p2_1,p3_1,p4_1,p5_1,p6_1,x)
yi(:) = p0_1(:) + p1_1(:) .* x(1) + p2_1(:) .* x(2) + p3_1(:) .* x(3) + p4_1(:) .* x(4) + p5_1(:) .* x(5) + p6_1(:) .* x(6);
end