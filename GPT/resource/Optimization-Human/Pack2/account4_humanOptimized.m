close all

%% ���ݵĶ���
data = readmatrix('cumcm2012B����4_ɽ����ͬ������������ʱ���������������ǿ��.xls','range','B3');
data1 = data(:,3);%ˮƽ���ܷ���ǿ��
data2 = data(:,4);%ˮƽ��ɢ�����ǿ��
data3 = data1 - data2;%ˮƽ����ֱ��ǿ��
hpi = deg2rad(40.1);%��ͬ��γ��

%% �ܿ�����
N = 365;
n = 1:N;
beta = deg2rad(38.1);%��б��38.1
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

%�ݶ�������ÿ��ÿƽ�׵��ܹ���ǿ��
power1 = sum(data5);

U = 33.6;
I = 8.33;  %B3�ĵ�ѹ����
S = 1.482 * 0.992; %B4�����
m = 56; %�����ص���Ŀ

price1 = m * 12.5 * U * I; %�����صķ���
price2 = 45700;%�����SN17�ķ���
g1 = power1 * S * m / 1000 * 0.1598 * 0.973; %ÿ�������羭��Ч��

%% ������
disp('35���ܵķ�����')
G = g1 * (10 + 15 * 0.9 + 10 * 0.8);

disp('����Ч��')
g = g1 * 0.5;  %������ÿ����������������Ч��
price = price1 + price2; %�ɱ�����

value = price / g;
if value > 10 && value < 25
    nian = (price - g * 10)              / (g * 0.9) + 10;
else
    nian = (price - g * (10 - 15 * 0.9)) / (g * 0.8) + 25;
end
