function [ elapsedTime, numFrameProcessed ] = seq2png( inputDir, outputDir, recursively )
%SEQ2PNG seq to png format conversion
%
%   Converts all seq files from 'inputDir' to 'outputDir', creating one
%   subfolder per seq file, named as the seq files. If 'recursively', then
%   the original 'inputDir' arborescence is recreated in 'outputDir',
%   considering only folders in 'inputDir' with seq files in it.
%
%   
%   [ runtime, numFrameProcessed ] = seq2png( inputDir, outputDir[, recursively] )
%   
%   
%   INPUTS
%     inputDir     -->  string of the input directory name
%     outputDir    -->  string of the output directory name
%     recursively  \->  0 or 1 or 'r' or 'recursively'
%                       (default = 0)   
%   
%   OUTPUTS
%   .png files are written in outputDir
%     elapsedTime        --> runtime in seconds
%     numFrameProcessed  --> number of frames converted
%
%   FUNCTIONS USED
%     seqIo                  from scripts\toolboxes\PiotrCVMT\toolbox\
%     dispstat               from scripts\toolboxes\dispstat\
%     dispProgress           from scripts\tools\
%     genSubDirsPathsFormat  from scripts\tools\
%
%   See also 
%     png2avi avi2png 
%     genSubDirsPathsFormat seqIo
%     dispstat dispProgress
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TO DO
%     - Le plus smple serait de mettre un argument recursively à la function
%     genSubDirsPathsFormat
%     - Clean les seek.mat

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


%% Where to look for seq files

if recursively
    [inDirs, filenames] = genSubDirsPathsFormat( inputDir, 'seq', inputDir );
    outDirs             = genSubDirsPathsFormat( inputDir, 'seq', outputDir, 1 );
    if isempty(inDirs)
        fprintf('No seq files found.\n\n')
        elapsedTime=0; numFrameProcessed=0;
        return
    end
else
    inputDirSeqInfos = dir([inputDir '*.seq']);
    if ~isempty(inputDirSeqInfos)   
        [inDirs, filenames] = genSubDirsPathsFormat( inputDir, 'seq', inputDir,  0, recursively );
        outDirs             = genSubDirsPathsFormat( inputDir, 'seq', outputDir, 1, recursively );
    else
        fprintf('No seq files in this folder.\n')
        fprintf('Maybe you want to try it recursively, in order to search for seq files in sub folders : \n\n')
        fprintf("    seq2png( inputDir, outputDir, 'recursively' )\n\n")
        elapsedTime=0; numFrameProcessed=0;
        return
    end
end


%% Initialisations
numFilesTotal          = getNumFormatFile(inDirs, 'seq');
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
    
    for j = 1:numFiles
        
        fName = [inDirs{i} filenames{i}{j}];
        tDir = outDirs{i}{j};
        
        info = seqIo( fName, 'getInfo' );
        
        seqIo( fName, 'toImgs', tDir, 1, 0, info.numFrames-1, 'png' );
        
        % Update stats
        elapsedTime            = datetime - start;        
        numFrameProcessed      = numFrameProcessed + info.numFrames;
        numFilesProcessed      = numFilesProcessed + 1;
        numFilesProcessedTotal = numFilesProcessedTotal + 1;
        
        % Display
        if progress_display
            dispProgress( numFilesProcessed, numFiles, ...
                      numFilesProcessedTotal, numFilesTotal, ...
                      seconds(elapsedTime), progressBarSize);
        end
    end
    
    % Clean -seek.mat residual files
    delete([inDirs{i} '*-seek.mat'])
end


%% Final display
if final_display
    fprintf('\nDone.\n\n');
    fprintf('Average processing time : %4.2f sec/frame\n', seconds(elapsedTime)./numFrameProcessed);
    fprintf(' Total frames processed : %-5.0f\n', numFrameProcessed);
    fprintf('    Total seq processed : %-5.0f\n', numFilesProcessedTotal);
    fprintf('          Total runtime : %s\n', elapsedTime );
end


end

