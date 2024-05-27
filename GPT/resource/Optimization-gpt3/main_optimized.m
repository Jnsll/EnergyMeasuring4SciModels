clear
clc

% Parameters
num_particles = 50;
c1 = 1.5;
c2 = 1.5;
w = 0.5;
max_iterations = 100;
dimension = 30;

% PSO function calls with different parameters
[xm1, fv1] = PSO(@fitness, num_particles, c1, c2, w, max_iterations, dimension);
[xm2, fv2] = PSO(@fitness, 100, c1, c2, w, max_iterations, dimension);
[xm3, fv3] = PSO(@fitness, 500, c1, c2, w, max_iterations, dimension);