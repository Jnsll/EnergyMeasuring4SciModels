rng("default")

pop_size = 65;
chromosome_size = 22;
clone_size = 60;
xmin = 0;
xmax = 8;
epochs = 100;
pMutate = 0.1;
cfactor = 0.3;
pop = InitializeFun(pop_size, chromosome_size);
E_best = zeros(1,epochs);
E_ave = zeros(1,epochs);

for epoch = 1:epochs
    [X,Fit] = helpFun2(pop,xmin,xmax);

    if epoch == 1
        plotFun(1,X,Fit,@helpFun,xmin,xmax,[0,0.4470,0.7410],'k*','抗体的初始化位置分布图')
    end

    plotFun(2,X,Fit,@helpFun,xmin,xmax,'b','r*','抗体的最终位置分布图')

    [FS, Affinity] = sort(Fit, 'ascend');
    XT = X(Affinity(end - clone_size + 1: end));
    FT = FS(end - clone_size + 1: end);
    E_best(epoch) = FT(end);
    [Clone, AAS] = ReproduceFun(clone_size, cfactor, pop_size, Affinity, pop, []);
    Clone = Hypermutation(Clone, chromosome_size, pMutate);
    AF = fliplr(Affinity(end - clone_size + 1: end));
    Clone(AAS, :) = pop(AF, :);

    [~,Fit] = helpFun2(Clone, xmin, xmax);

    AAS = [0,AAS]; %#ok<AGROW>
    E_ave(epoch) = mean(Fit);

    for i = clone_size:-1:1
        [~, BBS(i)] = max(Fit(AAS(i) + 1 : AAS(i + 1)));
        BBS(i) = BBS(i) + AAS(i);
    end
    
    AF2 = fliplr(Affinity(end - clone_size + 1 : end));
    pop(AF2, :) = Clone(BBS, :);
end

fprintf('\n The optimal point is: ');
fprintf('\n x: %2.4f. f(x): %2.4f', XT(end), E_best(end));

figure(3)
grid on 
plot(E_best)
title('适应值变化趋势')
xlabel('迭代数')
ylabel('适应值')
hold on
plot(E_ave,'r')
hold off
grid on

function res = helpFun(X)
res = X + 10 * sin(X .* 5) + 9 * cos(X .* 4);
end

function [X,Fit] = helpFun2(pop,xmin,xmax)
X = DecodeFun(pop, xmin, xmax);
Fit = helpFun(X);
end

function plotFun(figNum,X,Fit,F,xmin,xmax,color,lineStyle,titleStr)
figure(figNum);
fplot(F, [xmin, xmax], 'color',color);
grid on;
hold on;
plot(X, Fit, lineStyle);
hold off;
title(titleStr);
xlabel('x');
ylabel('y');
end
