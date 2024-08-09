
for idx0 = 1:10000
    clear a b
    a = 0;
    b = 0;
    for idx = 1:10
        if idx > 5
            b = b + 1;
        end
        a = a + 1;
    end
end
