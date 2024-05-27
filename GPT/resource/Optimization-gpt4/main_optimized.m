% Refactored and optimized Matlab code

% Define common parameters
fitnessFunc = @fitness;
w = 0.5;  % inertia weight
maxIter = 100;  % maximum number of iterations
popSizeArray = [50, 100, 500];
c1 = 1.5;
c2 = 1.5;
dim = 30;  % dimension size

% Initializing results storage
xm = cell(1, numel(popSizeArray));
fv = cell(1, numel(popSizeArray));

% Loop through different population sizes
for idx = 1:numel(popSizeArray)
    popSize = popSizeArray(idx);
    [xm{idx}, fv{idx}] = PSO(fitnessFunc, popSize, c1, c2, w, maxIter, dim);
end

% Access results if needed
xm1 = xm{1};
fv1 = fv{1};
xm2 = xm{2};
fv2 = fv{2};
xm3 = xm{3};
fv3 = fv{3};

% You can remove the results storage step and access results directly 
% in application-specific use cases if no further use of variable storage is needed.