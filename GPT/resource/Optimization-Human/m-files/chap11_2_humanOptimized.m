close all;							%�رյ�ǰ����ͼ�δ��ڣ���չ����ռ��������������ռ����б���

[I, Ravg1, Gavg1, Bavg1, Rstd1, Gstd1, Bstd1] = helpFun('hua.jpg');
[J, Ravg2, Gavg2, Bavg2, Rstd2, Gstd2, Bstd2] = helpFun('yezi.jpg');

set(0,'defaultFigurePosition',[100,100,1000,500]);  %�޸�ͼ��ͼ��λ�õ�Ĭ������
set(0,'defaultFigureColor',[1,1,1])

K = imread('flower1.jpg');

figure;
subplot(131)
imshow(K); %��ʾԭͼ��
subplot(132)
imshow(I);                         %��ʾ����ͼ��
subplot(133)
imshow(J);                         %��ʾҶ�ӵ�ͼ��

function [I, Ravg1, Gavg1, Bavg1, Rstd1, Gstd1, Bstd1] = helpFun(name)
I = imread(name);                         %IΪ���Ĳ�ɫͼ���������󻨵�ͼ���RGB������ֵ
R = I(:,:,1);                                  %��ɫ����
G = I(:,:,2);                                  %��ɫ����
B = I(:,:,3);                                   %��ɫ����
R = double(R);
G = double(G);
B = double(B);     %����double()��������������תΪdouble��
Ravg1 = mean2(R);                           %��ɫ������ֵ
Gavg1 = mean2(G);                           %��ɫ������ֵ
Bavg1 = mean2(B);                            %��ɫ������ֵ
Rstd1 = std(std(R));			                %��ɫ�����ķ���
Gstd1 = std(std(G));		             	       %��ɫ�����ķ���
Bstd1 = std(std(B));			                 %��ɫ�����ķ���
end