function out=Dmsc_PDF_DmscProc(bay,bpp)

% DDFAPD Demosaicing with Directional Filtering and a Posteriori Decision
% (D. Menon, S. Andriani, and G. Calvagno, IEEE Trans.
% Image Processing, vol. 16 no. 1, Jan. 2007.)
% 
%   OUT=DDFAPD(IMG,BPP) downsamples and interpolates the original image IMG
%   (with BPP bit per color sample) to create the reconstructed image OUT.
%
%   Input:
%   img : original image [mxnx3] 
%   bpp : bit per color sample
%
%   Output:
%   out: reconstructed image [mxnx3]
%
%   Daniele Menon 24/02/05

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

% horizontal and vertical interpolation of the green channel
disp('Directional interpolations of the green channel')
[Gh,Gv]=Dmsc_PDF_ddfapd_intDirezG(bay);
Gh=Dmsc_PDF_check_img(Gh,bpp);
Gv=Dmsc_PDF_check_img(Gv,bpp);

% decision between the two estimated green values
disp('Decision between the two estimated green values')
[outG, matScelta]=Dmsc_PDF_ddfapd_decision(Gh,Gv,bay);

% red and blue reconstruction
disp('Interpolation of the red and blue channels')
[outR, outB]=Dmsc_PDF_ddfapd_interpRB(bay,outG,matScelta);
out(:,:,1)=outR(:,:);
out(:,:,2)=outG(:,:);
out(:,:,3)=outB(:,:);
out=Dmsc_PDF_check_img(out,bpp);


% refining (comment this rows if you don't want to perform it)
disp('Refining of the reconstructed image')
out=Dmsc_PDF_ddfapd_refining(out,matScelta);
out=Dmsc_PDF_check_img(out,bpp);

% end of the algorithm
