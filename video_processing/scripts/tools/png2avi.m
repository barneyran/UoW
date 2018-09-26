function [ elapsedTime, numImProcessed ] = png2avi( inputDir, outputDir, recursively, frameRate )
%PNG2AVI png to avi format conversion
%
%   Converts all inputDir sub folders containing png files into .avi files 
%   named after those sub folders, and stored in outputDir, following the 
%   inputDir arborescence.
%   
%   
%   [ runtime, numImProcessed ] = png2avi( inputDir, outputDir[, recursively, frameRate] )
%   
%   
%   INPUTS
%     inputDir     -->  where to look for folders of png files.
%     outputDir    -->  where to store outputs avi files
%     recursively  \->  1 or 1 or 'r' or 'recursively', whether to look or 
%                       not to look for sub folders of inputDir
%                       (default = 0)   
%     frameRate    \->  outputs .avi files frame rate
%                       (default = 30)  
%   
%   OUTPUTS
%   .avi files are written in outputDir
%     runtime         --> runtime in seconds
%     numImProcessed  --> number of images converted
%
%   FUNCTIONS USED
%     genSubDirsPathsFormat  from scripts\tools\
%     dispProgress           from scripts\tools\
%     dispstat               from scripts\toolboxes\dispstat\
%
%   See also 
%      seq2png avi2png 
%      genSubDirsPathsFormat
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TO DO
%     - Je suis pas sur que ca marche si pas recursively parce que en fait si
%     on ne prend en compte que les images qui sont dans inputDir alors 
%     elles vont etre enregistrées sous quel nom en tant que avi. La 
%     logique voudrait que ce soit sous le nom inputDir, mais alors à quoi 
%     sert le outputDir ? est-ce que on peut y ranger au dessus ? A voir 
%     comment ça se comporte maintenant et quel comportement on 
%     souhaiterait avoir
%     - Remove commented lines if its working 

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

% Frame rate
if ~exist('frameRate', 'var')
    frameRate = 30;
end
    

%% Where to look for png files
% if recursively
%     inDirs  = genSubDirsPathsFormat( inputDir, 'png', inputDir );
%     outDirs = genSubDirsPathsFormat( inputDir, 'png', outputDir );
%     if isempty(inDirs)
%         fprintf('No png files found.\n\n')
%         elapsedTime=0; numImProcessed=0;
%         return
%     end
% else
%     if ~isempty(dir([inputDir '*.png']))
%         inDirs  = {inputDir };
%         outDirs = {outputDir};     
%     else
%         fprintf('No png files in this folder.\n')
%         fprintf('Maybe you want to try it recursively, in order to search for png files in sub folders : \n\n')
%         fprintf("    png2avi( inputDir, outputDir, 'recursively', frameRate )\n\n")
%         elapsedTime=0; numImProcessed=0;
%         return
%     end
% end

%% Where to look for png files
inDirs  = genSubDirsPathsFormat( inputDir, 'png', inputDir );
outDirs = genSubDirsPathsFormat( inputDir, 'png', outputDir );
% Handle lines 125 & 131 for particular case of png files directly inputDir
% which could make sense if '~recursively'
if strcmp(outDirs{1}, outputDir) || strcmp(outDirs{1}, [outputDir '\']) || strcmp(outDirs{1}, [outputDir '/'])
    tmp = strsplit(inputDir, {'/', '\'});
    outDirs{1} = [outDirs{1} tmp{end} '/'];
    clear tmp
end

%% Verification
if isempty(inDirs)
    fprintf('No png files found.\n\n')
    if ~recursively
        fprintf('Maybe you want to try it recursively, in order to search for png files in sub folders : \n\n')
        fprintf("    png2avi( inputDir, outputDir, 'recursively', frameRate )\n\n")
    end
    elapsedTime=0; numImProcessed=0;
    return
end

%% Initialisations
start          = datetime;
numImTotal     = getNumFormatFile(inDirs, 'png');
numImProcessed = 0;
elapsedTime    = 0;

dispstat('', 'init');


%% Create avi files

for i = 1 : size(inDirs, 1)
    
    % get info
    currentInDir       = inDirs{i};
    AVIfilename        = [outDirs{i}(1:end-1) '.avi'];
    currentDirInfosPNG = dir([ currentInDir '*.png' ]);
    currentImagesNames = {currentDirInfosPNG.name}';
    numIm              = size(currentImagesNames, 1);
    
    % create directory
    if ~isdir(fileparts(AVIfilename))
        mkdir(fileparts(AVIfilename))
    end
    
    % write video
    v = VideoWriter(AVIfilename, 'Uncompressed AVI'); %#ok<TNMLP>
    v.FrameRate = frameRate;
    
    open(v)
    for j = 1 : numIm
        im = imread([currentInDir currentImagesNames{j}]);
        writeVideo(v, im);
        numImProcessed = numImProcessed +1;
    end
    close(v)
    
    % Update stats
    elapsedTime = datetime - start;
    
    % Display
    if progress_display
        dispProgress( 1, 1, numImProcessed, numImTotal, seconds(elapsedTime), progressBarSize);
    end
end


%% Final display
if final_display
    fprintf('\nDone.\n\n');
    fprintf('Average processing time : %4.2f sec/frame\n', seconds(elapsedTime)./numImProcessed);
    fprintf(' Total frames processed : %-5.0f\n', numImProcessed);
    fprintf('    Total avi generated : %-5.0f\n', size(inDirs, 1));
    fprintf('          Total runtime : %s\n', elapsedTime );
end


end