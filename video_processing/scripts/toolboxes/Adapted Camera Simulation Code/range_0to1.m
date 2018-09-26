function [im_out]=range_0to1(im_in)
% Clips an RGB double image (im_in) to be specified limits = [min max], 
% output is another RGB double image (im_out).
%
% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson. 
% 
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.

limits = [0 1];
im_out=zeros(size(im_in));
for RGB=1:3
    if max(max(im_in(:,:,RGB)))>=1
        im_out(:,:,RGB) = min(max(im_in(:,:,RGB), limits(1)), limits(2));
    elseif min(min(im_in(:,:,RGB)))<=0
        im_out(:,:,RGB) = min(max(im_in(:,:,RGB), limits(1)), limits(2));
    else
        im_out(:,:,RGB)=im_in(:,:,RGB);
    end
end