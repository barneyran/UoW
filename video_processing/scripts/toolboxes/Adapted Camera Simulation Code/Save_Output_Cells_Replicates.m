function []=Save_Output_Cells_Replicates(out_path, All_Imgs, All_IDs, All_Orig_Imgs, All_Noise)
% Saves output cells, when replicates method is toggled on.
%
% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson. 
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.
%
% Inputs:
% out_path is path of output image folder
% All_Imgs is an output cell array containing all processed images
% All_IDs is an output cell array containing all image information
% All_Orig_Imgs is an output cell array containing unprocessed images in
% same order as All_Imgs first dimension
% All_Noise is an output cell array containing noise images calculated from 
% image replicates in same order as All_Imgs first dimension

disp('Saving All Images ');
save([out_path 'AA_All_Imgs' '.mat'], 'All_Imgs');
save([out_path 'AA_All_IDs' '.mat'], 'All_IDs');
disp('Saving All Original Images ');
save([out_path 'AA_All_Orig_Imgs' '.mat'], 'All_Orig_Imgs');
disp('Saving All Noise ');
save([out_path 'AA_All_Noise' '.mat'], 'All_Noise');




