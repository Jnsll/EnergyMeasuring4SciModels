
data = readmatrix('cumcm2012B附件4_山西大同典型气象年逐时参数及各方向辐射强度.xls','Range','B3');
data1 = data(:,end - 3:end);%东南西北的辐射数据
data2 = data1;
data2(data2 < 30) = 0;

he = sum(data2);
mpower = he ./ 1000;

%每平米一年的发电量
power = mpower * (10 + 15 * 0.9 + 10 * 0.8);

%每平米35年的发电量 没有加入逆变效率
price = power * 0.5;

% 每平米的面积35年的经济效益  没有加入转换率
data3 = readmatrix('cumcm2012B_附件3_三种类型的光伏电池(A单晶硅B多晶硅C非晶硅薄膜)组件设计参数和市场价格.xls','Range','C2');

pice = 4.8;
long = data3(:,2);%长
wide = data3(:,3);%宽
U = data3(:,4);%电压
I = data3(:,5);%电流
eta = data3(:,6);%转换率
P = U .* I;
S = long .* wide / 1000000;
price1 = pice .* P;%每块电池的价格

lr = price .* S .* eta - price1;

clr = lr(14:24,:);
% c类电池每块安装在四面墙上的35年利润
