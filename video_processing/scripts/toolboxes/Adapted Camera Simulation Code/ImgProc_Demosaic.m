function [Dmsc_image]=ImgProc_Demosaic(image, Demosaic_Type, Bayer_type)
% Performs demosaicing of replicates in img.Replicates structure, according 
% to user-specified Demosaic_Type and Bayer_type 
%
% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson. 
% 
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.
%
% Inputs:
% image is a single channel image with bayer pattern applied.
% Demosaic_Type is a user-specified string describing demosaicing method
% Bayer_type is a user-specified string describing Bayer pattern used
%
% Outputs: 
% Dmsc_image is the demosaiced image in RGB (double).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Check variables, and assign defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Checks if Demosaic_Type variable has been defined, and assigns Bilinear as 
% default if necessary
if exist('Demosaic_Type', 'var')
else
    Bayer_type='Bilinear';
    disp('Demosaic_Type variable not specified, assigning Bilinear as default'); 
end

% Checks if Bayer_type variable has been defined, and assigns grbg as 
% default if necessary
if exist('Bayer_type', 'var')
else
    Bayer_type='grbg';
    disp('Bayer_type variable not specified, assigning grbg as default');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        'Malvar' Demosaicing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% as per: Malvar et al. (2004) - High quality linear interpolation for
% demosaicing of Bayer-patterned color images.

if strcmp(Demosaic_Type, 'Malvar');
    % NB. requires input uint8 image.
    if strcmp(Bayer_type,'grbg')
        Dmsc_image=double(demosaic(uint8(image*255),'grbg'));
    elseif strcmp(Bayer_type,'rggb')
        Dmsc_image=double(demosaic(uint8(image*255),'rggb'));
    elseif strcmp(Bayer_type,'gbrg')
        Dmsc_image=double(demosaic(uint8(image*255),'gbrg'));
    elseif strcmp(Bayer_type,'bggr')
        Dmsc_image=double(demosaic(uint8(image*255),'bggr'));
    end    
    % Scaling back to img type double, range between 0-1. 
    Dmsc_image=(double(Dmsc_image))/255;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                LSLCD Demosaicing (Jeon & Dubois, 2013) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% as per: Jeon & Dubous (2013) - Demosaicking of noisy Bayer-sampled color 
% images with least-squares luma-chroma demultiplexing and noise level 
% estimation

if strcmp(Demosaic_Type, 'LSLCD');
    addpath('Dmsc_LSLCD');
    if strcmp(Bayer_type,'grbg')
        [Dmsc_image]=apply_Dmsc_LSLCD_NE(image);
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        image=circshift(image, [0,-1]);
        % Applies LCLCD
        [Dmsc_image]=apply_Dmsc_LSLCD_NE(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        image=circshift(image, [-1,-1]);
        % Applies LCLCD
        [Dmsc_image]=apply_Dmsc_LSLCD_NE(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        image=circshift(image, [-1,0]);
        % Applies LCLCD
        [Dmsc_image]=apply_Dmsc_LSLCD_NE(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1, 0]);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                NAT (LDI_NAT) Demosaicing (Zhang et al., 2011) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As per: Zhang et al. (2011) - Color demosaicking by local directional 
% interpolation and nonlocal adaptive thresholding

if strcmp(Demosaic_Type, 'NAT');
    addpath('Dmsc_NAT');
    if strcmp(Bayer_type,'grbg')
        % Applies LDI_NAT
        [Dmsc_image]=nat_cdm(image);
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        image=circshift(image, [0,-1]);
        % Applies LDI_NAT
        [Dmsc_image]=nat_cdm(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        image=circshift(image, [-1,-1]);
        % Applies LDI_NAT
        [Dmsc_image]=nat_cdm(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        image=circshift(image, [-1,0]);
        % Applies LDI_NAT
        [Dmsc_image]=nat_cdm(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1, 0]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                NLM (LDI_NLM) Demosaicing (Zhang et al., 2011) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As per: Zhang et al. (2011) - Color demosaicking by local directional 
% interpolation and nonlocal adaptive thresholding

if strcmp(Demosaic_Type, 'NLM');
    addpath('Dmsc_NLM');
    if strcmp(Bayer_type,'grbg')
        % Applies LDI_NLM
        [Dmsc_image]=nlm_cdm(image);
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        image=circshift(image, [0,-1]);
        % Applies LDI_NLM
        [Dmsc_image]=nlm_cdm(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        image=circshift(image, [-1,-1]);
        % Applies LDI_NLM
        [Dmsc_image]=nlm_cdm(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        image=circshift(image, [-1,0]);
        % Applies LDI_NLM
        [Dmsc_image]=nlm_cdm(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1, 0]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                AP (Alternate_Projections) Demosaicing (Gunturk, 2002)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As per: Gunturk et al. (2002) - Color plane interpolation using alternating 
% projections

if strcmp(Demosaic_Type, 'AP');
    addpath('Dmsc_AP');
    % Demosaicing Using Alternating Projections
    % Specifies number of iterations
    N_iter = 5;
    % Specifies threshold
    T = 0.02;
    if strcmp(Bayer_type,'grbg')
        % Applies AP
        [Dmsc_image]=Dmsc_AP(image, N_iter, T);
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        image=circshift(image, [0,-1]);
        % Applies AP
        [Dmsc_image]=Dmsc_AP(image, N_iter, T);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        image=circshift(image, [-1,-1]);
        % Applies AP
        [Dmsc_image]=Dmsc_AP(image, N_iter, T);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        image=circshift(image, [-1,0]);
        % Applies AP
        [Dmsc_image]=Dmsc_AP(image, N_iter, T);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1, 0]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       OSAP (One Step Alternating Projections) Demosaicing (Lu et al., 2010)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As per: One Step Alternating Projections, as per Lu et al.
% (2010) - 'Demosaicking by alternating projections: Theory and fast 
% one-step implementationber of iterations'.

if strcmp(Demosaic_Type, 'OSAP');
    addpath('Dmsc_OSAP');
    % applies OSAP demosaicing
    [Dmsc_image]=Dmsc_OSAP(image,Bayer_type); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      PDF (Posterior Directional filtering) Demosaicing (Menon., 2007) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As per: Menon et al. (2007) - 'Demosaicing with directional filtering 
% and a posteriori decision'.

if strcmp(Demosaic_Type, 'PDF');
    addpath('Dmsc_PDF');
    % Specifies bits per pixel
    bpp=8;
    % Multiplies image by 255 to avoid clipping of RGB values
    image=image*255;
    if strcmp(Bayer_type,'grbg')
        % Applies PDF
        [Dmsc_image]=Dmsc_PDF_DmscProc(image,bpp);
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        image=circshift(image, [0,-1]);
        % Applies PDF
        [Dmsc_image]=Dmsc_PDF_DmscProc(image,bpp);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        image=circshift(image, [-1,-1]);
        % Applies PDF
        [Dmsc_image]=Dmsc_PDF_DmscProc(image,bpp);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        image=circshift(image, [-1,0]);
        % Applies PDF
        [Dmsc_image]=Dmsc_PDF_DmscProc(image,bpp);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1, 0]);
    end
    % Divides by 255, cancelling the previous multiplication. 
    Dmsc_image=Dmsc_image/255;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                'Bilinear_Conv' Demosaicing (Gunturk., 2002) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performs Bilinear demosaicing by convolution, instead of looped pixel to
% pixel multiplication. Coded by B. Gunturk, and referenced in code for
% Gunturk et al. (2002) - Color Plane Interpolation Using Alternating 
% Projections

if strcmp(Demosaic_Type, 'Bilinear_Conv');
    addpath('Dmsc_Bilinear_Conv');
    if strcmp(Bayer_type,'grbg')
        [Dmsc_image]=Dmsc_Bilinear_Conv(image);
    elseif strcmp(Bayer_type,'rggb')
        % Circshifts
        image=circshift(image, [0,-1]);
        % Applies LCLCD
        [Dmsc_image]=Dmsc_Bilinear_Conv(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [0, 1]);
    elseif strcmp(Bayer_type,'gbrg')
        % Circshifts
        image=circshift(image, [-1,-1]);
        % Applies LCLCD
        [Dmsc_image]=Dmsc_Bilinear_Conv(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1,1]);
    elseif strcmp(Bayer_type,'bggr')
        % Circshifts
        image=circshift(image, [-1,0]);
        % Applies LCLCD
        [Dmsc_image]=Dmsc_Bilinear_Conv(image);
        % Circshifts back to orig position
        Dmsc_image=circshift(Dmsc_image, [1, 0]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        'Bilinear' Demosaicing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-programmed Bilinear demosaicing by looped pixel to pixel multiplication.
% NB. slower than the convolution method used in 'Bilinear_Conv',
% although results are identical.

if strcmp(Demosaic_Type, 'Bilinear');
    addpath('Dmsc_Bilinear');
    % Applies Bilinear demosaic
    [Dmsc_image]=Dmsc_Bilinear(image,Bayer_type);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        'Kriss' Demosaicing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-programmed demosaicing by looped pixel to pixel multiplication, with
% comparison of horizontal, vertical and diagonal pixel values, as
% described in p58 of: Kriss (2015) - Color Reproduction for Digital
% Cameras, in Handbook of Digital Imaging (ed. Kriss).

if strcmp(Demosaic_Type, 'Kriss');
    addpath('Dmsc_Kriss');
    % Applies Bilinear demosaic
    [Dmsc_image]=Dmsc_Kriss(image,Bayer_type);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Glotzbach_Basic Demosaicing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-programmed code for the most basic process in: Glotzbach (2001) - A 
% method of color filter array interpolation with alias cancellation properties
% This code does not fully describe Glotzbach's processing (which involves 
% edge-detection and other processes. Instead, this code is a simple
% frequency-based method of interpolation. also referenced in  Li et al 
% (2008) - Image demosaicing: A systematic survey.

if strcmp(Demosaic_Type, 'Glotzbach_Basic');
    addpath('Dmsc_Glotzbach_Basic');
    % Defines constants
    Pad_Factor=0;
    G_Gain=2;
    RB_Gain=4;
    % Runs processing
    [Dmsc_image]=Dmsc_Spat_Freq(image, Bayer_type, Pad_Factor, G_Gain, RB_Gain);
end

     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Glotzbach_Full Demosaicing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-programmed code for full process, as described in: 
% Glotzbach (2001) - A method of color filter array interpolation with  
% Also referenced in the following paper, with diagrams: 
% Li et al (2008) - Image demosaicing: A systematic survey

if strcmp(Demosaic_Type, 'Glotzbach_Full');  
    addpath('Dmsc_Glotzbach_Full');
    % Defines constants
    Pad_Factor=0;
    G_Gain=2;
    RB_Gain=4;
    % Runs processing
    [Dmsc_image]=Dmsc_Glotzbach(image, Bayer_type, Pad_Factor, G_Gain, RB_Gain);
end 


  
    

