
rng default
n = 20000;
A = rand(1,n) * 100;
B = rand(1,n) * 100;

M = zeros(n,n);
for idx1 = 1:n
    for idx2 = 1:n
        M(idx1,idx2) = A(idx1) * A(idx2) / (B(idx1) + B(idx2));
    end
end
