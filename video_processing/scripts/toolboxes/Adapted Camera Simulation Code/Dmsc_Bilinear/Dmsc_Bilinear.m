function [Dmsc_img]=Dmsc_Bilinear(img,Bayer_type)
% Applies Bilinear demosaic according to specified Bayer_type string.
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
%
% Outputs:
% Dmsc_image is the demosaiced image in RGB (double).




    % General image size calculations
    [h,w]=size(img(:,:,1));
    Bayer.Pttn=zeros(h,w);
    Dmsc_img=zeros(h,w,3);

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               Performing bilinear interpolation 'grbg'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Bilinear interpolation of green channel pixels corresponding to 
    % G1 & G2 can be extracted directly

    Dmsc_img(1:2:h,1:2:w,2)=img(1:2:h,1:2:w);
    Dmsc_img(2:2:h,2:2:w,2)=img(2:2:h,2:2:w);

    % Green values at red pixels need to be looped
    for i=3:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
         for j=2:2:w-1
            Dmsc_img(i,j,2)=1/4*(img(i,j-1)+img(i,j+1)+...
            img(i-1,j)+img(i+1,j));
         end
    end
    % Green values at blue pixels
    for i=2:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
         for j=3:2:w-1
            Dmsc_img(i,j,2)=1/4*(img(i,j-1)+img(i,j+1)+...
            img(i-1,j)+img(i+1,j));
         end
    end

    % Bilinear interpolation of red channel pixels
    % Red values at red pixels
    Dmsc_img(1:2:h,2:2:w,1)=img(1:2:h,2:2:w);
    % Red values at blue pixels
    for i=2:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
         for j=3:2:w-1
            Dmsc_img(i,j,1)=1/4*(img(i-1,j-1)+img(i+1,j+1)+...
            img(i-1,j+1)+img(i+1,j-1));
         end
    end
    % Red values at G1 pixels
    for i=3:2:h-1
        for j=3:2:w-1
            Dmsc_img(i,j,1)=1/2*(img(i,j-1)+img(i,j+1));
        end
    end
    % Red values at G2 pixels
    for i=2:2:h-1
        for j=2:2:w-1
            Dmsc_img(i,j,1)=1/2*(img(i-1,j)+img(i+1,j));
        end
    end

    % Bilinear interpolation of blue channel pixels
    % Blue values at blue pixels
    Dmsc_img(2:2:h,1:2:w,3)=img(2:2:h,1:2:w);
    % Blue values at red pixels
    for i=3:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
         for j=2:2:w-1
            Dmsc_img(i,j,3)=1/4*(img(i-1,j-1)+img(i+1,j+1)+...
            img(i-1,j+1)+img(i+1,j-1));
         end
    end
        % Blue values at G1 pixels
    for i=3:2:h-1
        for j=3:2:w-1
            Dmsc_img(i,j,3)=1/2*(img(i-1,j)+img(i+1,j));
        end
    end
        % blue values at G2 pixels
    for i=2:2:h-1
        for j=2:2:w-1
            Dmsc_img(i,j,3)=1/2*(img(i,j-1)+img(i,j+1));
        end
    end

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
  