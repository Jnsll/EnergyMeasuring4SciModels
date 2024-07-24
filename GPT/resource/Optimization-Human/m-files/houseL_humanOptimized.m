function res = houseL_humanOptimized
houseD = load('-ascii','house.dat')';

[N, m] = size(houseD);

%rand('state',0); randn('state',0);
%houseD = houseD(:,randperm(m));

Napp = ceil(m * 2 / 3);
Ntest = m - Napp;

app  = houseD(:,1:Napp);
test = houseD(:,Napp + 1:end);

ns = max(houseD,[],2)';

res.N = N;
res.Napp = Napp;
res.Ntest = Ntest;
res.app = app;
res.houseD = houseD;
res.m = m;
res.ns = ns;
res.test = test;
end
