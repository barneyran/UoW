function [ durationInSeconds ] = saveAsPNG( imagesStruct, imagesNames, outPath, SNR_names )
%SAVEASPNG Save a cell array of .mat as png
%
%   Adapted to the output of Ed's pipeline, see digitalCameraSimulation.m
%
%
%   [ durationInSeconds ] = saveAsPNG( imagesStruct, imagesNames, outPath, SNR_names )
%
%
%   INPUTS
%     imagesStruct  --> 
%     imagesNames   --> 
%     outPath       --> 
%     SNR_names     --> 
%
%   OUTPUTS
%     durationInSeconds  --> total runtime
%
%   See also
%     digitalCameraSimulation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TO DO
%     - end description

tic

for k = 1:size(SNR_names, 1)

    subPath = [ outPath SNR_names{k}];
    
    if (~isdir(subPath))
        mkdir(subPath);
    end

    for j = 1:size(imagesStruct, 1)

        img   = imagesStruct{j, 1, k};
        tName = [ subPath imagesNames{j} ];

        imwrite(img, tName);
    end
end

durationInSeconds = toc;
end

