function res = chap11_14_humanOptimized
%【例11 - 14】
I = imread('leaf1.bmp');                     %读入图像 　　
I = im2bw(I);                              %#ok<IM2BW> %转换为二值图像
Ar = regionprops(I,'Area');                  %求C的面积
Ce = regionprops(I,'Centroid');              %求C的重心


res.Ar = Ar;
res.Ce = Ce;
res.I = I;
end
