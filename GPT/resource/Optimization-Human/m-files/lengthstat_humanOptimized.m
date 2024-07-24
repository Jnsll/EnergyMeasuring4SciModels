function lengthstat

rng("default")

n = 850;
mat = zeros(1,n);
for i = 1:1001
    [~,temp] = lengthplot(n,1370,1500);
    mat = mat + temp;
end

mat = mat / 1000;
plot(1:n,mat)
end