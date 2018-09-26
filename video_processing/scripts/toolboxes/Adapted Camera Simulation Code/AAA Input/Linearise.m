clear all; 
Gamma=0.4545;
in_path = '/Users/EdFry/Documents/PhD/CH4 - Systems Simulation/2017.02.05 -  Version to Send - Edit/AAA Input/'; % set up an in and an out path - this is the in path
images = dir([in_path '*.png']); % search for images of specified type
num_images = size(images, 1);
disp([num2str(num_images) ' images found.']); 

for p_im = 1:num_images  % p_im denotes image number (alphabetically)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                      Loading of Images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    try  % try - catch is a way to stop things from halting on errors 
        %- so if an image cannot be loaded it will continue
        img.Path = [in_path images(p_im).name];
        img.Orig = imread(img.Path);
    catch
        disp(['Could not load image ' num2str(p_im) '. Moving on...' ]); 
        %what to do if it can't load image
        continue
    end
    % Checks to ensure image is uint8
    if class(img.Orig)=='uint8'
    else
        disp(['Image ' num2str(p_im) 'is not UINT8, terminating script' ]);
        return
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                      Linearising Images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Linear=(double(img.Orig)/255).^(1/Gamma);
    name=strcat(num2str(p_im), '.png');
    %figure, imshow(Linear)
    %figure, imshow(double(img.Orig)/255)
    imwrite(Linear,name, 'png');
end
    
    