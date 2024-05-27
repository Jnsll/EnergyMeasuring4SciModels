% Load data
monks_A1 = load('monks_A1.ascii');
monks_T = load('monks_T.ascii');

[N, m] = size(monks_T);

class = 1;

app = monks_A1;
test = monks_T;

[Napp, ~] = size(app);
[Ntest, ~] = size(test);

uniqueAppClass = unique(app(class, :));
uniqueTestClass = unique(test(class, :));

ns = max(monks_T, [], 2);
clear monks_A1 monks_T;

disp(['N: ', num2str(N)]);
disp(['ns(class): ', num2str(ns(class))]);
disp(['Napp: ', num2str(Napp)]);
disp(['Ntest: ', num2str(Ntest)]);
disp(['Mean(ns): ', num2str(mean(ns))]);