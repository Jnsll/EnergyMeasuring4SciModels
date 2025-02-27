
function loadIntoVariable
for idx = 1:1000
    value = load('data.mat').value;
    value = value + 1;
end
end
