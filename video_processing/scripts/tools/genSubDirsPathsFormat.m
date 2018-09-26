function [ genPaths, filenames ] = genSubDirsPathsFormat( mainDir, format, pathsPrefix, genDirPathsForFormatFiles, recursively )
%GENSUBDIRSPATHSFORMAT Generate "[pathsPrefix] arborescence [files]" paths,
%considering the arborescence of 'mainDir' sub folders containing format
%files.
%
%   It can be useful when one want to process format file in an input
%   directory and save the results in an output directory while keeping the
%   same arborescence.
%   It may cause further issues if format files are directly in mainDir,
%   because then genPaths do NOT contains any indication of such situation.
%
%   If genDirPathsForFormatFiles == 1, then genPaths will be a cell array
%   of size Nx1, where N is the size of mainDir arborescence, with each 
%   cell containing an Mx1 array with paths, where M is the number of
%   format files in each folders of mainDir. So there is one particular
%   path per format file, with last folder of each path being named as the
%   file.
%   
%   
%   [ genPaths, filenames ] = genSubDirsPathsFormat( mainDir, format[, ...
%       pathsPrefix, genDirPathsForFormatFiles, recursively] )
%   
%   
%   INPUTS      
%     mainDir      -->  Path where to look for format files
%     format       -->  Extension to look for ('.avi', 'png' ...)
%     pathsPrefix  \->  Path to be added as a prefix to each paths of the 
%                       arborescence.
%                       It can be mainDir if whole paths are needed.
%                       (default = [])
%     genDirPathsForFormatFiles  
%                  \->  1 or 0, to generate or not a folder for each format
%                       files.
%                       (default = 0)
%     recursively  \->  0 or 1 or 'r' or 'recursively'
%                       (default = 1)
%   
%   OUTPUTS
%     genPaths   --> Nx1 cell array if genDirPathsForFormatFiles == 0
%                    Nx1 cell array if genDirPathsForFormatFiles == 1
%                    With N being the number of folders in MainDir
%                    containing format files.
%                    If a cell array, each cell contains an Mx1 array with
%                    particular paths named after each one of the M files 
%                    originally in correspondent MainDir subpath.
%     filenames  --> Nx1 cell array, each cell being an Mx1 array. So each
%                    cell contains format file names (not path)
%
%   FUNCTIONS USED
%     getNumFormatFile  from scripts\tools
%
%   See also
%     getNumFormatFile
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
%   TO DO
%     - Suffixe
%       et il faudrait que les deux, surtout les suiffixe en fait, puisse 
%       etre une liste de suffixe, et donc on aurait a chaque fois
%       plusieurs subFolds avec les suffixes
%     - Recursively or not ?
%     - Add description for recursively input

%% Misc jobs

% Verification
if ~isdir(mainDir)
    error('%s doesn t exist. \n', mainDir);
end
if ~exist('genDirPathsForFormatFiles', 'var')
    genDirPathsForFormatFiles = 0;
end
if ~exist('pathsPrefix', 'var')
    pathsPrefix = [];
end
if ~exist('recursively', 'var')
    recursively = 1;
else
    if ischar(recursively)
        if ( strcmpi('recursively', recursively) || strcmpi('r', recursively) )
            recursively = 1;
        else
            recursively = 0;
        end
    end
end

% Formating directory name
if ( strcmp(mainDir(end),  '\') || strcmp(mainDir(end),  '/') )
    mainDir(end) = [];
end
if ~( isempty(pathsPrefix) )
    if ~strcmp(pathsPrefix(end),  '/')
        if strcmp(pathsPrefix(end),  '\')
            pathsPrefix(end) = '/';
        else
            pathsPrefix(end+1) = '/';
        end
    end
end


% Formating format name
if ~strcmp(format(1), '.')
    format = ['.' format];
end
format = lower(format);

% Get all dir and subdir names
if recursively
    genPath      = genpath(mainDir);
    allDirs      = strsplit(genPath, {';', ':'})';
    allDirs(end) = [];
else
    allDirs      = {mainDir};
end

% Initialisations
cpt          = 0;
sizeDirName  = size(mainDir, 2) +2;
if ~genDirPathsForFormatFiles
    genPaths = cell(size(allDirs, 1), 1);
else
    genPaths = cell(getNumFormatFile( allDirs, format ), 1);
end
filenames = cell(size(allDirs, 1), 1);


%% Generate paths : [ [pathsPrefix] arborescence [Files] ]
%  and cell array with filenames

for i = 1 : size(allDirs, 1)
    currentDir  = [allDirs{i} '/'];    
    files = dir([currentDir '*' format]);
    
    if (~isempty(files))
        
        currentFileNames = {files.name}';
        currentPath = [ pathsPrefix currentDir(sizeDirName:end) ];

        if genDirPathsForFormatFiles
            dirForFiles = cell(size(currentFileNames, 1), 1);
            for j = 1 : size(currentFileNames, 1)
                dirForFiles{j, 1} = [currentPath currentFileNames{j}(1:end-size(format, 2)) '/'];
            end
            currentPath = dirForFiles;
        end
        
        cpt = cpt + 1;
        genPaths{cpt, 1} = currentPath;
        filenames{cpt} = currentFileNames;
    end
end

% Handle oversized pre-allocation due to folders empty of format files
genPaths  (cellfun('isempty', genPaths)   == 1) = [];
filenames (cellfun('isempty', filenames)  == 1) = [];


end