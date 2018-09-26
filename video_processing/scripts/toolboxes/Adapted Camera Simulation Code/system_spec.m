function [System]=system_spec(Cam_Type)
% Outputs System structure, describing all physical camera/module 
% dimensions and other characteristics. 
%
% Code developed in 2016/17 by Ed Fry from University of Westminster, 
% Computer Vision & Image Quality Research Group, for PhD supervised by 
% Sophie Triantaphillidou, Robin Jenkin, John Jarvis & Ralph Jacobson.  
% For any queries, please contact Ed Fry on ewsfry@gmail.com, or
% e.fry@my.westminster.ac.uk.
%
% Inputs: 
% Cam_Type is a string specifying which physical camera's dimensions to copy
%
% Outputs:
% System is a structure, describing all physical camera characteristics
      
   % iPhone camera dimensions and other information:
   if strcmp(Cam_Type,'iPhone7')
       % NB Requires further information
       % sensor height
       System.SensorHeight=5.16e-3;
       % NB Requires further information
   elseif strcmp(Cam_Type,'iPhone6s')
       % NB Requires further information
       % pixel pitch
       System.PixPitch=1.22e-6;
       % aperture
       System.FNumber=2.2;
       % NB Requires further information
   else
       %%%%%%%%%%%%%%%disp('Selecting iPhone6 camera (default)')
       % Selects 'iPhone6' camera properties by default
       % vertical pixels
       System.Pix_h=2448;
       % horizontal pixels
       System.Pix_w=3264;
       % sensor height
       System.SensorHeight=3.67e-3;
       % sensor width
       System.SensorWidth=4.89e-3;
       % pixel pitch
       System.PixPitch_h=System.SensorHeight/System.Pix_h;
       System.PixPitch_w=System.SensorWidth/System.Pix_w;
       System.PixPitch=(System.PixPitch_h+System.PixPitch_w)/2;
       % aperture (System.FNumber)
       System.FNumber=2.2;
   end

   % System parameters for Gaussian Airy-Disc Approximation:
   
   % Defines parameters for Airy Disk approximation
   % wavelength is the peak wavelength of RGB respectively, in meters
   System.PeakRGBWvlngth=[450e-9,550e-9,570e-9];
   % System.PSF_Knl_NoOfPixels is the number of pixels for output (x by x)
   System.PSF_Knl_NoOfPixels=10;
   % System.PSF_Knl_Dims is the distance in meters across sensor (-distance/2 to 
   % distance/2), i.e. full height of sensor in m. In this case, we
   % assume distance is equal to picture height.
   System.PSF_Knl_Dims=System.PixPitch*System.PSF_Knl_NoOfPixels; 

   % Further option: For PSF of same size as image
   % System.PSF_Knl_NoOfPixels=System.Pix_h;
   % System.PSF_Knl_Dims=System.SensorHeight;