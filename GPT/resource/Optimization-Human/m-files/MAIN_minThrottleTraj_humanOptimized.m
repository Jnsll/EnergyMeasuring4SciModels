
addpath(fullfile('..','..'))
addpath(fullfile('.','utilities'))
addpath(fullfile('.','test'))

% Define environmental and plant model params
p = loadPlant_QuadRotor3d(); 

% Trajectory Parameters:
duration = 3;

% Initial State:
zeroArray = zeros(6,1);
X0 = [1;0;0;0;0;0];   % initial configuration
dX0 = zeroArray;     % initial rates
z0 = [X0; dX0];  % initial state

XF = zeroArray;   % final configuration
dXF = zeroArray;     % final rates
zF = [XF; dXF];  % final state

problem.func.dynamics = @(t,z,u)( dynQuadRotor3d(z,u,p) );
problem.func.pathObj = @(t,z,u)( sum(u.^2,1) );

problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = duration;
problem.bounds.finalTime.upp = duration;

problem.bounds.initialState.low = z0;
problem.bounds.initialState.upp = z0;
problem.bounds.finalState.low = zF;
problem.bounds.finalState.upp = zF;

onesArray = ones(4,1);
problem.bounds.control.low = -p.uMax * onesArray;
problem.bounds.control.upp = p.uMax * onesArray;

problem.guess.time = [0,duration];
problem.guess.state = [z0, zeros(12,1)];
problem.guess.control = ones(4,2);

problem.options.nlpOpt = optimset(...
    'Display','iter',...
    'MaxFunEvals',1e5);

problem.options.method = 'trapezoid'; 
problem.options.trapezoid.nGrid = 16;

soln = optimTraj(problem);

plotQuadRotor3d(soln)
