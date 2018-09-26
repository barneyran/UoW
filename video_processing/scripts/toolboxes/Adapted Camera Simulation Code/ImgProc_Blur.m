function [img, PSF]=ImgProc_Blur(img, Blur_Type, System, Num_Reps)
% Blurs image according to specified Blur_Type. 

% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.
%
% Inputs:
% img is a structure containing original images, replicates and other 
    % information
% Blur_Type is a string that specifies type of blur 
% System is a structure describing all physical camera/module dimensions &
    % characteristics.
% Num_Reps is the number of replicates to be processed
%
% Outputs:
% img is a structure containing original images, replicates and other 
    % information
% PSF is the point spread function

    if strcmp(Blur_Type,'Gaussian')
        %%% *******TUNING PARAMETER******, %%%
        PSF = fspecial('gaussian', [5 5], 0.7);
%         disp('Applying basic Gaussian blurring')
        img.Blur.Gauss=img.Replicates;
        for rep=1:Num_Reps
            img.Blur.Gauss{rep}=imfilter(img.Replicates{rep},PSF,'circular');
        end
    elseif strcmp(Blur_Type,'None')
        disp('User specified for zero blur to be added to image')
        img.Blur.Gauss=img.Replicates;
    elseif strcmp(Blur_Type,'Diff_Limited')
%         disp('Applying diffraction limited Gaussian model blur')
        % Blurs by convolving with Gaussian approximation of Airy Disc 
        % i.e. PSF for diffraction limited lens at specified wavelength, 
        % F number, and pixel dimensions. Code from Jenkin (2009).
        % First creates PSF of size specified by 'System.PSF_Knl_NoOfPixels' 
        % parameter, and according to peak wavelength of RGB channels, modeled 
        % by a Gaussian approximation [Code from Jenkin (2009].
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Camera equation can be implemented here, but not strictly necessary
        % img.Blur.Post_Cam_EQ=Camera_Equation(img.Orig,System.FNumber,1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PSF=zeros(System.PSF_Knl_NoOfPixels,System.PSF_Knl_NoOfPixels,3);
        for RGB=1:3
        PSF(:,:,RGB)=airy_disc(System.PeakRGBWvlngth(RGB),System.FNumber,...
            System.PSF_Knl_NoOfPixels, System.PSF_Knl_Dims);
        end
        % Convolves image with PSF in 3 dimensions independently.
%         disp('Convolving with airy-disc approximation from diffraction limited lens')
        % Defines img.Blur.Gauss cell
        img.Blur.Gauss=img.Replicates;
        for rep=1:Num_Reps 
            for RGB=1:3
                img.Blur.Gauss{rep}(:,:,RGB)=...
                    imfilter(img.Replicates{rep}(:,:,RGB),PSF(:,:,RGB),...
                    'circular');
            end
        end
    else
        disp('No image Blur_Type specified, Applying simple Gaussian blurring by default')
        %%% *******TUNING PARAMETER******, %%%
        PSF = fspecial('gaussian', [5 5], 0.7);
        img.Blur.Gauss=img.Replicates;
        for rep=1:Num_Reps
            img.Blur.Gauss{rep}=imfilter(img.Replicates{rep},PSF,'circular');
        end
    end