
function loadIntoVariable2
for idx = 1:1000
    value = load('data2.mat').value;
    value = value + 1;
end
end
