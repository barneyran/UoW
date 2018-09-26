function out = Dmsc_PDF_bayerGR(in)

% BAYERGR downsamples an image according to the Bayer pattern.
%   OUT=BAYERGR(IN) downsamples the three-channel input image IN to give the
%   output one-dimensional image OUT.
% 
%   NB: The Bayer pattern is considered with a G value in the most top-left
%   pixel, i.e.:
%    ------------------> x
%   |  G R G R ...
%   |  B G B G ...
%   |  G R G R ...
%   |  B G B G ...
%   |  . . . . .
%   |  . . . .  .
%   |  . . . .   .
%   |
%   V y

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




m = size(in,1); 
n = size(in,2);

out=zeros(m,n);

out(1:2:m,1:2:n)=in(1:2:m,1:2:n,2);
out(1:2:m,2:2:n)=in(1:2:m,2:2:n,1);
out(2:2:m,1:2:n)=in(2:2:m,1:2:n,3);
out(2:2:m,2:2:n)=in(2:2:m,2:2:n,2);

