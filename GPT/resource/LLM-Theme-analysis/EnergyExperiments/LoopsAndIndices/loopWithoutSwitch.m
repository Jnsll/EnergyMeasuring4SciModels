
function loopWithoutSwitch
rng default
indices = randi(4,2000,1);

for idx = 1:10000
    output = zeros(2000,4);
    for idx1 = 1:4
        output(indices == idx1,idx1) = 1;
    end
end
end
