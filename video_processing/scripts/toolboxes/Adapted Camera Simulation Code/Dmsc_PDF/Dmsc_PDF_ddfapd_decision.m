function [outG,matScelta]=Dmsc_PDF_ddfapd_decision(Gh, Gv, bay)

% Dmsc_PDF_ddfapd_DECISION Decision for the best directional reconstruction
%   [OUTG, MATSCELTA]=Dmsc_PDF_ddfapd_DECISION(GH,GV,BAY) uses the horizontally
%   interpolated image GH, the vertically interpolated image GV and the
%   Bayer-sampled BAY to estimate for each pixel the best reconstruction
%   for the green component. OUTG is the resulting green image. MATSCELTA is
%   is a matrix where the MATSCELTA(i,j)=1 if in the pixel (i,j) the best
%   reconstruction is the horizontal interpolation, =2 if the best
%   reconstruction is the vertical one, and =0 if no estimation was
%   performed (for the G positions)
% 
%   Input:
%   Gh : horizontally interpolated green image (mxn)
%   Gv : vertically interpolated green image (mxn)
%   bay : Bayer-downsampled image (mxn)
%
%   Output:
%   outG : reconstructed green image (mxn)
%   matScelta : (mxn) matrix containing the estimation for the best 
%   directional reconstruction  
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


[m,n]=size(Gh);
mm=m-2;
nn=n-2;


% matric matScelta takes into account the selected direction for the
% interpolation
% 1 --> horizontal recontruction
% 2 --> vertical reconstruction
matScelta=zeros(m,n);


% copy the original green values available from the Bayer pattern
outG(1:2:m,1:2:n)=bay(1:2:m,1:2:n);
outG(2:2:m,2:2:n)=bay(2:2:m,2:2:n);

% chrominances of the horizontally reconstructed image
chrH=zeros(m,n);
chrH(1:2:m,2:2:n)=bay(1:2:m,2:2:n)-Gh(1:2:m,2:2:n);
chrH(2:2:m,1:2:n)=bay(2:2:m,1:2:n)-Gh(2:2:m,1:2:n);

% chrominances of the vertically reconstructed image
chrV=zeros(m,n);
chrV(1:2:m,2:2:n)=bay(1:2:m,2:2:n)-Gv(1:2:m,2:2:n);
chrV(2:2:m,1:2:n)=bay(2:2:m,1:2:n)-Gv(2:2:m,1:2:n);

% gradients of chrH and chrV
DH(1:2:m,2:2:nn)=nor(chrH(1:2:m,2:2:nn),chrH(1:2:m,(2:2:nn)+2));
DH(2:2:m,1:2:nn)=nor(chrH(2:2:m,1:2:nn),chrH(2:2:m,(1:2:nn)+2));
DH(1:2:m,n)=nor(chrH(1:2:m,n),chrH(1:2:m,n-2));

DV(1:2:mm,2:2:n)=nor(chrV(1:2:mm,2:2:n),chrV((1:2:mm)+2,2:2:n));
DV(2:2:mm,1:2:n)=nor(chrV(2:2:mm,1:2:n),chrV((2:2:mm)+2,1:2:n));
DV(m,1:2:n)=nor(chrV(m,1:2:n,:),chrV(m-2,1:2:n));

% weight
c=3;

% compute DeltaH and DeltaV
DeltaH=zeros(m,n);
DeltaV=zeros(m,n);

i=3:2:mm;
j=4:2:nn;
DeltaH(i,j)=DH(i-2,j-2)+DH(i-2,j)+c*DH(i,j-2)+c*DH(i,j)+DH(i+2,j-2)+DH(i+2,j)+DH(i-1,j-1)+DH(i+1,j-1);   
DeltaV(i,j)=DV(i-2,j-2)+c*DV(i-2,j)+DV(i-2,j+2)+DV(i,j-2)+c*DV(i,j)+DV(i,j+2)+DV(i-1,j-1)+DV(i-1,j+1);   

i=4:2:mm;
j=3:2:nn;
DeltaH(i,j)=DH(i-2,j-2)+DH(i-2,j)+c*DH(i,j-2)+c*DH(i,j)+DH(i+2,j-2)+DH(i+2,j)+DH(i-1,j-1)+DH(i+1,j-1);   
DeltaV(i,j)=DV(i-2,j-2)+c*DV(i-2,j)+DV(i-2,j+2)+DV(i,j-2)+c*DV(i,j)+DV(i,j+2)+DV(i-1,j-1)+DV(i-1,j+1);   


% compute DeltaH and Delta V near the bordero of the image
i=2;
j=3:2:nn;
DeltaH(i,j)=DH(i+2,j-2)+DH(i+2,j)+c*DH(i,j-2)+c*DH(i,j)+DH(i+2,j-2)+DH(i+2,j)+DH(i-1,j-1)+DH(i+1,j-1);
DeltaV(i,j)=DV(i+2,j-2)+c*DV(i+2,j)+DV(i+2,j+2)+DV(i,j-2)+c*DV(i,j)+DV(i,j+2)+DV(i-1,j-1)+DV(i-1,j+1);

i=m-1;
j=4:2:nn;
DeltaH(i,j)=DH(i-2,j-2)+DH(i-2,j)+c*DH(i,j-2)+c*DH(i,j)+DH(i-2,j-2)+DH(i-2,j)+DH(i-1,j-1)+DH(i+1,j-1);
DeltaV(i,j)=DV(i-2,j-2)+c*DV(i-2,j)+DV(i-2,j+2)+DV(i,j-2)+c*DV(i,j)+DV(i,j+2)+DV(i-1,j-1)+DV(i-1,j+1);

j=2;
i=3:2:mm;
DeltaH(i,j)=DH(i-2,j+2)+DH(i-2,j)+c*DH(i,j+2)+c*DH(i,j)+DH(i+2,j+2)+DH(i+2,j)+DH(i-1,j-1)+DH(i+1,j-1);
DeltaV(i,j)=DV(i-2,j+2)+c*DV(i-2,j)+DV(i-2,j+2)+DV(i,j+2)+c*DV(i,j)+DV(i,j+2)+DV(i-1,j-1)+DV(i-1,j+1);

j=n-1;
i=4:2:mm;
DeltaH(i,j)=DH(i-2,j-2)+DH(i-2,j)+c*DH(i,j-2)+c*DH(i,j)+DH(i+2,j-2)+DH(i+2,j)+DH(i-1,j-1)+DH(i+1,j-1);
DeltaV(i,j)=DV(i-2,j-2)+c*DV(i-2,j)+DV(i-2,j-2)+DV(i,j-2)+c*DV(i,j)+DV(i,j-2)+DV(i-1,j-1)+DV(i-1,j+1);

% decision between the horizontal and vertical interpolation and
% reconstruction of the green component
x=find(DeltaV<DeltaH);
outG(x)=Gv(x);
matScelta(x)=2;
x=find(DeltaV>=DeltaH);
outG(x)=Gh(x);
matScelta(x)=1;       

% reconstruction near the border of the image
outG(1,:)=Gh(1,:);
outG(m,:)=Gh(m,:);
outG(:,1)=Gv(:,1);
outG(:,n)=Gv(:,n);

outG(2,2)=Gh(2,2);
outG(m-1,2)=Gh(m-1,2);
outG(2,n-1)=Gh(2,n-1);
outG(m-1,n-1)=Gh(m-1,n-1);

end


% internal function: calculate the absolute norm between two values.
function y=nor(g1,g2)
y=abs(g1(:,:)-g2(:,:));

end