
for idx = 1:1000
    % Problem bounds
    clear
    initialTime.low = 0;
    initialTime.upp = 0;
    bounds.initialTime = initialTime;
    finalTime.low = 1.0;
    finalTime.upp = 1.0;
    bounds.finalTime = finalTime;

    state.low = [0; -inf];
    state.upp = [1; inf];
    bounds.state = state;
    initialState.low = [0;0];
    initialState.upp = [0;0];
    bounds.initialState = initialState;
    finalState.low = [1;0];
    finalState.upp = [1;0];
    bounds.finalState = finalState;

    uMax = 20;
    control.low = [-uMax;zeros(2,1)];  %Two slack variables
    control.upp = [uMax;inf(2,1)];
    bounds.control = control;

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
