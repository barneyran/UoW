function [j, k, l, Img_Cell, ID_Cell, Orig_Img_Cell, All_Imgs,...
    All_Orig_Imgs, All_IDs, K_Values]=Create_Working_Cells(NR_Type,...
    Shrpn_Type, TM_Type, num_images, Num_Reps, No_of_SNRs)
% Creates all cell arrays used during simulation workflow, and output. 

% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk. 

% Inputs:
% NR_Type is a user-specified string describing noise reduction method
% Shrpn_Type is a user-specified string describing sharpening method
% TM_Type is a user-specified string describing tone-mapping method
% num_images is the total number of images to be processed
% Num_Reps is the total number of replicates (user-specified)
% No_of_SNRs is the total number of SNR levels to be tested

% Outputs:
% j specifies noise reduction dimension of working and output cells.
% k specifies sharpening dimension of working and output cells.
% l specifies tone mapping dimension of working and output cells. 
% Img_Cell is a cell array containing processed image replicates
% ID_Cell is a cell array containing image information
% Orig_Img_Cell is a cell array containing unprocessed images
% All_Imgs is an output cell array containing all processed images
% All_Orig_Imgs is an output cell array containing unprocessed images in
    % same order as All_Imgs first dimension
% All_IDs is an output cell array containing all image information
% K_Values is a cell containing constants for noise simulation

% Gets cell dimensions according to specifications of user
[j,k,l]=specify_cell_dims(NR_Type, Shrpn_Type, TM_Type);

% Defines size of Img_Cell and ID_Cell working cells
% NB. Dimensions are specified in each output {rep, i, j, k, l} cell array: 
% rep = replicate number (i.e. Num_Reps)
% i = SNR level dimension (i.e. signal to noise ratio)
% j = Noise Reduction dimension (off = 1, on = 2)
% k = Sharpen/deblur dimension (off = 1, on = 2)
% l = Tone Mapping dimension (off = 1, on = 2)
Img_Cell=cell(Num_Reps,No_of_SNRs,j,k,l);
ID_Cell=Img_Cell;
Orig_Img_Cell=cell(Num_Reps,1);

% Defines size of final output cell arrays, containing all replicates
% (dimension 2), of all input images (dimension 1)
% NB. These final output cell arrays (eg. All_Imgs and All_IDs) will also include a 
% further first dimension populated by the input image number: 'p_im'. 
% eg. All_Imgs{p_im, rep, i, j, k, l}
All_Imgs{num_images,:,:,:,:,:}=Img_Cell;
All_Orig_Imgs=cell(num_images,1);
All_IDs=All_Imgs;

% PREVIOUS, ERROR
%K_Values=cell(num_images,3,5);
K_Values=cell(num_images,3,No_of_SNRs);

% PREVIOUS CODE - JUST COPY AND PASTE INTO AAA_ORIGINAL_RUNCODE_FILE in
% place of this function.
%{
% Specifies the  dimensions in each output {rep, i, j, k, l} cell array 
% rep = replicate number (i.e. Num_Reps)
% i = SNR level dimension (i.e. signal to noise ratio)
% j = Noise Reduction dimension (off = 1, on = 2)
% k = Sharpen/deblur dimension (off = 1, on = 2)
% l = Tone Mapping dimension (off = 1, on = 2)
% Final output cell arrays (eg. All_Imgs and All_IDs) will also include a 
% further first dimension populated by the input image number: 'p_im'. 
% eg. All_Imgs{p_im, rep, i, j, k, l}
[j,k,l]=specify_cell_dims(NR_Type, Shrpn_Type, TM_Type);

% Defines size of Img_Cell and ID_Cell according to specifications
Img_Cell=cell(Num_Reps,No_of_SNRs,j,k,l);
ID_Cell=Img_Cell;
Orig_Img_Cell=cell(Num_Reps,1);
% Defines size of final output cell arrays, containing all replicates
% (dimension 2), of all input images (dimension 1)
All_Imgs{num_images,:,:,:,:,:}=Img_Cell;
All_Orig_Imgs{num_images,:}=Orig_Img_Cell;
All_IDs=All_Imgs;
K_Values=cell(num_images,3,5);
%}