% Demosaicking of Noisy Bayer-Sampled Color Images with Least-Squares
% Luma-Chroma Demultiplexing and Noise Level Estimation
%
% Perform demosaicking on the Kodak image set using one single filter 
% package with the intent to generate the actual demosaicked images
% 
% IEEE Trans. Image Processing (submitted)
% This software is for provided for non-commercial and research purposes only
% Copyright Eric Dubois (edubois@site.uottawa.ca), University of Ottawa 2011 
% *****************

% Adapted by Ed Fry on 2016.09.06, for purposes of capture systems simulation.
% All elements creating CFA image with noise are bypassed. 
% CFAN is essentially the input image, all noise values are estimated from
% thereon, and sigma and frame constants are not required. 

% Input variables:
% CFAN - image with CFA and additive noise accounted for
% CAorEA - noise level estimation parameters 
% KorL = 'K' specified by default;

% Output variables:
% ESTM - demosaiced and noise reduced image.

function [ESTM]=apply_Dmsc_LSLCD_NE(CFAN)


%{
% Initialize MATLAB Workspace
clc; clear all; close all;
%}
%{
% Setup frame size when computing MSE/PSNR
frame = 11; 

% added noise sigma 
sigma = 10;
%}

% noise level estimation parameters 
CAorEA = 'CA';
% CAorEA = 'EA';

KorL = 'K';
% KorL = 'L';

%{
% Implementation
image_fname='Kodak/19.tiff';
ORIG = im2double(imread(image_fname));
CFAN = Dmsc_LSLCD_create_CFAN(ORIG, sigma);
%}





% NOISE ESTIMATION STAGES
esigma = Dmsc_LSLCD_ENL(CFAN, CAorEA, KorL);
resigma = 2*round(esigma/2);

% Select h1 h2a h2b filter
%     % LSLCD-NE algorithm using 11x11 $f_{ST}$
%     filtername = sprintf('filters\\filters_RGB_ST\\filters_RGB_im%02d_sigma%02d%s',19,resigma,'.mat');
    % LSLCD-NE algorithm using 'filtersize'x'filtersize' $f_{GT}$
    filtersize = 13; filtername = sprintf('Dmsc_LSLCD_filters/filters_RGB_GT/filters_RGB_%02dx%02d_GT_sigma%02d%s',filtersize,filtersize,resigma,'.mat');

% Load filter 
load(filtername)

% Load Gaussian filter
load('Dmsc_LSLCD_filters/GF/GF.mat');

% Prepare the filter package
fpkg = 'fpkg.mat';
save(fpkg,'h1','h2a','h2b','hG1','hG2','hL');
clear h1 h2a h2b hG1 hG2 hL;

% luma component denoising
selectlcdmethod = 1;        % 'hL' 
% selectlcdmethod = 2;      % 'BM3D'

ESTM = Dmsc_LSLCD_NE(CFAN,fpkg,resigma,selectlcdmethod);

%imwrite(ESTM, '19_out.tiff');

delete(fpkg);
