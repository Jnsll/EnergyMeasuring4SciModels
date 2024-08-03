houseD = load('-ascii','house.dat')';

[N, m] = size(houseD);

%rand('state',0); randn('state',0);
%houseD = houseD(:,randperm(m));

Napp = ceil(m * 2 / 3);
Ntest = m - Napp;

app  = houseD(:,1:Napp);
test = houseD(:,Napp + 1:end);

ns = max(houseD,[],2)';
