function [All_Imgs,All_IDs, All_Orig_Imgs]=Assemble_Output_Cells(Img_Cell,...
    ID_Cell, Orig_Img_Cell, p_im, All_Imgs,All_IDs, All_Orig_Imgs)
% Assembling cell arrays for all images in input folder, containing all
% replicates of each image.

% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.

% Inputs:
% Img_Cell is a cell array containing processed image replicates
% ID_Cell is a cell array containing image information
% Orig_Img_Cell is a cell array containing unprocessed images
% p_im is the image number used in the main loop (in order alphabetically)
% All_Imgs is an output cell array containing all processed images
% All_IDs is an output cell array containing all image information
% All_Orig_Imgs is an output cell array containing unprocessed images in
    % same order as All_Imgs first dimension

% Outputs:
% All_Imgs is an output cell array containing all processed images
% All_IDs is an output cell array containing all image information
% All_Orig_Imgs is an output cell array containing unprocessed images in
    % same order as All_Imgs first dimension

% Copies Orig_Img_Cell info into All_Orig_Imgs cell array
All_Orig_Imgs{p_im}=Orig_Img_Cell{1};

% Loops for all replicates
for reps=1:numel(Img_Cell(:,1,1,1,1))

    % Loops for all SNRs
    for i=1:numel(Img_Cell(reps,:,1,1,1))
        % Loops for j (Noise Reduction)
        for j=1:numel(Img_Cell(reps,i,:,1,1))
            % Loops for k (Sharpening/Deblur)
            for k=1:numel(Img_Cell(reps,i,j,:,1))
                % Loops for l (Tone Mapping)
                for l=1:numel(Img_Cell(reps,i,j,k,:))
                   % Copies in all processed images IDs
                   All_Imgs{p_im,reps,i,j,k,l}=Img_Cell{reps,i,j,k,l}; 
                   All_IDs{p_im,reps,i,j,k,l}=strcat('I',num2str(p_im),ID_Cell{reps,i,j,k,l});
                end
            end
        end
    end
end


% PREVIOUS CODE - JUST COPY AND PASTE INTO AAA_ORIGINAL_RUNCODE_FILE in
% place of this function.

%{
% Assembling cell arrays for all images in input folder, containing all
% replicates of each image.
% Loops for all replicates
for reps=1:numel(Img_Cell(:,1,1,1,1))

    % Copies Orig_Img_Cell info into All_Orig_Imgs cell array
    All_Orig_Imgs{p_im,reps}=Orig_Img_Cell{reps};

    % Loops for all SNRs
    for i=1:numel(Img_Cell(reps,:,1,1,1))
        % Loops for j (Noise Reduction)
        for j=1:numel(Img_Cell(reps,i,:,1,1))
            % Loops for k (Sharpening/Deblur)
            for k=1:numel(Img_Cell(reps,i,j,:,1))
                % Loops for l (Tone Mapping)
                for l=1:numel(Img_Cell(reps,i,j,k,:))
                   % Copies in all processed images IDs
                   All_Imgs{p_im,reps,i,j,k,l}=Img_Cell{reps,i,j,k,l}; 
                   All_IDs{p_im,reps,i,j,k,l}=strcat('Img_',num2str(p_im),'_',ID_Cell{reps,i,j,k,l});
                   % Copies in flatfields if specified
                   if strcmp(NPS_Method, 'Flatfield')
                       All_FFs{p_im,reps,i,j,k,l}=FF_Cell{reps,i,j,k,l};
                       All_Mean_Imgs{p_im}=FF.Orig;
                   end 
                end
            end
        end
    end
end
%}