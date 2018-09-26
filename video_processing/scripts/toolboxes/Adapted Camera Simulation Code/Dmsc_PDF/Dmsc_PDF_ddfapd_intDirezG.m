function [Gh,Gv]=Dmsc_PDF_ddfapd_intDirezG(bay)

% Dmsc_PDF_ddfapd_INTDIREZG Directional interpolation of the green channel
%   [GH, GV]=Dmsc_PDF_ddfapd_INTDIREZG(BAY) reconstructs two estimates of the green channel
%   from the bayer data BAY, using horizontal and vertical interpolation, to
%   produce GH and GV, respectively.
% 
%   Input:
%   bay : Bayer-downsampled image (mxn)
%
%   Output:
%   Gh : horizontally interpolated green image (mxn)
%   Gv : vertically interpolated green image (mxn)
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

[m,n]=size(bay);

%%%% horizontal interpolation %%%%%
Gh=zeros(m,n);

h0=[-0.25, 0, 0.5, 0, -0.25];
h1=[0, 0.5, 0, 0.5, 0];

% odd rows
G0=zeros(m/2,n);
R1=zeros(m/2,n);
G0(:,1:2:n)=bay(1:2:m,1:2:n);
R1(:,2:2:n)=bay(1:2:m,2:2:n);
f1=filtImg(h1+[0 0 1 0 0],G0,1);         
f2=filtImg(h0,R1,1); 
Gh(1:2:m,:)=f1+f2;

% even rows
B0=zeros(m/2,n);
G1=zeros(m/2,n);
B0(:,1:2:n)=bay(2:2:m,1:2:n);
G1(:,2:2:n)=bay(2:2:m,2:2:n);
f1=filtImg(h1+[0,0,1,0,0],G1,1);
f2=filtImg(h0,B0,1); 
Gh(2:2:m,:)=f1+f2;

%%%% vertical interpolation %%%%%
Gv=zeros(m,n);

% odd columns
G0=zeros(m,n/2);
B1=zeros(m,n/2);
G0(1:2:m,:)=bay(1:2:m,1:2:n);
B1(2:2:m,:)=bay(2:2:m,1:2:n);
f1=filtImg([0 0 1 0 0]+h1,G0,2);         
f2=filtImg(h0,B1,2); 
Gv(:,1:2:n)=f1+f2;

% even columns
R0=zeros(m,n/2);
G1=zeros(m,n/2);
R0(1:2:m,:)=bay(1:2:m,2:2:n);
G1(2:2:m,:)=bay(2:2:m,2:2:n);
f1=filtImg(h1+[0 0 1 0 0],G1,2);         
f2=filtImg(h0,R0,2); 
Gv(:,2:2:n)=f1+f2;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y=filtImg(h,x,dir)
%
% directional filtering of the image x along the direction dir.
% 
% Near the border of the image the neighboring pixels are replicated.
% Dir=1 means horizontal filtering, dir=2 vertical filtering
%

[m,n]=size(x);

B = (length(h)-1)/2;

if dir==1
    xx = [x(:,1+B:-1:2), x, x(:,n-1:-1:n-B)]; 
    y=conv2(1,h,xx,'valid');
end
if dir==2
    xx = [x(1+B:-1:2,:); x; x(m-1:-1:m-B,:)];
    y=conv2(h,1,xx,'valid');
end

end
