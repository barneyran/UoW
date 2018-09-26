function [j,k,l]=specify_cell_dims(NR_Type, Shrpn_Type, TM_Type)
% This function automatically specifys working and output cell dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specifies the  dimensions in each output {rep, i, j, k, l} cell array 
% rep = replicate number (i.e. Num_Reps)
% i = SNR level dimension (i.e. signal to noise ratio)
% j = Noise Reduction dimension (off = 1, on = 2)
% k = Sharpen/deblur dimension (off = 1, on = 2)
% l = Tone Mapping dimension (off = 1, on = 2)
% Final output cell arrays (eg. All_Imgs and All_IDs) will also include a 
% further first dimension populated by the input image number: 'p_im'. 
% eg. All_Imgs{p_im, rep, i, j, k, l}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.  
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.
%
% Inputs:
% NR_Type is a user-specified string describing noise reduction method
% Shrpn_Type is a user-specified string describing sharpening method
% TM_Type is a user-specified string describing tone-mapping method
% 
% Outputs:
% j determines cell noise reduction dimension (off = 1, on = 2)
% k determines cell sharpening dimension (off = 1, on = 2)
% l determines cell tone mapping dimension (off = 1, on = 2)

    % NOISE REDUCTION: Specifies dimension j of output cells
    NR_Types={'Median', 'Gaussian', 'Bilateral', 'FBF', 'FOE', 'GIF',...
        'GLAS','GLNM','BM3D','Luo','SADCT_W','DDID','SAIST','Zoran','Sigma'};
    if strmatch(NR_Type,NR_Types)>=1
        j=2;
    else
        j=1;
    end
    
     % DEBLUR/SHARPEN: Specifies dimension k of output cells
    Shrpn_Types={'USM', 'MATLAB_USM', 'USM_MDN', 'USM_AMDN', 'USM_BLTRL', 'USM_GF',...
        'USM_DENG','USM_RTNL','AMF','GIF','GLAS','WLS'};
    if strmatch(Shrpn_Type,Shrpn_Types)>=1
        k=2;
    else
        k=1;
    end
   
    % TONE MAPPING: Specifies dimension l of output cells
    TM_Types={'HISTEQ', 'ADAPTHISTEQ', 'IMADJUST', 'Moroney', 'Capra'};
    if strmatch(TM_Type,TM_Types)>=1
        l=2;
    else
        l=1;
    end