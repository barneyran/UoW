function img=Dmsc_PDF_check_img(img,bpp)
%
% Check if the image's pixels are in correct values and,
% if they saturate, correct them
%
% Input:
% img : image [mxnxK]
% bpp: bit per sample
%
% Output:
% img : corrected image [mxnxK]
%
% Daniele Menon 04/22/05

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

maxVal=2^bpp-1;
img= round(img); 
ind = find(img>maxVal); 
img(ind) = maxVal;
ind = find(img<0); 
img(ind) = 0;

