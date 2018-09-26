function [ All_Imgs, durationInSeconds ] = digitalCameraSimulation( in_path, out_path, images )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Digital Camera Simulation - Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code developed in 2016/17 by Ed Fry for a PhD from University of Westminster, 
% Computational Vision & Imaging Technology Research Group. Supervisors: 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk. 
% 
% For user instructions and system workflow refer to readme.docx

tic
% Display activated or not
isverbose = 0;

num_images = size(images, 1);
if isverbose; disp([num2str(num_images) ' images found.']); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         USER SETTINGS DASHBOARD: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User specifies simulation settings here.

%%%%%%%%%%%%%%%%%%%%%%%%%%% GENERAL SETTINGS:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GENERAL SETTINGS:
% Are Input Images Linearised? Specify: 'Yes' or 'No' (Default is 'No)
Linear_Input='No';
% Do you want to linearise all Output Images? Specify: 'Yes' or 'No' (Default is 'No)
Linearise_Output='No';
% Specify whether to save output cell arrays: 'Yes' or 'No'
Save_Data= 'No';
% Define number of replicates (i.e. repeated processing of same input image) (Default is 1)
Num_Reps=1;

%%%%%%%%%%%%%%%%%%%%%%%% PHYSICAL CAMERA ATTRIBUTES:%%%%%%%%%%%%%%%%%%%%%%%

% CAM TYPE: Specify camera type (default is 'iPhone6') - Relevant model variables include: f-number, pixel and sensor dimensions. 
Cam_Type='iPhone6';
% BLUR: Select Blur_Type from: 'Gaussian', 'Diff_Limited' 'None' (default is 'Diff_Limited')
Blur_Type='Diff_Limited';
% MOSAIC: Select Bayer_Type from: 'grbg', 'rggb', 'gbrg'  or 'bggr' (default is 'grbg')
Bayer_Type='grbg';

%%%%%%%%%%%%%%%%%%%%%%%% NOISE CALCULATION SETTINGS %%%%%%%%%%%%%%%%%%%%%%%

% Define SNR levels - NB. Make sure SNR_names_Cell and SNR_names_II are
% identical, and SNR_names describes the same values in 6 characters only,
% replacing spaces with _ character if necessary. 
SNR_names=['Three_'; 'Five__'; 'Ten___'; 'Twenty'; 'Forty_';  ];
SNR_names_Cell={03,05,10,20,40}; SNR_names_II=[03,05,10,20,40]; No_of_SNRs=numel(SNR_names_II);
% Specify Pixel Value for SNR Calculation: 'Mean_Image_Pixel_Value', '1' or
% '0.46' (default is '1')
PV_For_SNR='1';
% Specify assumed system gamma (1/2.2 = 0.4545) (default is '0.4545')
Gamma=0.4545;
% Specify constants for simulation of effect of CCM,
CCM_R_Gain=2; %(default is '2')
CCM_B_Gain=3.5; %(default is '3.5')
% Specify dark current and read noise mean and Standard Deviation, for each SNR.
Dark_Noise_Mean=[0.05,0.01,0.0001,0.00001,0.000001];
Dark_Noise_SD=[0.01,0.005,0.0001,0.000005,0.0000005];

%%%%%%%%%%%%%%%%%%%%%%% IMAGE PRE-PROCESSING SETTINGS %%%%%%%%%%%%%%%%%%%%%

% Do you Wish to Apply Pre-Processing Adjustments? (this improves visual 
% image quality, but may affect performance of CNN)
ApplyPreProc='Yes';
% Specifies Exposure (gain) Adjustment, for each SNR.
Expo_adj=[1.25,1.19,1.06,1.02,1];
% Defines black level adjustment, for each SNR - higher values reduce black level
Blk_lvl_adj=[0.34,0.18,0.09,0.04,0.02];
% Defines white level adjustment, for each SNR - lower values reduce white level
Wht_lvl_adj=[0.92,0.95,0.98,0.99,1];

%%%%%%%%%%%%%%%%%%%%%%%%% IMAGE PROCESSING SETTINGS %%%%%%%%%%%%%%%%%%%%%%%

% DEMOSAIC TYPE: Select Demosaic_Type: (Default is 'Malvar')
%{
% Otherwise, select any from: 'Bilinear' [fast --] [default],  'Bilinear_Conv' [fast --],
% 'Malvar' [fast +], 'Glotzbach_Basic' [fast +], 'Glotzbach_Full' [fast +], 
% 'Kriss' [fast -], 'LSLCD' [fast +], 'NAT' [slow ?], 'NLM' [slow -],
% 'AP'[fast +], 'OSAP'[fast +], 'PDF' [fast +]
%}
Demosaic_Type='Malvar';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparatory Calculations 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CAMERA/MODULE SPECIFICATION:
% Outputs System structure, describing all physical camera/module dimensions
[System]=system_spec(Cam_Type);

% CREATES WORKING & OUTPUT CELLS FOR SIMULATION:
% Specifies no denoising, sharpening, or tone-mapping to be applied - image cell dimensions will reflect this. 
NR_Type='None'; Shrpn_Type='None'; TM_Type='None';
% Creates all cell arrays used during simulation workflow, and output.
[j, k, l, Img_Cell, ID_Cell, Orig_Img_Cell, All_Imgs,...
    All_Orig_Imgs, All_IDs, K_Values]=Create_Working_Cells(NR_Type,...
    Shrpn_Type, TM_Type, num_images, Num_Reps, No_of_SNRs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGINNING SIMULATION LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p_im = image number (alphabetically) from hereon, 
% num_images = total number of images to be processed (i.e. in input folder)

% Loops over all images in input folder
for p_im = 1:num_images  % p_im denotes image number (alphabetically)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Loading of Images
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loads image number alphabetically in in_path folder, according to 
    % 'p_im'. Creates a number of replicates as specified by "Num_Reps".
    
    try  % try - catch is a way to stop things from halting on errors 
        %- so if an image cannot be loaded it will continue
        img.Path = [in_path images{p_im}];
        img.Orig = imread(img.Path);
    catch
        if isverbose; disp(['Could not load image ' num2str(p_im) '. Moving on...' ]); end
        %what to do if it can't load image
        continue
    end
    % Checks to ensure image is uint8
    if class(img.Orig)=='uint8'
    else
        if isverbos; disp(['Image ' num2str(p_im) 'is not UINT8, terminating script' ]); end
        return
    end
    img.Info=imfinfo(img.Path); % Getting image info
    img.Replicates=cell(1,Num_Reps); % Duplicates image into replicates
    for rep=1:Num_Reps
        img.Replicates{rep}=img.Orig;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Blur Modelling
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Blurs image according to specified Blur_Type
    if isverbose; disp('Blur Modelling'); end
    [img]=ImgProc_Blur(img, Blur_Type, System, Num_Reps);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BEGINNING REPLICATES LOOP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rep = identifies each image replicate 
    % Num_Reps = total number of replicates
    for rep=1:Num_Reps
        if isverbose
            disp(' ');
            disp(['Processing image ' num2str(p_im) ' of ' num2str(num_images)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Noise modelling
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Step-by-step description of noise modelling and pre-processing: 
        % 1. convert blurred image to double, and linearise if
        % necessary
        % 2. normalize to fractional linear luminance (/255)
        % 3. scale to fractional linear quanta (between 0 and 1) (/scale)
        % 4. Multiply by K_Lambda (i.e. SNR^2) - this gives image in quanta, as per SNR. 
        % 5. Account for colour correction matrix (CCM) (necessary because R and B channels have lower quantum efficiency). 
        % 6. Calculate poisson noise 
        % 7. Apply reverse scaling for steps 3 & 4 on noisy image.
        % 8. Exposure adjustment at lower SNRs, to compensate for noise floor. 
        % 9. Black and white level adjustment: black level lowered to account for noise floor; white level lowered to account for exposure adjustment scaling, and clipping. 
        % 10. Clip image to between pixel values of 0 and 1. 
            
        % Creates cell to record K values for all images (their mean PV's
        % are different, therefore K values will not be identical, and will
        % need to be stored for reference).
        if isverbose; disp('Image: Noise modelling'); end
        p_im_names_Cell=cell(num_images,No_of_SNRs);
        for im_id=1:num_images
            for SNR=1:No_of_SNRs
                p_im_names_Cell{im_id,SNR}=im_id;
            end
        end
        K_Values(p_im,2,:)=SNR_names_Cell;
        K_Values(p_im,1,:)=p_im_names_Cell(p_im,:);
        
        % K is normalised according to full saturation, i.e. SNRs are
        % calculated at full well capacity. 
        PV_SNR=1;
            
        % Calculates K value and stores in cell
        % Loops across various K values logarithmically
        for SNR_Indi=1:No_of_SNRs
            % Defines K (lambda) constant (average number of events, or N as in
            % https://en.wikipedia.org/wiki/Shot_noise). 
            K_Lambda=(1*PV_SNR)* SNR_names_II(SNR_Indi)^2;
            K_Values{p_im,3,SNR_Indi}=K_Lambda;
        end
     
        % Gets image dimensions
        [h,w]=size(img.Blur.Gauss{1}(:,:,1));
        % Creates all blank img.Poiss output images
        for SNR_Selector=1:No_of_SNRs
            SNR_ID=strcat('SNR_',num2str(SNR_names_II(SNR_Selector)));
            % Sets field name, and creates blank image
            img.Poiss.(SNR_ID)=zeros(h,w,3); 
        end
        % Wipes SNR_IDs cell
        SNR_IDs=cell(No_of_SNRs,1);
        
        % Linear gain adjustment, so overall SNR remains same after CCM
        % application
        CCM_Gain_Adjust=1/((CCM_R_Gain+CCM_B_Gain+1)/3);
        
        % Loops for No_of_SNRs
        for SNR_Selector=1:No_of_SNRs
            % assigns K value according to image and SNR ID 
            % Note: Gain adjustment is made here, to K value. 
            K_Lambda=K_Values{p_im,3,SNR_Selector}/CCM_Gain_Adjust;
            SNR_ID=strcat('SNR_',num2str(SNR_names_II(SNR_Selector)));
            SNR_IDs{SNR_Selector}=SNR_ID;
            
            % LINEARISING IMAGE IF REQUIRED (disabled for linear input images)
            if strcmp(Linear_Input,'Yes')
                lin_image=double(img.Blur.Gauss{rep})/255;
            else
                lin_image=(double(img.Blur.Gauss{rep})/255).^(1/Gamma);
            end
            
            % Calculates noise per specifications and scales per CCM.
            scale = 1e12;
            img.Poiss.(SNR_ID)(:,:,1) = scale/K_Lambda*CCM_R_Gain * imnoise(lin_image(:,:,1)/scale*K_Lambda/CCM_R_Gain, 'poisson');
            img.Poiss.(SNR_ID)(:,:,2) = scale/K_Lambda * imnoise(lin_image(:,:,2)/scale*K_Lambda, 'poisson');
            img.Poiss.(SNR_ID)(:,:,3) = scale/K_Lambda*CCM_B_Gain * imnoise(lin_image(:,:,3)/scale*K_Lambda/CCM_B_Gain, 'poisson');
           
            % Dark current & read noise (Gaussian, added at higher levels at low SNRs)
            img.Poiss.(SNR_ID)=imnoise(img.Poiss.(SNR_ID),'gaussian',Dark_Noise_Mean(SNR_Selector),Dark_Noise_SD(SNR_Selector));
            % Accounting for capture system gamma (Delinearising image).
            img.Poiss.(SNR_ID)=img.Poiss.(SNR_ID).^Gamma;
            
            % Applying pre-processing if specified.
            if strcmp(ApplyPreProc,'Yes') 
                % Exposure (gain) Adjustment - disabled
                img.Poiss.(SNR_ID)=img.Poiss.(SNR_ID)*Expo_adj(SNR_Selector);
                % Black (& white) level adjustment
                img.Poiss.(SNR_ID)= imadjust(img.Poiss.(SNR_ID),[Blk_lvl_adj(SNR_Selector) 1],[0 Wht_lvl_adj(SNR_Selector)]);
            end
            
            % Storing img.Poiss output images in Img_Cell Cell Array
            Img_Cell{rep,SNR_Selector,1,1}=img.Poiss.(SNR_ID);
            ID_Cell{rep,SNR_Selector,1,1}=strcat('R ',num2str(rep), ' SNR ',num2str(SNR_names_II(SNR_Selector)));
            % Clips image between values of 0 and 1 if necessary
            [Img_Cell{rep,SNR_Selector,1,1}]=range_0to1(Img_Cell{rep,SNR_Selector,1,1});
       
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Conversion to Bayer Mosaic 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Converts image to bayer, by dropping pixel information according
        % to array type. See RGB2Bayer function for more details. 
        if isverbose; disp('Conversion to Bayer Mosaic '); end
        for i=1:numel(Img_Cell(rep,:,1,1))
            [img.Bayer]=ImgProc_RGB2Bayer(Img_Cell{rep,i,1,1}, Bayer_Type);
            Img_Cell{rep,i,1,1}=img.Bayer;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Demosiaicing
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isverbose; disp(strcat('Demosaicing using -', Demosaic_Type, '- method')); end
        %Converts to double, otherwise mosaic calculation saturates at 255
        for i=1:numel(Img_Cell(rep,:,1,1))
            Img_Cell{rep,i,1,1}=im2double(Img_Cell{rep,i,1,1});
            % Performs demosaicing on Bayer_type image, according to Demosaic_Type
            % specified: 'Bilinear', 'Matlab_Default' & others.
            img.Dmsc=ImgProc_Demosaic(Img_Cell{rep,i,1,1}, Demosaic_Type , Bayer_Type);
            Img_Cell{rep,i,1,1}=img.Dmsc;
            % Clips image between values of 0 and 1 if necessary
            [Img_Cell{rep,i,1,1}]=range_0to1(Img_Cell{rep,i,1,1});
        end 
    end  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assembling Output Cell Arrays
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isverbose; disp('Assembling Output Cell Arrays'); end
    [All_Imgs,All_IDs, All_Orig_Imgs]=...
    Assemble_Output_Cells(Img_Cell, ID_Cell, Orig_Img_Cell, p_im,...
    All_Imgs,All_IDs, All_Orig_Imgs);

end

% Clearing working cells (all data now in output cells)
clear Img_Cell; clear Orig_Img_Cell; 

% LINERISING OUTPUT IMAGES IF SPECIFIED
if strcmp(Linearise_Output, 'Yes')
    [RP_imgs, RP_reps, RP_SNRs, RP_NRs, RP_Shrps, RP_TMs]=size(All_IDs); 
    All_Imgs_2=All_Imgs;
    for img=1:RP_imgs
        for p=1:RP_reps
            for i=1:RP_SNRs
                for j=1:RP_NRs
                    for k=1:RP_Shrps
                        for l=1:RP_TMs
                            All_Imgs_2{img,p,i,j,k,l}=All_Imgs{img,p,i,j,k,l}.^(1/Gamma);
                        end
                    end
                end
            end
        end
    end
    All_Imgs=All_Imgs_2; clear All_Imgs_2;  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving Output Cell Arrays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
if strcmp(Save_Data, 'Yes')
    disp('Saving All Images ');
    save([out_path 'AA_All_Imgs' '.mat'], 'All_Imgs');
    save([out_path 'AA_All_IDs' '.mat'], 'All_IDs');
    disp('Saving All Original Images ');
    save([out_path 'AA_All_Orig_Imgs' '.mat'], 'All_Orig_Imgs');
end

if isverbose; fprintf('******** finished ********\n'); end

durationInSeconds = toc;


end

