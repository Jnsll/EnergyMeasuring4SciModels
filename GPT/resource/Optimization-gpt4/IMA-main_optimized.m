clear;
clc;
tic;

% Parameters
pop_size = 15;
chromosome_size = 10;
epochs = 50;
cross_rate = 0.4;
mutation_rate = 0.1;
a0 = 0.7;
zpop_size = 5;
best_fitness = 0;
nf = 0;
number = 0;

% Read and process image
Image = imread('bird.bmp');
if isRgb(Image)
    Image = rgb2gray(Image);
end
[m, n] = size(Image);
p = imhist(Image) / (m * n);

% Display original image
figure(1);
subplot(121);
imshow(Image);
title('Original Image');
hold on;

% Initialize population
pop = round(rand(pop_size, chromosome_size));

for epoch = 1:epochs
    % Calculate fitness
    [fitness, threshold, number] = fitnessty(pop, chromosome_size, Image, pop_size, m, n, number);
    max_fitness = max(fitness);
    
    if max_fitness > best_fitness
        best_fitness = max_fitness;
        nf = 0;
        best_index = find(fitness == best_fitness, 1);
        thres = threshold(1, best_index);
    elseif max_fitness == best_fitness
        nf = nf + 1;
    end
    
    if nf >= 20
        fprintf('Early stopping due to no improvement.\n');
        break;
    end
    
    % Genetic Algorithm operations
    similar_chromosome = similarChromosome(pop);
    f = fit(similar_chromosome, fitness);
    pop = select(pop, f);
    pop = cross(pop, cross_rate, pop_size, chromosome_size);
    pop = mutation(pop, mutation_rate, chromosome_size, pop_size);
    
    % Check for diversity
    if similarPopulation(pop) > a0
        zpop = round(rand(zpop_size, chromosome_size));
        pop = [pop; zpop];
        [fitness, threshold, number] = fitnessty(pop, chromosome_size, Image, pop_size, m, n, number);
        similar_chromosome = similarChromosome(pop);
        f = fit(similar_chromosome, fitness);
        pop = select(pop, f);
    end
    
    if epoch == epochs
        [fitness, threshold, number] = fitnessty(pop, chromosome_size, Image, pop_size, m, n, number);
    end
    
    % Draw result
    drawResult(Image, thres);
    subplot(122);
    fprintf('Threshold = %d\n', thres);
end

toc;

% Final result display
subplot(122);
drawResult(Image, thres);
title('Result after segmentation');