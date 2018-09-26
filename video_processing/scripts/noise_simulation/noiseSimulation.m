function [ DurationPipeline, DurationBackup, numImProcessedTotal ] = noiseSimulation( inMainDir, outMainDir, outSubDirs )
%NOISESIMULATION generate noisy png from original png, with Ed's pipeline 
%   
%   Generate noisy png in outMainDir, with Ed's pipeline, for all png files
%   in inMainDir, keeping the same arborescence, with final subfolders
%   named after outSubDirs input cell array of names.
%   
%   
%   [ DurationPipeline, DurationBackup, numImProcessedTotal ] = ...
%       noiseSimulation( inMainDir, outMainDir, outSubDirs )
%   
%   
%   INPUTS
%     inMainDir   --> directory where are folders with images to process
%     outMainDir  --> directory where to recreate inMainDir arborescence to
%                     store output images
%     outSubDirs  --> names of last subfolders, corresponding to different
%                     noising intensities
%   
%   OUTPUTS
%   .png files are written in outMainDir
%     DurationPipeline     --> total runtime of Ed's pipeline process
%     DurationBackup       --> total runtime of backuping process
%     numImProcessedTotal  --> total number of images processed
%
%   FUNCTIONS USED
%     getNumIm                 from scripts\tools\
%     genSubDirsPathsFormat    from scripts\tools\
%     saveAsPNG                from scripts\tools\
%     dispProgress             from scripts\tools\
%     dispstat                 from scripts\toolboxes\dispstat\
%     digitalCameraSimulation  from scripts\noise_simulation\
%
%   See also
%     digitalCameraSimulation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TO DO
%     Finir la description

start = datetime;

%% Settings
control_display  = 0;
progress_display = 1;
progressBarSize  = 50;
final_display    = 1;

subSizeMin       = 20;

%% Misc initial jobs
% Get sub directories names
inDirs  = genSubDirsPathsFormat(inMainDir, 'png', inMainDir );
outDirs = genSubDirsPathsFormat(inMainDir, 'png', outMainDir );

% Initialisations
DurationPipeline    = 0;
DurationBackup      = 0;
numImTotal          = getNumFormatFile(inDirs, 'png');
numImProcessedTotal = 0;
dispstat('', 'init');

%% Control display
if control_display
    fprintf('%.0f images will be processed\n', numImTotal);
    disp(' ');
    fprintf('from :\n');
    disp(inDirs);
    fprintf('  to :\n');
    disp(outDirs);
    fprintf('\nPress any key\n\n');
    pause();
end

%% Processing
% Application of the pipeline, processing subSize images by subSize images
% in order to have regular backups
for i = 1 : size(inDirs, 1)
    
    % Get info
    currentInDir       = inDirs {i};
    currentOutDir      = outDirs{i};
    currentDirInfosPNG = dir([ currentInDir '*.png' ]);
    currentImagesNames = {currentDirInfosPNG.name}';
    numIm              = size(currentImagesNames, 1);
    
    % Reset
    subSize            = max(subSizeMin, floor(numIm/50));
    subIndex           = 0;
    numImProcessed     = 0;    
    
    % Display
    if progress_display
        dispstat(sprintf('currentDir : %s \n     numIm : %d', currentInDir, numIm), 'keepthis', 'keepprev');  
        dispProgress( numImProcessed, numIm, ...
                  numImProcessedTotal, numImTotal, ...
                  DurationPipeline + DurationBackup, ...
                  progressBarSize);
    end

    
    for j = 1 : (numIm/subSize)

        % Get info
        subIndex       = (j-1)*subSize +1 : j*subSize;
        subImagesNames = {currentImagesNames{subIndex}}';
        
        % Process and backup
        [imagesProcessed, durationPipeline] = ...
            digitalCameraSimulation(currentInDir, currentOutDir, subImagesNames);
        durationBackup = saveAsPNG( imagesProcessed, subImagesNames, currentOutDir, outSubDirs );
        
        % Update stats
        DurationPipeline    = DurationPipeline + durationPipeline;
        DurationBackup      = DurationBackup   + durationBackup;
        numImProcessed      = numImProcessed      + subSize;
        numImProcessedTotal = numImProcessedTotal + subSize;
        
        % Display
        if progress_display
            dispProgress( numImProcessed, numIm, ...
                          numImProcessedTotal, numImTotal, ...
                          DurationPipeline + DurationBackup, ...
                          progressBarSize);
        end
    end
    
    % Cases where there is not a multiple of subSize images in the
    % directory, or less than subSize images in the directory
    if ( numIm > 0 && (subIndex(end)<numIm || subIndex(end)<subSize) )
        
        subImagesNames   = {currentImagesNames{subIndex(end)+1 : end}}';
        
        [imagesProcessed, durationPipeline] = ...
            digitalCameraSimulation(currentInDir, currentOutDir, subImagesNames);
        durationBackup = saveAsPNG( imagesProcessed, subImagesNames, currentOutDir, outSubDirs );

        DurationPipeline    = DurationPipeline + durationPipeline;
        DurationBackup      = DurationBackup   + durationBackup;
        numImProcessed      = numImProcessed      + size(subImagesNames, 1);
        numImProcessedTotal = numImProcessedTotal + size(subImagesNames, 1);
        
        if progress_display
            dispProgress( numImProcessed, numIm, ...
                          numImProcessedTotal, numImTotal, ...
                          DurationPipeline + DurationBackup, ...
                          progressBarSize);
        end
    end
end

% Final stats
totalRuntime = datetime - start;
funcRuntime  = seconds(totalRuntime) - (DurationPipeline+DurationBackup);

%% Final display
if final_display
    fprintf('\nDone.\n\n');
    fprintf('Average processing time : %4.2f sec/image\n', DurationPipeline./numImProcessedTotal);
    fprintf(' Average backuping time : %4.2f sec/image\n', DurationBackup  ./numImProcessedTotal);
    disp(' ');
    fprintf(" Total processed images : %-5.0f\n", numImProcessedTotal);
    fprintf("          Total runtime : %s (%.2f%% spend in functions)\n" , ... 
        totalRuntime, (funcRuntime/seconds(totalRuntime))*100);
end
