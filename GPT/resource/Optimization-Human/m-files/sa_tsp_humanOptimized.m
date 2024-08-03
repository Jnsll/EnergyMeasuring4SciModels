% sa_tsp.m
% 用模拟退火算法求解TSP问题

%% 清理
close all

%% 定义数据,position是2行25列的矩阵
position = [1304,2312;3639,1315;4177,2244;3712,1399;3488,1535;3326,1556;...
    3238,1229;4196,1044;4312,790;4386,570;3007,1970;2562,1756;...
    2788,1491;2381,1676;1322,695;3715,1678;3918,2179;4061,2370;...
    3394,2643;3439,3201;2935,3240;3140,3550;2545,2357;2778,2826;2360,2975]';
L = size(position,2);

% 计算邻接矩阵dist  25 * 25
dist = zeros(L);
for i = 2:L
   for j = 1:i - 1
       dist(i,j) = sqrt((position(1,i) - position(1,j)).^2 + (position(2,i) - position(2,j)).^2);
   end
end
dist = dist + dist';

%% 初始化
MAX_ITER = 2000;
MAX_M = 20;
T0 = 100;
T = [1,cumprod(ones(1,MAX_ITER - 1) * 0.97)] * T0;
rng(2);
x0 = randperm(L);

%% 
x = x0;                   % 路径变量
xx = x0;                  % 每个路径
di = tsp_len(dist, x0);   % 每个路径对应的距离
n = 1;                  % 路径计数

% 外循环
for iter = 1:MAX_ITER

    % 内循环迭代器
    % 内循环
    for m = 1:MAX_M
        % 产生新路径
        newx = tsp_new_path(x);

        % 计算距离
        oldl = tsp_len(dist,x);
        newl = tsp_len(dist,newx);
        if oldl > newl   % 如果新路径优于原路径，选择新路径作为下一状态
            [x, xx, n, di] =  helpFun(newx, xx, n, di, newl);
        else                % 如果新路径比原路径差，则执行概率操作
            tmp = rand;
            if tmp < exp(- (newl - oldl) / T(iter))
                [x, xx, n, di] = helpFun(newx, xx, n, di, newl);
            end
        end
    end                     % 内循环
end
            
%% 计算最优值
[bestd,index] = min(di);
bestx = xx(index,:);
fprintf('共选择 %d 次路径\n', n);

fprintf('最优解:\n');
disp(bestd);
fprintf('最优路线:\n');
disp(bestx);

%% 显示
% 显示路径图
figure;
plot(position(1,:), position(2,:),'o');
hold on;

for i = 1:L - 1
   plot(position(1,bestx(i:i + 1)), position(2,bestx(i:i + 1))); 
end

plot([position(1,bestx(L)),position(1,bestx(1))], [position(2,bestx(L)),position(2,bestx(1))]); 
title('TSP问题选择的最优路径');
hold off;

% 显示所选择的路径变化曲线
figure;
semilogx(1:n,di);
title('路径长度的变化曲线');

function [x, xx, n, di] = helpFun(newx, xx, n, di, newl)
x = newx;
xx(n + 1,:) = x;
di(n + 1) = newl;
n = n + 1;
end