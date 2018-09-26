function [Dmsc_img]=Dmsc_Spat_Freq(img, Bayer_type, Pad_Factor, G_Gain, RB_Gain)
% Self-programmed code for the most basic process in: Glotzbach (2001) - A 
% method of color filter array interpolation with alias cancellation properties
% This code does not fully describe Glotzbach's processing (which involves 
% edge-detection and other processes. Instead, this code is a simple
% frequency-based method of interpolation. also referenced in  Li et al 
% (2008) - Image demosaicing: A systematic survey.
%
% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson. 
% 
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.
% 
% Inputs: 
% img is a single channel image with bayer pattern applied.
% Bayer_type is a user-specified string describing Bayer pattern used
% Pad_Factor is a user-defined constant describing level of padding 
% G_Gain is a user-defined constant describing gain on green channel
% RB_Gain is a user-defined constant describing gain on red/blur channels
% 
% Outputs: 
% Dmsc_image is the demosaiced image in RGB (double).


    % General image size calculations
    [h,w]=size(img(:,:));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               Shifts image to 'grbg', if specified as other
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % NB. Circshift can be used to shift the image to this position. If four
    % images are tested, one should come up as correct colours. 
    if strcmp(Bayer_type,'grbg')
        % do nothing (as default)
    elseif strcmp(Bayer_type,'rggb')
        img=circshift(img, [0,-1]);
    elseif strcmp(Bayer_type,'gbrg')
        img=circshift(img, [-1,-1]);
    elseif strcmp(Bayer_type,'bggr')
        img=circshift(img, [-1,0]);
    end
    
    % Checks if image is divisible by 2 to integer values, this is 
    % required for later calculation. In this case, remainder must be zero
    % when divided by value of 1.
    if rem(h/2,1) == 0  && rem(w/2,1) == 0 && h/2==w/2
        else
        disp('Terminating Demosaic script: Image is not subsamplable by value of 2, or image is not square format');
        return 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        Creating Green Filter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    % Creates blank Green low-pass filter, of same size as image
    G_Filter=zeros(h,w);
    % Gets centre height, and width
    h_c=ceil(h/2);
    w_c=ceil(w/2);
    
    % Creates bottom right quadrant only, for flipping. 
    G_Quad=zeros(h_c,h_c);
    % Fills filter with ones, for specified area
    for filt_i = 1:h_c
        for filt_j = 1:w_c
            % Top right corner
            if filt_i + filt_j <= h_c
                G_Quad(filt_i,filt_j)=1;
            else
                G_Quad(filt_i,filt_j)=0;
            end
        end
    end
    
    % Flips quadrants to create green filter 
    G_Filter(h_c+1:h,w_c+1:w)=G_Quad;
    G_Filter(1:h_c,w_c+1:w)=flip(G_Quad ,1);
    G_Filter(h_c+1:h,1:w_c)=flip(G_Quad ,2);
    % and flips TR section of green filter to create final quadrant of filter
    G_Filter(1:h_c,1:w_c)=flip(G_Filter(1:h_c,w_c+1:w),2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        Creating Red/Blue Filter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    % Creates blank Red/Blue low-pass filter, of same size as image
    RB_Filter=zeros(h,w);
    RB_Filter(h_c-ceil(h_c/2):h_c+ceil(h_c/2),w_c-ceil(w_c/2):w_c+ceil(w_c/2))=1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %          Separating R, G and B Bayer channels from Bayer Image
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Creates GRBG Bayer image, with R, G and B separated into in three channels.
    Bayer=zeros(h,w,3);  
    Bayer(1:2:h,1:2:w,2)=img(1:2:h,1:2:w);
    Bayer(1:2:h,2:2:w,1)=img(1:2:h,2:2:w);
    Bayer(2:2:h,1:2:w,3)=img(2:2:h,1:2:w);
    Bayer(2:2:h,2:2:w,2)=img(2:2:h,2:2:w);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                        Padding
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Bayer_pad=padarray(Bayer,[Pad_Factor*h Pad_Factor*w]);
    G_Filter_Pad=padarray(G_Filter,[Pad_Factor*h Pad_Factor*w]);
    RB_Filter_Pad=padarray(RB_Filter,[Pad_Factor*h Pad_Factor*w]);
    [h_pad,w_pad]=size(Bayer_pad(:,:,1));
    % Creating Bayer Interpolated matrix
    Dmsc_img=zeros(h_pad,w_pad,3);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                    Performing filtering
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GREEN Channel
    Bayer_Pad_GreenChan=Bayer_pad(:,:,2);
    GreenUnshiftedFT = fft2(Bayer_Pad_GreenChan); 
    GreenMultipliedImage=(GreenUnshiftedFT).*fftshift(G_Filter_Pad);
    IFTGreenMultipliedImage=ifft2(GreenMultipliedImage);
    max(max(IFTGreenMultipliedImage));
    GreenRealPart=real(IFTGreenMultipliedImage);

    % RED Channel
    Bayer_Pad_RedChan=Bayer_pad(:,:,1);
    RedUnshiftedFT = fft2(Bayer_Pad_RedChan); 
    RedMultipliedImage=(RedUnshiftedFT).*fftshift(RB_Filter_Pad);
    IFTRedMultipliedImage=ifft2(RedMultipliedImage);
    max(max(IFTRedMultipliedImage));
    RedRealPart=real(IFTRedMultipliedImage);
    
    % BLUE Channel
    Bayer_Pad_BlueChan=Bayer_pad(:,:,3); 
    BlueUnshiftedFT = fft2(Bayer_Pad_BlueChan); 
    BlueMultipliedImage=(BlueUnshiftedFT).*fftshift(RB_Filter_Pad);
    IFTBlueMultipliedImage=ifft2(BlueMultipliedImage);
    max(max(IFTBlueMultipliedImage));
    BlueRealPart=real(IFTBlueMultipliedImage);

    Dmsc_img(:,:,1)=(RedRealPart*RB_Gain);
    Dmsc_img(:,:,2)=(GreenRealPart*G_Gain);
    Dmsc_img(:,:,3)=(BlueRealPart*RB_Gain);
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %              Crops the padded image down if necessary
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    i_start = ceil((h_pad-h)/2); 
    i_stop = i_start + h;
    j_start = ceil((w_pad-h)/2);
    j_stop = j_start + h;
    if i_start==0
        i_start=1;
    end
    if j_start==0
        j_start=1;
    end
    Dmsc_img = Dmsc_img(i_start:i_stop, j_start:j_stop, :);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               Shifts image back to original position
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(Bayer_type,'grbg')
            % do nothing (as default)
        elseif strcmp(Bayer_type,'rggb')
            Dmsc_img=circshift(Dmsc_img, [0,1]);
        elseif strcmp(Bayer_type,'gbrg')
            Dmsc_img=circshift(Dmsc_img, [1,1]);
        elseif strcmp(Bayer_type,'bggr')
            Dmsc_img=circshift(Dmsc_img, [1,0]);
    end 