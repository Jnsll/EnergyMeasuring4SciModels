% Load data
monks_A1 = load('-ascii', 'monks_A1');
monks_T = load('-ascii', 'monks_T');

[N, m] = size(monks_T);

class = 1;

% Separate training and test data
app = monks_A1;
test = monks_T;

% Get the number of columns directly
Napp = size(app, 2);
Ntest = size(test, 2);

% Find unique elements in the specified class
unique_app_class = unique(app(class, :));
unique_test_class = unique(test(class, :));

% Find the maximum value in each row of monks_T
ns = max(monks_T, [], 2);

% Clear unnecessary variables
clear monks_A1 monks_T

% Display the results
disp('Number of samples in monks_T (N):');
disp(N);

disp('Unique elements in app(class,:):');
disp(unique_app_class);

disp('Unique elements in test(class,:):');
disp(unique_test_class);

disp('Number of columns in app (Napp):');
disp(Napp);

disp('Number of columns in test (Ntest):');
disp(Ntest);

disp('Mean of maximum values in each row of monks_T:');
disp(mean(ns));