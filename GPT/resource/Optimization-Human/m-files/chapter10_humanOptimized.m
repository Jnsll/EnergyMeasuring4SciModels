%% 导入数据
load class.mat class_1 class_2 class_3 class_4 class_5

%% 目标向量
T = [class_1,class_2,class_3,class_4,class_5];

%% 创建网络
net = newhop(T);

%% 导入待分类样本
load sim.mat sim_1 sim_2 sim_3 sim_4 sim_5

A = {[sim_1,sim_2,sim_3,sim_4,sim_5]};

%% 网络仿真
Y = sim(net,{25,20},{},A);

%% 结果显示
Y1 = Y{20}(:,1:5);
Y2 = Y{20}(:,6:10);
Y3 = Y{20}(:,11:15);
Y4 = Y{20}(:,16:20);
Y5 = Y{20}(:,21:25);

%% 绘图
result = {T;A{1};Y{20}};

figure

m = 11;
for p = 1:3
    resultP = result{p};
    switch p
        case 1
            titleStart = 'class';
        case 2
            titleStart = 'pre-sim';
        otherwise
            titleStart = 'sim';
    end

    baseIndent = (p - 1) * 5;
    for k = 1:5 
        subplot(3,5,baseIndent + k)
        hold on
        
        temp = resultP(:,(k - 1) * 5 + 1:k * 5);
        for i = 1:m
            for j = 1:5
                if temp(i,j) > 0
                   plot(j,m - i,'ko','MarkerFaceColor','k');
                else
                   plot(j,m - i,'ko');
                end
            end
        end
        axis([0,6,0,12])
        axis off

        title([titleStart,num2str(k)])
    end                
end

noisy = [1,-1,-1,-1,-1;-1,-1,-1,1,-1;
    -1,1,-1,-1,-1;-1,1,-1,-1,-1;
    1,-1,-1,-1,-1;-1,-1,1,-1,-1;
    -1,-1,-1,1,-1;-1,-1,-1,-1,1;
    -1,1,-1,-1,-1;-1,-1,-1,1,-1;
    -1,-1,1,-1,-1];

y = sim(net,{5,100},{},{noisy});
a = y{100};
