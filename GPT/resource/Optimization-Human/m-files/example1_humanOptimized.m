
function res = example1_humanOptimized
rng("default")

close all
figure
hold on
fplot(@(x)x .* sin(10 * pi * x) + 2,[-1,2]);

%% 参数设置
fishnum = 50; %生成50只人工鱼
MAXGEN = 50; %最多迭代次数
try_number = 100;%最多试探次数
visual = 1; %感知距离
delta = 0.618; %拥挤度因子
step = 0.1; %步长

%% 初始化鱼群
lb_ub = [-1,2,1];
X = AF_init(fishnum,lb_ub);
LBUB = [];

for i = 1:size(lb_ub,1)
    LBUB = [LBUB;repmat(lb_ub(i,1:2),lb_ub(i,3),1)]; %#ok < AGROW >
end
newArray = -ones(1,MAXGEN);
BestY = newArray; %每步中最优的函数值
BestX = newArray; %每步中最优的自变量
besty = -100; %最优函数值
Y = AF_foodconsistence(X);

for gen = 1:MAXGEN
    for i = 1:fishnum
          %% 聚群行为
        [Xi1,Yi1] = AF_swarm(X,i,visual,step,delta,try_number,LBUB,Y); 
        
         %% 追尾行为
        [Xi2,Yi2] = AF_follow(X,i,visual,step,delta,try_number,LBUB,Y); 

        if Yi1 > Yi2
            X(:,i) = Xi1;
            Y(1,i) = Yi1;
        else
            X(:,i) = Xi2;
            Y(1,i) = Yi2;
        end
    end

    [Ymax,index] = max(Y);
    plot(X(1,index),Ymax,'.','color',[gen / MAXGEN,0,0])
    
    if Ymax > besty
        besty = Ymax;
        bestx = X(:,index);
        
        BestY(gen) = Ymax;
        [BestX(:,gen)] = X(:,index);
    else
        BestY(gen) = BestY(gen - 1);
        [BestX(:,gen)] = BestX(:,gen - 1);
    end
end

plot(bestx(1),besty,'ro','MarkerSize',100)
xlabel('x')
ylabel('y')
title('鱼群算法迭代过程中最优坐标移动')

%% 优化过程图
figure
plot(1:MAXGEN,BestY)
xlabel('迭代次数')
ylabel('优化值')
title('鱼群算法迭代过程')
disp(['最优解X：',num2str(bestx,'%1.4f')])
disp(['最优解Y：',num2str(besty,'%1.4f')])

res.BestX = BestX;
res.bestx = bestx;
res.BestY = BestY;
res.besty = besty;
end