
new_R = 1;

cnt = 0;
while new_R > 1e-15
    if cnt > 0
        new_R = new_R * 0.9;
    end
    cnt = cnt + 1;
end
