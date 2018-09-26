function [Dmsc_img]=Dmsc_Kriss(img,Bayer_type)
% Performs interpolation as described by Kriss (2015) - Color 
% Reproduction for Digital Cameras, employing logical evaluation of
% each channel, by comparing gradients across pixels, and only using
% information from low gradients. This means that edges are preserved
% in both directions. Green pixels compute horiz and vert gradients,
% Red, and Blue pixels also compute diagonal components.

% General image size calculations
[h,w]=size(img(:,:,1));
%Bayer.Pttn=zeros(h,w);
Dmsc_img=zeros(h,w,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Shifts image to 'grbg', if specified as other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%               Performing Kriss interpolation 'grbg'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sets threshold for image pixel gradient comparison, high values mean
% that edges are less likely to be preserved. Low values mean noise is
% more likely to be introduced.
Thrsh=0.5;

%%%%%%%%%%%%%%%%%%%%%%% Green Channel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Kriss interpolation of green channel pixels corresponding to 
% G1 & G2 can be extracted directly

Dmsc_img(1:2:h,1:2:w,2)=img(1:2:h,1:2:w);
Dmsc_img(2:2:h,2:2:w,2)=img(2:2:h,2:2:w);

% Green values at red pixels need to be looped
for i=3:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
     for j=2:2:w-1
        % finds vertical difference
        diff.vert=max(img(i-1,j)-img(i+1,j),img(i+1,j)-img(i-1,j));
        % finds horizontal difference
        diff.horiz=max(img(i,j-1)-img(i,j+1),img(i,j+1)-img(i,j-1));
        % compares gradients
        if diff.horiz>=diff.vert && diff.horiz<=Thrsh && diff.vert<=Thrsh
            % if horizontal difference is greater than vertical, and 
            % both horiz and vert diffs are lower than threshold, 
            % assigns vertical average of pixels
            Dmsc_img(i,j,2)=1/2*(img(i-1,j)+img(i+1,j));
        elseif diff.vert>=diff.horiz && diff.horiz<=Thrsh && diff.vert<=Thrsh
            % if vertical gradient is greater than horizontal by threshold 
             % Thrsh, assigns horizontal average of pixels
            Dmsc_img(i,j,2)=1/2*(img(i,j-1)+img(i,j+1));
        else
            % if neither gradient is greater than the 
            % other, or either are very large, computes average across all pixels.
            Dmsc_img(i,j,2)=1/4*(img(i,j-1)+img(i,j+1)+...
            img(i-1,j)+img(i+1,j));
        end    
     end
end
% Green values at blue pixels
for i=2:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
     for j=3:2:w-1
        % finds vertical difference
        diff.vert=max(img(i-1,j)-img(i+1,j),img(i+1,j)-img(i-1,j));
        % finds horizontal difference
        diff.horiz=max(img(i,j-1)-img(i,j+1),img(i,j+1)-img(i,j-1));
        % compares gradients
        if diff.horiz>=diff.vert && diff.horiz<=Thrsh && diff.vert<=Thrsh
            % if horizontal difference is greater than vertical, and 
            % both horiz and vert diffs are lower than threshold, 
            % assigns vertical average of pixels
            Dmsc_img(i,j,2)=1/2*(img(i-1,j)+img(i+1,j));
        elseif diff.vert>=diff.horiz && diff.horiz<=Thrsh && diff.vert<=Thrsh
            % if vertical gradient is greater than horizontal by threshold 
             % Thrsh, assigns horizontal average of pixels
            Dmsc_img(i,j,2)=1/2*(img(i,j-1)+img(i,j+1));
        else
            % if neither gradient is greater than the 
            % other, or either are very large, computes average across all pixels.
            Dmsc_img(i,j,2)=1/4*(img(i,j-1)+img(i,j+1)+...
            img(i-1,j)+img(i+1,j));
        end
     end
end

 % Kriss interpolation of red channel pixels
% Red values at red pixels
Dmsc_img(1:2:h,2:2:w,1)=img(1:2:h,2:2:w);
% Red values at blue pixels
for i=2:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
     for j=3:2:w-1
        % finds TL_BR diagonal difference
        diff.TL_BR=max(img(i-1,j-1)-img(i+1,j+1),img(i+1,j+1)-img(i-1,j-1));
        % finds TR_BL diagonal  difference
        diff.TR_BL=max(img(i-1,j+1)-img(i+1,j-1),img(i+1,j-1)-img(i-1,j+1));
        % compares gradients
        if diff.TL_BR>=diff.TR_BL && diff.TL_BR<=Thrsh && diff.TR_BL<=Thrsh
            % if TL_BR difference is greater than TR_BL, and 
            % both TL_BR and TR_BL diffs are lower than threshold, 
            % assigns TR_BL average of pixels
            Dmsc_img(i,j,1)=1/2*(img(i-1,j+1)+img(i+1,j-1));
        elseif diff.TR_BL>=diff.TL_BR && diff.TL_BR<=Thrsh && diff.TR_BL<=Thrsh
            % if TR_BL gradient is greater than TL_BR by threshold 
             % Thrsh, assigns TL_BR average of pixels
            Dmsc_img(i,j,1)=1/2*(img(i-1,j-1)+img(i+1,j+1));
        else
            % if neither gradient is greater than the 
            % other, or either are very large, computes average across all pixels.
            Dmsc_img(i,j,1)=1/4*(img(i-1,j+1)+img(i+1,j-1)+...
            img(i-1,j-1)+img(i+1,j+1)); 
        end 
        %Bayer_Interpolated(i,j,1)=1/4*(img(i-1,j-1)+img(i+1,j+1)+...
        %img(i-1,j+1)+img(i+1,j-1));
     end
end

% Red values at G1 (GR) pixels
for i=3:2:h-1
    for j=3:2:w-1
        Dmsc_img(i,j,1)=1/2*(img(i,j-1)+img(i,j+1));
    end
end
% Red values at G2 (GB) pixels
for i=2:2:h-1
    for j=2:2:w-1
        Dmsc_img(i,j,1)=1/2*(img(i-1,j)+img(i+1,j));
    end
end


 %%%%%%%%%%%%%%%%%%%%%%% Blue Channel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bilinear interpolation of blue channel pixels
% Blue values at blue pixels
Dmsc_img(2:2:h,1:2:w,3)=img(2:2:h,1:2:w);
% Blue values at red pixels
for i=3:2:h-1 %NB starts at 3 and ends at w-1 or h-1 to avoid overlapping edge
     for j=2:2:w-1
        % finds TL_BR diagonal difference
        diff.TL_BR=max(img(i-1,j-1)-img(i+1,j+1),img(i+1,j+1)-img(i-1,j-1));
        % finds TR_BL diagonal  difference
        diff.TR_BL=max(img(i-1,j+1)-img(i+1,j-1),img(i+1,j-1)-img(i-1,j+1));
        % compares gradients
        if diff.TL_BR>=diff.TR_BL && diff.TL_BR<=Thrsh && diff.TR_BL<=Thrsh
            % if TL_BR difference is greater than TR_BL, and 
            % both TL_BR and TR_BL diffs are lower than threshold, 
            % assigns TR_BL average of pixels
            Dmsc_img(i,j,3)=1/2*(img(i-1,j+1)+img(i+1,j-1));
        elseif diff.TR_BL>=diff.TL_BR && diff.TL_BR<=Thrsh && diff.TR_BL<=Thrsh
            % if TR_BL gradient is greater than TL_BR by threshold 
             % Thrsh, assigns TL_BR average of pixels
            Dmsc_img(i,j,3)=1/2*(img(i-1,j-1)+img(i+1,j+1));
        else
            % if neither gradient is greater than the 
            % other, or either are very large, computes average across all pixels.
            Dmsc_img(i,j,3)=1/4*(img(i-1,j+1)+img(i+1,j-1)+...
            img(i-1,j-1)+img(i+1,j+1)); 
        end 
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
