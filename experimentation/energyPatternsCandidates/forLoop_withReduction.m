
rng default
n = 20000;
A = rand(n,n) * 100;
d = rand(1,n) * 100;

mu = mean(A); sigma = std(A);

r = zeros(n,n);
for i = n:-1:1
    for j = 1:i-1
        r(i,j) = exp(-(mu(j) - mu(i))^2 / (sigma(i) + sigma(j))^2);
    end
end
r = r + r' + diag(d);
