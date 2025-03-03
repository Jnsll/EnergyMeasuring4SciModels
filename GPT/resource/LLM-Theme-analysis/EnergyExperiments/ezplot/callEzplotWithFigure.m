
function callEzplot
for idx = 1:15
    figure
    ezplot('x*sin(10*pi*x)+2',[-1,2]);
end
end
