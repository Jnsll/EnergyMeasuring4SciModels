
function loopWithSwitch
rng default
indices =randi(4,2000,1);

for idx = 1:10000
    for i=1:2000
        switch indices(i)
            case 1
                output(i,:)=[1 0 0 0];
            case 2
                output(i,:)=[0 1 0 0];
            case 3
                output(i,:)=[0 0 1 0];
            case 4
                output(i,:)=[0 0 0 1];
        end
    end
end
end
