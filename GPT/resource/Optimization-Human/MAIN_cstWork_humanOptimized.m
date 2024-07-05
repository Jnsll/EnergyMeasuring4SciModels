% MAIN - Point Mass
%
% Demonstrates how to use slack variables for an objective function that
% includes an abs()
%
% The Integral{abs(power)} cost function is difficult to optimize for two
% reasons:
%   1) The objective function is non-smooth. This is addressed here by
%   introducing a pair of slack variables and a path constraint. An
%   alternative method is shown in MAIN_smoothWork.m, that directly smooths
%   
%
%   2) The second problem is that the solution itself is non-smooth. This
%   means that the piece-wise polynomial representation will fail to
%   accurately represent the solution, making the optimization difficult.
%   One solution to this problem is to add additional smoothing terms to
%   the cost function. Integral of of the input squared is good, as is the
%   integral of the input rate squared.
%
%

function res = MAIN_cstWork_humanOptimized
addpath ../../

% User-defined dynamics and objective functions
func.dynamics = @(~,x,u)( cstDyn(x,u) );
func.pathObj = @(~,~,u)( obj_cstWork(u) );
func.pathCst = @(~,x,u)( cstSlackPower(x,u) );
problem.func = func;

% Problem bounds
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
problem.bounds = bounds;

% Guess at the initial trajectory
guess.time = [0,1];
guess.state = [0, 0; 1, 0];
guess.control = zeros(3,2); %Two slack variables
problem.guess = guess;

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

% Solve the problem
soln = optimTraj(problem);
grid = soln.grid;
t = grid.time;
q = grid.state(1,:);
dq = grid.state(2,:);
u = grid.control;

% Plot the solution:
figure(3);
clf;

createSubplot(t,q,'pos',1)

title('Move Point Mass');

createSubplot(t,dq,'vel',2)
createSubplot(t,u(1,:),'force',3)
createSubplot(t,u(2:3,:),'slack',4)

res.bounds = problem.bounds;
res.guess = problem.guess;
res.options = problem.options;
res.grid = soln.grid;
soln.info.nlpTime = [];
res.info = soln.info;
end

function createSubplot(x,y,str,idx)
subplot(4,1,idx)
plot(x,y)
ylabel(str)
end
