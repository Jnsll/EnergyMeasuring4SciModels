
data = readmatrix('cumcm2012B����4_ɽ����ͬ������������ʱ���������������ǿ��.xls','Range','B3');
data1 = data(:,end - 3:end);%���������ķ�������
data2 = data1;
data2(data2 < 30) = 0;

he = sum(data2);
mpower = he ./ 1000;

%ÿƽ��һ��ķ�����
power = mpower * (10 + 15 * 0.9 + 10 * 0.8);

%ÿƽ��35��ķ����� û�м������Ч��
price = power * 0.5;

% ÿƽ�׵����35��ľ���Ч��  û�м���ת����
data3 = readmatrix('cumcm2012B_����3_�������͵Ĺ�����(A������B�ྦྷ��C�Ǿ��象Ĥ)�����Ʋ������г��۸�.xls','Range','C2');

pice = 4.8;
long = data3(:,2);%��
wide = data3(:,3);%��
U = data3(:,4);%��ѹ
I = data3(:,5);%����
eta = data3(:,6);%ת����
P = U .* I;
S = long .* wide / 1000000;
price1 = pice .* P;%ÿ���صļ۸�

lr = price .* S .* eta - price1;

clr = lr(14:24,:);
% c����ÿ�鰲װ������ǽ�ϵ�35������
