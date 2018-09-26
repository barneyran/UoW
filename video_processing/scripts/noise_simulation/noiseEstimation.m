function [ sigma, stds ] = noiseEstimation( estimationDir, outSubDirs, reference )
%NOISEESTIMATION estimate the sigma
%
%   Detailed explanation
%
%   [ sigma ] = noiseEstimation( estimationDir, outSubDirs, reference )
%
%
%   INPUTS
%     estimationDir  --> 
%     outSubDirs     --> names of last subfolders, corresponding to 
%                        different noising intensities
%     reference      \-> path to a reference image, in order to get size,
%                        or directly [height width RGB]
%                        (default = [480 640 3])
%
%   OUTPUTS
%     sigma  -->
%
%   FUNCTIONS USED
%     noiseSimulation          from scripts\noise_simulation\
%
%   See also
%     noiseSimulation digitalCameraSimulation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TO DO
%     End description


pas = 1;
display = 0;


%% Misc jobs
% Optional input reference
if ~exist('reference', 'var')
    referenceSize = [480 640 3];
elseif ischar(reference)
    referenceSize = size(imread(reference));
else 
    referenceSize = reference;        
end

% Format dir name
if strcmp(estimationDir(end), '\') || strcmp(estimationDir(end), '/')
    estimationDir(end) = '/';
else
    estimationDir = [estimationDir '/'];
end

% Generate in and out dirs names 
inMainDir  = [estimationDir 'in/'];
outMainDir = [estimationDir 'out/'];


%% Generate dummy images & pass them through the noise simulation pipeline
% Make sure that the folder is clean
if isdir(estimationDir)
    rmdir(estimationDir, 's');
end
mkdir(estimationDir)
mkdir(inMainDir)

% Generate images into inMainDir
for i = 0:pas:254
    imwrite((i/255)*ones(referenceSize), [inMainDir sprintf('I%05.f.png', i)])
end

% Process images
noiseSimulation( inMainDir, outMainDir, outSubDirs );


%% Noise estimation

% Compute standard deviations
[ paths, filenames ] = genSubDirsPathsFormat(outMainDir, 'png', outMainDir);

dirInfos = dir([inMainDir '*.png']);
imNames  = {dirInfos.name}';
numIm    = size(imNames, 1);
stds     = zeros(numIm, 6);


for i = 1:size(paths, 1)
    fnames = filenames{i, 1};
    for j = 1:size(fnames, 1)
        im = [paths{i, 1} fnames{j, 1}];
        stds(j, 1)   = sscanf(fnames{j, 1}, 'I%f.png');
        stds(j, i+1) = std(im(:));
    end
end


% Analysis
if display
    figure
    legends = cell(size(stds, 2)-1, 1);
    for i = 2:size(stds, 2)
        plot(stds(:, 1), stds(:, i))
        legends{i-1} = paths{i-1};
        hold on
    end
    legend(legends)
end

sigma = mean(mean(stds(:, 2:end)));


end