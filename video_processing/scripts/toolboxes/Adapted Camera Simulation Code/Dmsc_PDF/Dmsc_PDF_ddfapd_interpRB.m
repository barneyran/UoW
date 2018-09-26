function [R,B]=Dmsc_PDF_ddfapd_interpRB(bay,G,scelta)

% Dmsc_PDF_ddfapd_INTERPRB Reconstruction of the red and blue components
%   [R,B]=Dmsc_PDF_ddfapd_INTERRB(BAY,G,SCELTA) reconstructs the red and blue
%   components, R and B respectively, using the bayer data BAY, the
%   reconstructed green image G, and the knowledge of the green decision
%   contained in the matrix SCELTA.
% 
%   Input:
%   bay : Bayer-downsampled image (mxn)
%   G : reconstructed green image (mxn)
%   scelta : (mxn) matrix containing the estimation for the best directional 
%   reconstruction
%
%   Output:
%   R : reconstructed red image (mxn)
%   B : reconstructed blue image (mxn)
%
%   Daniele Menon 

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

[m,n]=size(G);
R=zeros(m,n);
B=zeros(m,n);
R(1:2:m,2:2:n)=bay(1:2:m,2:2:n);
B(2:2:m,1:2:n)=bay(2:2:m,1:2:n);

% green pixels: reconstruction of the red through bilinear interpolation of
% R-G
R(1:2:m,3:2:n)=G(1:2:m,3:2:n)+(R(1:2:m,(3:2:n)-1)-G(1:2:m,(3:2:n)-1)+R(1:2:m,(3:2:n)+1)-G(1:2:m,(3:2:n)+1))/2;
R(2:2:m-1,2:2:n)=G(2:2:m-1,2:2:n)+(R((2:2:m-1)-1,2:2:n)-G((2:2:m-1)-1,2:2:n)+R((2:2:m-1)+1,2:2:n)-G((2:2:m-1)+1,2:2:n))/2;

% green pixels: reconstruction of the blue through bilinear interpolation of
% B-G
B(2:2:m,2:2:n-1)=G(2:2:m,2:2:n-1)+(B(2:2:m,(2:2:n-1)-1)-G(2:2:m,(2:2:n-1)-1)+B(2:2:m,(2:2:n-1)+1)-G(2:2:m,(2:2:n-1)+1))/2;
B(3:2:m,1:2:n)=G(3:2:m,1:2:n)+(B((3:2:m)-1,1:2:n)-G((3:2:m)-1,1:2:n)+B((3:2:m)+1,1:2:n)-G((3:2:m)+1,1:2:n))/2;

% reconstruction near the borders of the image
R(:,1)=G(:,1)+R(:,2)-G(:,2);
R(m,:)=G(m,:)+R(m-1,:)-G(m-1,:);
B(1,:)=G(1,:)+B(2,:)-G(2,:);
B(:,n)=G(:,n)+B(:,n-1)-G(:,n-1);

% reconstruction of the red and blue values in the blue and red pixels,
% respectively.
for i=2:2:m-1,
    for j=3:2:n-1,
        if scelta(i,j)==1,
           R(i,j) = B(i,j)+1/2*(R(i,j-1)-B(i,j-1)+R(i,j+1)-B(i,j+1));
        else
           R(i,j) = B(i,j)+1/2*(R(i-1,j)-B(i-1,j)+R(i+1,j)-B(i+1,j));
        end
     end
end

for i=3:2:m-1,
    for j=2:2:n-2,
        if scelta(i,j)==1,
           B(i,j) = R(i,j)+1/2*(B(i,j-1)-R(i,j-1)+B(i,j+1)-R(i,j+1));
        else
           B(i,j) = R(i,j)+1/2*(B(i-1,j)-R(i-1,j)+B(i+1,j)-R(i+1,j));
        end
     end
end
