
function callFplot
for idx = 1:15
    figure
    fplot(@(x)x .* sin(10 * pi * x) + 2,[-1,2]);
    title('x*sin(10*pi*x)+2')
end
end
