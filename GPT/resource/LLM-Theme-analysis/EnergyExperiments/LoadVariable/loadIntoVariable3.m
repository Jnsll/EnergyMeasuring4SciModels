
function loadIntoVariable3
for idx = 1:1000
    value = load('data3.mat').value;
    value = value + 1;
end
end
