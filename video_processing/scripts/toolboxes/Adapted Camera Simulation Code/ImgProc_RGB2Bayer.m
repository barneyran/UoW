function [Bayer]=ImgProc_RGB2Bayer(img, Bayer_type)
% Converts RGB 3 channel image into single channel Bayer image, according 
% to specified Bayer_type string 

% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk
%
% Inputs:
% img is a 3 channel RGB image
% Bayer_type is a user-specified string describing Bayer pattern used
% Outputs:
% Bayer is the resultant single channel Bayer image, after processing.

%General dimensions etc
[h,w]=size(img(:,:,1)); Bayer=zeros(h,w); Pttn=zeros(h,w);

% Checks if Bayer_type variable has been defined, and assigns grbg as 
% default if necessary
if exist('Bayer_type', 'var')
else
    Bayer_type='grbg';
end

% Creates GRBG Bayer image, Position is G1 pixel in top left corner. As in TL==2 below.
if strcmp(Bayer_type,'grbg')  
    Pttn(1:2:h,1:2:w)=2; %G1
    Pttn(1:2:h,2:2:w)=1; %R  
    Pttn(2:2:h,1:2:w)=4; %B 
    Pttn(2:2:h,2:2:w)=3; %G2   
    Bayer(1:2:h,1:2:w)=img(1:2:h,1:2:w,2);
    Bayer(1:2:h,2:2:w)=img(1:2:h,2:2:w,1);
    Bayer(2:2:h,1:2:w)=img(2:2:h,1:2:w,3);
    Bayer(2:2:h,2:2:w)=img(2:2:h,2:2:w,2);
end

% Creates RGGB Bayer image, 
if strcmp(Bayer_type,'rggb')
    Pttn(1:2:h,1:2:w)=1; %R
    Pttn(1:2:h,2:2:w)=2; %G1
    Pttn(2:2:h,1:2:w)=3; %G2  
    Pttn(2:2:h,2:2:w)=4; %B 
    Bayer(1:2:h,1:2:w)=img(1:2:h,1:2:w,1);
    Bayer(1:2:h,2:2:w)=img(1:2:h,2:2:w,2);
    Bayer(2:2:h,1:2:w)=img(2:2:h,1:2:w,2);
    Bayer(2:2:h,2:2:w)=img(2:2:h,2:2:w,3);
end

% Creates GBRG Bayer image, 
if strcmp(Bayer_type,'gbrg')
    Pttn(1:2:h,1:2:w)=3; %G2  
    Pttn(1:2:h,2:2:w)=4; %B
    Pttn(2:2:h,1:2:w)=1; %R
    Pttn(2:2:h,2:2:w)=2; %G1  
    Bayer(1:2:h,1:2:w)=img(1:2:h,1:2:w,2);
    Bayer(1:2:h,2:2:w)=img(1:2:h,2:2:w,3);
    Bayer(2:2:h,1:2:w)=img(2:2:h,1:2:w,1);
    Bayer(2:2:h,2:2:w)=img(2:2:h,2:2:w,2);
end

% Creates BGGR Bayer image, 
if strcmp(Bayer_type,'bggr')
    Pttn(1:2:h,1:2:w)=4; %B
    Pttn(1:2:h,2:2:w)=3; %G2
    Pttn(2:2:h,1:2:w)=2; %G1
    Pttn(2:2:h,2:2:w)=1; %R
    Bayer(1:2:h,1:2:w)=img(1:2:h,1:2:w,3);
    Bayer(1:2:h,2:2:w)=img(1:2:h,2:2:w,2);
    Bayer(2:2:h,1:2:w)=img(2:2:h,1:2:w,2);
    Bayer(2:2:h,2:2:w)=img(2:2:h,2:2:w,1);
end
