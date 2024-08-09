
rng default
n = 20000;
A = rand(n,n) * 100;
d = rand(1,n) * 100;

mu = mean(A); sigma = std(A);

r = zeros(n,n);
for i = 1:n
    for j = 1:n
        r(i,j) = exp(-(mu(j) - mu(i))^2 / (sigma(i) + sigma(j))^2);
    end
end
