close all

%% 数据的读入
data = readmatrix('cumcm2012B附件4_山西大同典型气象年逐时参数及各方向辐射强度.xls','range','B3');
data1 = data(:,3);%水平面总辐射强度
data2 = data(:,4);%水平面散射辐射强度
data3 = data1 - data2;%水平面上直射强度
hpi = deg2rad(40.1);%大同的纬度

%% 架空铺设
N = 365;
n = 1:N;
beta = deg2rad(38.1);%倾斜角38.1
delta = deg2rad(23.5 * sin((2 * pi * (284 + n)) / N));
omegat = zeros(1,N);
omegap = omegat;

for i = N:-1:1
    cos1 = cos(delta(i));
    sin1 = sin(delta(i));
    tan1 = tan(delta(i));
    sum1 = hpi - beta;

    omegap(i) =               acos(-tan(hpi)        * tan1);
    omegat(i) = min(omegap(i),acos(-tan(sum1) * tan1));
    Rb(i) = (cos(sum1) * cos1  * sin(omegat(i)) + deg2rad(            sin(sum1) * sin1)) ...
          / (cos(hpi)  * cos1  * sin(omegap(i)) + deg2rad(omegap(i) * sin(hpi)  * sin1));
end

data4 = zeros(N,1);

for i = n
    IDX = (1:24) + (i - 1) * 24;
    data4(IDX,1) = data3(IDX,1) .* Rb(i) + (1 + cos(beta)) .* data2(IDX,1) / 2 + (1 - cos(beta)) .* data1(IDX,1) / 8;
end

data5 = data4;
data5(data5 < 80) = 0;

%屋顶光伏电池每年每平米的总光照强度
power1 = sum(data5);

U = 33.6;
I = 8.33;  %B3的电压电流
S = 1.482 * 0.992; %B4的面积
m = 56; %光伏电池的数目

price1 = m * 12.5 * U * I; %光伏电池的费用
price2 = 45700;%逆变器SN17的费用
g1 = power1 * S * m / 1000 * 0.1598 * 0.973; %每年所发电经济效益

%% 输出结果
disp('35年总的发电量')
G = g1 * (10 + 15 * 0.9 + 10 * 0.8);

disp('经济效益')
g = g1 * 0.5;  %光伏电池每年所发发电能量的效益
price = price1 + price2; %成本费用

value = price / g;
if value > 10 && value < 25
    nian = (price - g * 10)              / (g * 0.9) + 10;
else
    nian = (price - g * (10 - 15 * 0.9)) / (g * 0.8) + 25;
end
