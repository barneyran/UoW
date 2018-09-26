% Modified by Ed Fry (2016.09.09), for purposes of image capture system simulation. 
% Modifications involve changing of function names as below:

% ORIGINAL FUNCTION NAME => NEW FUNCTION NAME
% run_test.m => Dmsc_PDF_ORIG_RUN_CODE.m
% ddfapd.m => Dmsc_PDF_DmscProc.m
% bayerGR.m => Dmsc_PDF_bayerGR.m
% check_img.m => Dmsc_PDF_check_img.m
% ddfapd_decision.m => Dmsc_PDF_ddfapd_decision.m
% ddfapd_intDirezG.m => Dmsc_PDF_ddfapd_intDirezG.m
% ddfapd_interpRB.m => Dmsc_PDF_ddfapd_interpRB.m
% ddfapd_refining.m => Dmsc_PDF_ddfapd_refining.m

%   img : original image [mxnx3] 
%   bpp : bit per color sample
%   out: reconstructed image [mxnx3]

filename='peppers.png';


img=double(imread(filename));
info=imfinfo(filename);

bpp=info.BitDepth/3;


% downsample the image according to the Bayer pattern
bay=Dmsc_PDF_bayerGR(img);

% reconstruct the image using the DDFAPD technique
out=Dmsc_PDF_DmscProc(bay,bpp);


imshow(uint8(out))