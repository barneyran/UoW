function [ elapsedTime, numFrameProcessed ] = avi2png( inputDir, outputDir, recursively )
%AVI2PNG avi to png format conversion
%
%   Converts all avi files from 'inputDir' to 'outputDir', creating one
%   subfolder per avi file, named as the avi files. If 'recursively', then
%   the original 'inputDir' arborescence is recreated in 'outputDir',
%   considering only folders in 'inputDir' with avi files in it.
%
%   Note : estimate remaining time, displayed if 'progress_display' hard
%   coded parameter is set to 1, can be totally false as it supose that avi
%   files have all the same number of frames.
%   
%   
%   [ elapsedTime, numFrameProcessed ] = avi2png( inputDir, outputDir[, recursively] )
%   
%   
%   INPUTS
%     inputDir     --> string of the input directory name
%     outputDir    --> string of the output directory name
%     recursively  \-> 0 or 1 or 'r' or 'recursively'
%                      (default = 0)    
%   
%   OUTPUTS
%   .png files are written in outputDir
%     elapsedTime        --> elapsedTime in seconds
%     numFrameProcessed  --> number of frames converted
%
%   FUNCTIONS USED
%     genSubDirsPathsFormat  from scripts\tools\
%     getNumFormatFile       from scripts\tools\
%     dispProgress           from scripts\tools\
%     dispstat               from scripts\toolboxes\dispstat\
%
%   See also 
%      png2avi seq2png 
%      genSubDirsPathsFormat
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%   
%   TO DO
%     - Remove commented lines if it is working correctly
%   
%
%

%% Settings
progress_display = 1;
progressBarSize  = 50;
final_display    = 1;


%% Optionnal parameters
% Recursively or not
if exist('recursively', 'var')
    if ischar(recursively)
        if ( strcmpi('recursively', recursively) || strcmpi('r', recursively) )
            recursively = 1;
        else
            recursively = 0;
        end
    end
else
    recursively = 0;
end


%% Misc jobs
% Formating
% if ( strcmp(inputDir(end), '/') || strcmp(inputDir(end), '\') )
%     inputDir(end) = '\';
% else
%     inputDir(end+1) =  '\';
% end
% 
% if ( strcmp(outputDir(end), '/') || strcmp(outputDir(end), '\') )
%     outputDir(end) = '\';
% else
%     outputDir(end+1) =  '\';
% end


% Where to look for avi files
if recursively
%     [ inDirs, outDirs ] = getDirNames( inputDir, outputDir, [], 'avi' );
    [inDirs, filenames] = genSubDirsPathsFormat( inputDir, 'avi', inputDir );
    outDirs             = genSubDirsPathsFormat( inputDir, 'avi', outputDir, 1 );
    if isempty(inDirs)
        fprintf('No avi files found.\n\n')
        return
    end
else
    if ~isempty(dir([inputDir '*.avi']))
        inDirs  = {inputDir };
        outDirs = {outputDir};     
    else
        fprintf('No avi files in this folder.\n')
        fprintf('Maybe you want to try it recursively, in order to search for avi files in sub folders : \n\n')
        fprintf("    avi2png( inputDir, outputDir, 'recursively' )\n\n")
        return
    end
end


%% Initialisations
numFilesTotal          = getNumFormatFile(inDirs, 'avi');
start                  = datetime;
numFrameProcessed      = 0;
numFilesProcessedTotal = 0;
elapsedTime            = datetime - datetime;

dispstat('', 'init');


%% Create png files

for i = 1:size(inDirs, 1)
    
    % Reset
    numFilesProcessed = 0;
    numFiles = size(filenames{i}, 1);
    
    % Display
    if progress_display
        dispstat(sprintf('currentDir : %s \n  numFiles : %d', inDirs{i}, numFiles), 'keepthis', 'keepprev');  
        dispProgress( numFilesProcessed, numFiles, ...
                  numFilesProcessedTotal, numFilesTotal, ...
                  seconds(elapsedTime), progressBarSize);
    end
    
    % get info
%     currentInDir       = inDirs{i};
%     currentOutDir      = outDirs{i};
%     currentDirInfosAVI = dir([ currentInDir '*.avi' ]);
%     currentAviNames    = {currentDirInfosAVI.name}';
%     numAvi             = size(currentAviNames, 1);
    
    for j = 1:numFiles
        
%         fName = [currentInDir currentAviNames{j}];
%         tDir  = [currentOutDir currentAviNames{j}(1:end-4)];
        
        fName = [inDirs{i} filenames{i}{j}];
        tDir = outDirs{i}{j};
        
        aviFile = VideoReader(fName); %#ok<TNMLP>
        
        cpt = -1;
        while hasFrame(aviFile)
            cpt   = cpt +1;
            tName = [tDir '/' sprintf('I%05.f', cpt) '.png'];
            
            if ~isdir(fileparts(tName))
                mkdir(fileparts(tName))
            end
            
            imwrite(readFrame(aviFile), tName)
            
            numFrameProcessed = numFrameProcessed +1;
        end
        
        % Update stats
        elapsedTime            = datetime - start;        
        numFilesProcessed      = numFilesProcessed + 1;
        numFilesProcessedTotal = numFilesProcessedTotal + 1;
        
        % Display
        if progress_display
            dispProgress( numFilesProcessed, numFiles, ...
                      numFilesProcessedTotal, numFilesTotal, ...
                      seconds(elapsedTime), progressBarSize);
        end
        
    end
end


%% Final display
if final_display
    fprintf('\nDone.\n\n');
    fprintf('Average processing time : %4.2f sec/frame\n', seconds(elapsedTime)./numFrameProcessed);
    fprintf(' Total frames processed : %-5.0f\n', numFrameProcessed);
    fprintf('    Total avi processed : %-5.0f\n', numFilesProcessedTotal);
    fprintf('          Total runtime : %s\n', elapsedTime );
end


end

