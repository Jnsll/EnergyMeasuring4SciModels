function res = mushroomsL_humanOptimized
mushroomsD = load('-ascii','mushrooms.dat')';

N = size(mushroomsD,1);

%rand('state',0); randn('state',0);
%abalone = abalone(:,randperm(m));

for node = 1:N
  UNI = setdiff(unique(mushroomsD(node,:)),-9999);
  for val = 1:numel(UNI)
    [~,J] = find(mushroomsD(node,:) == UNI(val));
    mushroomsD(node,J) = val;
  end
end

ns = helpFun(mushroomsD);
seul = find(ns == 1);
mushroomsD = mushroomsD(setdiff(1:N,seul),:);
m = size(mushroomsD,2);

ns = helpFun(mushroomsD);

Napp = ceil(m * 2 / 3);
Ntest = m - Napp;

app  = mushroomsD(:,1:Napp);
test = mushroomsD(:,Napp + 1:end);

res.Napp = Napp;
res.Ntest = Ntest;
res.UNI = UNI;
res.app = app;
res.mushroomsD = mushroomsD;
res.ns = ns;
res.seul = seul;
res.test = test;
end

function ns = helpFun(mushroomsD)
ns = max(mushroomsD,[],2)';
end