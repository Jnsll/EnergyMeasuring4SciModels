
function callFplot
for idx = 1:15
    fplot(@(x)x .* sin(10 * pi * x) + 2,[-1,2]);
end
end
