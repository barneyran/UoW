%% Demo of LDI-NAT algorithm for CDM
% L. Zhang, X. Wu, A. Buades, and X. Li, 
% "Color Demosaicking by Local Directional Interpolation and Non-local Adaptive Thresholding," 
% in Journal of Electronic Imaging, 2011.

%% The code is not optimized so that it runs a little slow. 

% MODIFIED by Ed Fry 2016.09.09 for purposes of capture system simulation
% Modifications include, removal of image reading, and GRGB bayer array
% simulation, and creation of individual functions for LDI-NAT and LDI-NLM
% demosaicing algorithms. 


clear;
I=imread('Portrait_RGB','jpg');
I=double(I);
[n,m,c]=size(I);

figure(1), subplot 131, imshow(I/255), title('original image');

A=zeros(n,m);
% Keeps green channel
A=I(:,:,2);
% replaces red channel as per GRGB
A(1:2:n,2:2:m)=I(1:2:n,2:2:m,1);
% replaces blue channel as per GRGB
A(2:2:n,1:2:m)=I(2:2:n,1:2:m,3);


%%% CDM by the LDI-NAT algorithm %%%
G=nat_cdm(A);
%snr_nat=csnr(G(21:n-20,21:m-20,:),I(21:n-20,21:m-20,:))

 subplot 132, imshow(G/255), title('LDI-NAT dmsc img');

%%% CDM by the LDI-NLM algorithm %%%
G=nlm_cdm(A);
%snr_nlm=csnr(G(21:n-20,21:m-20,:),I(21:n-20,21:m-20,:))

 subplot 133, imshow(G/255), title('LDI-NLM dmsc img');

