
close all;							%�رյ�ǰ����ͼ�δ��ڣ���չ����ռ��������������ռ����б���
J = imread('huangguahua.jpg');				%����Ҫ�����ͼ�񣬲���ֵ��J
hsv = rgb2hsv(J);                   %ͼ����RGB�ռ�任��HSV�ռ�
h = hsv(:, :, 1);                     %Ϊɫ��h��ֵ
s = hsv(:, :, 2);                     %Ϊ���Ͷ�s��ֵ
v = hsv(:, :, 3);                     %Ϊ����v��ֵ

set(0,'defaultFigurePosition',[100,100,1000,500]);	%�޸�ͼ��ͼ��λ�õ�Ĭ������
set(0,'defaultFigureColor',[1,1,1])

helpFun(J, h);
helpFun(s, v);

figure;
subplot(131);
imhist(h); 	      	%��ʾɫ��h��ֱ��ͼ
subplot(132);
imhist(s);              %��ʾ���Ͷ�s��ֱ��ͼ
subplot(133);
imhist(v);              %��ʾ����v��ͼ

function helpFun(im1, im2)
figure;
subplot(121);
imshow(im1);                           %��ʾԭͼ
subplot(122);
imshow(im2);         %����ɫ��h�ĻҶ�ͼ��
end