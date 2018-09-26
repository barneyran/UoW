function [ num ] = getNumFormatFile( dirsPaths, format )
%GETNUMFORMATFILE return the number of format files found in all
%directories informed by dirsPaths
%   
%   
%   [ num ] = getNumFormatFile( dirsPaths, format )
%
%
%   INPUTS
%     dirsPaths  --> cell array, or char
%     format     --> format of searched files, like '.avi' or 'png'
%
%   OUTPUTS
%     num  --> number of format files found in all directories informed by 
%              dirsPaths 



% Formating format name
if ~strcmp(format(1), '.')
    format = ['.' format];
end
format = lower(format);

% Formating dirsPaths into a cell array
if ~iscell(dirsPaths)
    dirsPaths = {char(dirsPaths)};
end
if size(dirsPaths, 2) > 1
    dirsPaths = dirsPaths';
end

% Get the number of files
num = 0;
for i = 1 : size(dirsPaths, 1)
    if ( strcmp(dirsPaths{i}(end),  '/') || strcmp(dirsPaths{i}(end),  '/') )
        dirsPaths{i}(end)  = [];
    end
    num = num + size(dir([dirsPaths{i} '/*' format]), 1);
end

