
rng default
n = 20000;
A = rand(1,n) * 100;
B = rand(1,n) * 100;

M = zeros(n,n);
for idx1 = n:-1:1
    for idx2 = 1:idx1-1
        M(idx1,idx2) = A(idx1) * A(idx2) / (B(idx1) + B(idx2));
    end
end
D = A .* A ./ (B + B);
M = M + M' + diag(D);
