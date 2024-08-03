
%%% Generate the training data.

close all;

addpath('utilities');

batchSize     = 128;        %%% batch size
dataName      = 'TrainingPatches';
folder        = fullfile('Test','Set12'); % folder 'Train400' is missing on GitHub

patchsize     = 40;
stride        = 10;
step          = 0;

count   = 0;

ext                 =  {'*.jpg','*.png','*.bmp','*.jpeg'};
filepaths           =  [];

for i = 1 : length(ext)
    filepaths = cat(1,filepaths, dir(fullfile(folder, ext{i})));
end
lengthFilePaths = length(filepaths);

%% count the number of extracted patches
scales  = [1 0.9 0.8 0.7];
for i = 1 : lengthFilePaths
    
    image = part1(folder,filepaths,lengthFilePaths,i);

    for s = 1:4
        image = imresize(image,scales(s),'bicubic');

        [hei,wid,~] = size(image);
        
        for x = 1 + step : stride : (hei - patchsize + 1)
            for y = 1 + step :stride : (wid - patchsize + 1)
                count = count + 1;
            end
        end
    end
end

numPatches = ceil(count / batchSize) * batchSize;

disp([numPatches,batchSize,numPatches / batchSize]);

%pause;

inputs  = zeros(patchsize, patchsize, 1, numPatches,'single'); % this is fast
count   = 0;
for i = 1 : lengthFilePaths
    
    image = part1(folder,filepaths,lengthFilePaths,i);
    
    %     end
    for s = 1:4
        image = imresize(image,scales(s),'bicubic');

        image_aug = data_augmentation(image, 1);  % augment data
        im_label  = im2single(image_aug); % single
        [hei,wid,~] = size(im_label);

        for x = 1 + step : stride : (hei - patchsize + 1)
            for y = 1 + step :stride : (wid - patchsize + 1)
                count = count + 1;
                inputs(:, :, :, count)   = im_label(x : x + patchsize - 1, y : y + patchsize - 1,:);
            end
        end
    end
end
set    = uint8(ones(1,size(inputs,4)));

disp('-------Datasize-------')
disp([size(inputs,4),batchSize,size(inputs,4) / batchSize]);

if ~exist(dataName,'file')
    mkdir(dataName);
end

%%% save data
save(fullfile(dataName,['imdb_',num2str(patchsize),'_',num2str(batchSize)]), 'inputs','set','-v7.3')

function image = part1(folder,filepaths,lengthFilePaths,i)
image = imread(fullfile(folder,filepaths(i).name)); % uint8
if size(image,3) == 3
    image = rgb2gray(image);
end
%[~, name, exte] = fileparts(filepaths(i).name);
if mod(i,100) == 0
    disp([i,lengthFilePaths]);
end
end
