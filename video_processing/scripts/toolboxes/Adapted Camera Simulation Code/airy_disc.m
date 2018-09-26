function outputimg = airy_disc(wavelength,f_number,pixels, distance)
 
% Airy disc generation
%
% Robin Jenkin
% Feb 2009
%
% (c) 2009 Aptina Imaging
 
% Approximates an Airy Disc with a equal volume gaussian for use in convolution.
%
% wavelength is the wavelength of light in meters
% f_number is the f_number of the lens
% pixels is the number of pixels for output (x by x)
% distance is the distance in meters to output (-distance/2 to distance/2)
% Try 
% a=airy(450e-9,2,100,1500e-9); a=a./max(max(a)); imshow(a);
 
%------------------------------------------------------------------------
% Define some parameters
%------------------------------------------------------------------------
 
if (nargin == 0)
    wavelength = 550e-9;
    f_number = 2;
    pixels=100;
    distance = 1500e-9;
end
 
%Calculate width of equal volume gaussian...
w = 0.44 * wavelength * f_number;
 
%------------------------------------------------------------------------
% Create coordinates of Disc
%------------------------------------------------------------------------
 
%xx = -(distance/2):(distance)/(pixels-1):(distance/2);
xx=1:pixels;
xx= xx - (pixels/2) -0.5;
xx = xx .* (distance/(pixels));
%disp(xx)
len_x = length(xx);
X = repmat(xx,len_x,1);
Y = X';
 
D=sqrt(X.^2 + Y.^2);
 
%------------------------------------------------------------------------
% Create Airy Disc
%------------------------------------------------------------------------
 
D = D.^2;
w = 2*w^2;
 
outputimg = exp(-D./w);
outputimg = outputimg ./ sum(sum(outputimg));