function [ cbm3d_totalRuntime, numImTotal, logsPSNR, logsSNR ] = cbm3dDenoising( inMainDir, outMainDir, origMainDir, logsMainDir, profile, sigma )
%CVBM3DR Denoising of RGB videos corrupted with AWGN.
%   Detailed explanation goes here
%   
%   
%   
%   [ cbm3d_totalRuntime, numImTotal, logsPSNR, logsSNR ] = ...
%       cbm3dDenoising( inMainDir, outMainDir, origMainDir, logsMainDir, ...
%                       profile, sigma )
%   
%   
%   INPUTS
%     inMainDir    -->
%     outMainDir   -->
%     origMainDir  -->
%     logsMainDir  -->
%     profile      \-> 'lc', 'np', 'high', 'vn'
%                      'vn' is automatically enabled for high noise,
%                      when sigma > 40
%                      (default = 'np')
%     sigma        \-> (default = 30)
%   
%   OUTPUTS
%   .avi and logs files are written in the outMainDir folder
%     cbm3d_totalRuntime -->
%     numOfFramesTotal   -->
%     logsPSNR           -->
%     logsSNR            -->
%
%   FUNCTIONS USED
%     cvbm3d                 from scripts\denoising\ 
%     genSubDirsPathsFormat  from scripts\tools\
%     dispProgress           from scripts\tools\
%     dispstat               from scripts\toolboxes\dispstat\
%
%   See also
%     cvbm3d
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TO DO
%     End description


%% Settings
control_display  = 0;
progress_display = 1;
progressBarSize  = 25;
final_display    = 1;


%% Misc initial jobs
% Get paths
[inDirs, allNoisyIm]  = genSubDirsPathsFormat( inMainDir,   'png', inMainDir );
outDirs               = genSubDirsPathsFormat( inMainDir,   'png', outMainDir );
[origDirs, allOrigIm] = genSubDirsPathsFormat( origMainDir, 'png', origMainDir );
arborescence          = genSubDirsPathsFormat( origMainDir, 'png' );
logsDirs              = genSubDirsPathsFormat( inMainDir,   'png', logsMainDir );

% Initialisations
numSequences        = size(inDirs, 1);
numImTotal          = getNumFormatFile(inDirs, 'png');
logsPSNR            = cell(numSequences, 2);
logsSNR             = cell(numSequences, 2);
numImProcessedTotal = 0;
cbm3d_totalRuntime  = 0;
totalRuntime        = datetime-datetime;

cntDir              = 1;
currentInDir        = inDirs{1};
invalidOrig         = 0;

print_to_screen = 0;
colorspace = 'opp';

dispstat('', 'init');

% Defaults parameters
if ~exist('profile', 'var')
    profile = 'np';
end
if ~exist('sigma', 'var')
    sigma = 30;
end


%% Control display
if control_display
    fprintf('%.0f images will be processed from %.0f squences \n', numImTotal, numSequences);
    fprintf('\nPress any key\n\n');
    pause();
end


%% Processing
start = datetime;

for i = 1 : size(origDirs, 1)
    
    % Update infos
    currentOrgDir = origDirs{i};
    numIm         = size(allOrigIm{i}, 1);
    
    % Update logs
    logsPSNR{i, 1} = currentOrgDir;
    
    % Update counters
    cntWhile = 0;
    
    % Display
    if progress_display
        dispstat(sprintf('  sequence : %s \n     numIm : %d', arborescence{i}, numIm), 'keepthis', 'keepprev'); % TO DO print num Dir
        dispProgress( 1e-5, numIm, ...
                  numImProcessedTotal, numImTotal, ...
                  seconds(totalRuntime), progressBarSize);
    end
    
    % Denoise each different noisy versions of the sequence contained in
    % currentOrigDir
    while true
        
        % Update counters
        numImProcessed = 0;
        cntWhile       = cntWhile +1;
        
        % Initialisations
        PSNRs = zeros(numIm, 2);
        SNRs  = zeros(numIm, 2);
        
        % Update infos
        currentOutDir  = outDirs{cntDir};
        currentLogsDir = logsDirs{cntDir};
        
        % Create output directory
        if ~isdir(currentOutDir)
            mkdir(currentOutDir);
        end
        
        % Verification
        if numIm ~= size(allNoisyIm{cntDir}, 1)
            fprintf('Original and noisy directories do not match, no stats calculated.\n');
            invalidOrig = 1;
            numIm = size(allNoisyIm{cntDir}, 1);
        end
        
        % Denoising directory
        for j = 1 : numIm
            
            % Update infos
            currentNoisyIm = imread([currentInDir allNoisyIm{cntDir}{j}]);
            if ~invalidOrig
                currentOrigIm = imread([currentOrgDir allOrigIm{i}{j}]);
            else
                currentOrigIm = [];
            end
            
            % Process
            [ denoisedIm, runtime, PSNRs(j, 1:2), SNRs(j, 1:2) ] = ...
                cbm3d( currentNoisyIm, currentOrigIm, sigma, ...
                       profile, print_to_screen, colorspace );
                   
            % Save result as png
            imwrite(denoisedIm, [currentOutDir allNoisyIm{cntDir}{j}])
                   
            % Update stats
            cbm3d_totalRuntime  = cbm3d_totalRuntime + runtime;
            totalRuntime        = datetime-start;
            numImProcessed      = numImProcessed +1;
            numImProcessedTotal = numImProcessedTotal +1;
            
            % Display
            if progress_display
                dispProgress( numImProcessed, numIm, ...
                          numImProcessedTotal, numImTotal, ...
                          seconds(totalRuntime), progressBarSize);
            end
            
        end
        
        % Update logs
        logsPSNR{i, 2}{cntWhile, 1} = currentInDir;
        logsPSNR{i, 2}{cntWhile, 2} = PSNRs;
        logsSNR {i, 2}{cntWhile, 1} = currentInDir;        
        logsSNR {i, 2}{cntWhile, 2} = SNRs;
        
        % Create logs dir
        if ~isdir(currentLogsDir)
            mkdir(currentLogsDir);
        end
        
        % Write logs
        formatSpec_psnrs = '%.f,%.3f,%.3f\n';
        fileID_psnrs = fopen([currentLogsDir  'PSNRs.txt'], 'w');
        fileID_snrs  = fopen([currentLogsDir  'SNRs.txt'],  'w');
        fprintf(fileID_psnrs, formatSpec_psnrs, [(0:numIm-1)' PSNRs]');
        fprintf(fileID_snrs,  formatSpec_psnrs, [(0:numIm-1)' SNRs]');
        if fclose(fileID_psnrs) || fclose(fileID_snrs)
            warning('psnr or snr logs file did not close well\n')
        end
        
        % while conditions
        if cntDir >= numSequences
            break
        else
            cntDir       = cntDir +1;
            currentInDir = inDirs{cntDir};
            if ~contains(currentInDir, arborescence{i}(1:end-1))
                    break
            end
        end
    end  
end    

% Final stats
funcRuntime  = seconds(totalRuntime) - (cbm3d_totalRuntime);

%% Final display
if final_display
    fprintf('\nDone.\n\n');
    fprintf(" Total processed frames : %-5.0f\n", numImTotal);
    fprintf('Average processing time : %4.2f sec/image\n', cbm3d_totalRuntime./numImTotal);    
    fprintf("          Total runtime : %s (%.2f%% spend in functions)\n" , ... 
        totalRuntime, (funcRuntime/seconds(totalRuntime))*100);
end



end