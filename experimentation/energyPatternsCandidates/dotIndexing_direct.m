
for idx = 1:1000
    % Problem bounds
    clear
    problem.bounds.initialTime.low = 0;
    problem.bounds.initialTime.upp = 0;
    problem.bounds.finalTime.low = 1.0;
    problem.bounds.finalTime.upp = 1.0;

    problem.bounds.state.low = [0; -inf];
    problem.bounds.state.upp = [1; inf];
    problem.bounds.initialState.low = [0;0];
    problem.bounds.initialState.upp = [0;0];
    problem.bounds.finalState.low = [1;0];
    problem.bounds.finalState.upp = [1;0];

    uMax = 20;
    problem.bounds.control.low = [-uMax;zeros(2,1)];  %Two slack variables
    problem.bounds.control.upp = [uMax;inf(2,1)];

    % Guess at the initial trajectory
    problem.guess.time = [0,1];
    problem.guess.state = [0, 0; 1, 0];
    problem.guess.control = [0, 0;zeros(2,2)]; %Two slack variables

    % Options for fmincon
    problem.options.nlpOpt = optimset(...
        'Display','iter',...
        'GradObj','on',...
        'GradConstr','on',...
        'DerivativeCheck','on');   %Fmincon automatic gradient check

    problem.options.method = 'trapezoid';
    problem.options.trapezoid.nGrid = 100;
    problem.options.defaultAccuracy = 'medium';
end
