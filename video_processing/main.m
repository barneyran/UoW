close all ; 
clear all ;
clc

logsOutputDir = '../logs/video_processing/';
if ~isdir(logsOutputDir)
    mkdir(logsOutputDir);
end
outLogName = sprintf([logsOutputDir 'run_%s'], datestr(now, 'yyyy_mm_dd__HH_MM_SS'));
diary([outLogName '.txt'])
disp(datetime)
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TO DO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - Comment all / TO DO
% - bug avi directly in mainFolder (denoising)
% - enlever les parties commentées de png2avi si tout marche tjrs bien
% - Tell where folders will be created, deleted, or need to be present.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('./scripts'))
verystart = datetime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Dataset conversion  |  seq --> png
%%%%
% fprintf("--------------- Dataset conversion  |  seq --> png \n\n");
% 
% start = datetime;
% 
% inputDir  = '../dataset/seq/';
% outputDir = '../dataset/png/original';
% 
% [ runtime_seq2png, numFrameProcessed_seq2png ] = ...
%     seq2png( inputDir, outputDir, 'recursively' );
% 
% 
% elapsedTime_conversion_seq2png = datetime - start;
% 
% clear start inputDir outputDir
% fprintf("\n\n\n")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Noise simulation  |  Ed's pipeline
%%%%
% fprintf("--------------- Noise simulation  |  Ed's pipeline \n\n");
% 
% start = datetime;
% 
% inMainDir  = '../dataset/png/original';
% outMainDir = '../dataset/png/noisy';
% outSubDirs = { 'snr03/'; 'snr05/'; 'snr10/'; 'snr20/'; 'snr40/' };
% 
% [ durationPipeline, durationBackup, numFrameProcessed_noiseSimu ] = ...
%     noiseSimulation( inMainDir, outMainDir, outSubDirs);
% 
% 
% elapsedTime_noiseSimu = datetime - start;
% 
% clear start inMainDir outMainDir outSubDirs
% fprintf("\n\n\n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Noisy images conversion  |  png --> avi
%%%%
% fprintf("--------------- Noisy images conversion  |  png --> avi \n\n");
% 
% start = datetime;
% 
% inputDir  = '../dataset/png/';
% outputDir = '../dataset/avi/';
% frameRate = 30;
% 
% [ runtime_png2avi, numFrameProcessed_png2avi ] = ...
%     png2avi( inputDir, outputDir, 'recursively', frameRate );
% 
% 
% elapsedTime_conversion_png2avi = datetime - start;
% 
% clear start inputDir outputDir frameRate
% fprintf("\n\n\n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Noise estimation
%%%%
fprintf("--------------- Noise estimation \n\n");

start = datetime;

estimationDir ='../dataset/estimation';
outSubDirs    = { 'snr03/'; 'snr05/'; 'snr10/'; 'snr20/'; 'snr40/' };
reference     = '../dataset/png/original/set07/V000/I00000.png';

[ sigma, stds ] = noiseEstimation( estimationDir, outSubDirs, reference );


elapsedTime_noiseSimu = datetime - start;

clear start estimationDir outSubDirs reference
fprintf("\n\n\n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Denoising  |  CBM3D
%%%%
fprintf("--------------- Denoising  |  CBM3D \n\n");

start = datetime;

profil = 'vn'; % low complexity (lc)
               % normal profile (np)
               % vn ( best )
                
inMainDir   = '../dataset/png/noisy';
outMainDir  = ['../dataset/png/denoised/' profil '(sig=' num2str(sigma) ')'];
origMainDir = '../dataset/png/original';
logsMainDir = '../dataset/metrics/';
        


[ bm3d_totalRuntime, numOfFramesTotal, logsPSNR, logsSNR ] = ...
    cbm3dDenoising( inMainDir, outMainDir, origMainDir, logsMainDir, profil, sigma );


elapsedTime_denoising = datetime - start;

clear start inMainDir outMainDir origMainDir logsMainDir
fprintf("\n\n\n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Denoised avi conversion  |  avi --> png
%%%%
% fprintf("--------------- Denoised avi conversion  |  avi --> png \n\n");
% 
% start = datetime;
% 
% inputDir  = '../dataset/avi/denoised'; 
% outputDir = '../dataset/png/denoised';
% 
% [ runtime_avi2png, numFrameProcessed_avi2png ] = ...
%     avi2png( inputDir, outputDir, 'recursively' );
% 
% 
% elapsedTime_conversion_avi2png = datetime - start;
% 
% clear start inputDir outputDir start
% fprintf("\n\n\n");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% END
%%%%
fprintf("--------------- END \n\n");

fprintf('Elapsed time : %s \n\n', datetime - verystart);

diary off
clear verystart logsOutputDir
save(outLogName)