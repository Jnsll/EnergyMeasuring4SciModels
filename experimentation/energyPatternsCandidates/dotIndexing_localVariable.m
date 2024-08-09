
for idx = 1:1000
    % Problem bounds
    clear
    bounds.initialTime.low = 0;
    bounds.initialTime.upp = 0;
    bounds.finalTime.low = 1.0;
    bounds.finalTime.upp = 1.0;

    bounds.state.low = [0; -inf];
    bounds.state.upp = [1; inf];
    bounds.initialState.low = [0;0];
    bounds.initialState.upp = [0;0];
    bounds.finalState.low = [1;0];
    bounds.finalState.upp = [1;0];

    uMax = 20;
    bounds.control.low = [-uMax;zeros(2,1)];  %Two slack variables
    bounds.control.upp = [uMax;inf(2,1)];

    % Guess at the initial trajectory
    guess.time = [0,1];
    guess.state = [0, 0; 1, 0];
    guess.control = [0, 0;zeros(2,2)]; %Two slack variables

    % Options for fmincon
    options.nlpOpt = optimset(...
        'Display','iter',...
        'GradObj','on',...
        'GradConstr','on',...
        'DerivativeCheck','on');   %Fmincon automatic gradient check

    options.method = 'trapezoid';
    options.trapezoid.nGrid = 100;
    options.defaultAccuracy = 'medium';

    problem.options = options;
    problem.guess = guess;
    problem.bounds = bounds;
end
