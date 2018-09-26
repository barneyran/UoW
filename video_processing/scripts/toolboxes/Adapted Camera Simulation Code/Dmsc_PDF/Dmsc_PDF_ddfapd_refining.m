function img=Dmsc_PDF_ddfapd_refining(img,matScelta)

% Dmsc_PDF_ddfapd_REFINING Refining of the reconstructed image
%   IMG=Dmsc_PDF_ddfapd_REFINING(IMG,MATSCELTA) refines the reconstruction of the
%   interpolated image IMG. The knowledge of the edge-direction estimation
%   contained in MATSCELTA is also used.
%
%   Input: 
%   img: reconstructed image (mxnx3)
%   matScelta: (mxn) matrix containing the estimation for the best directional 
%   reconstruction
%
%   Output:
%   img: reconstructed image (mxnx3)
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

m=size(img,1);
n=size(img,2);

R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);

RlessG=R-G;
BlessG=B-G;

medRlessG=zeros(m,n);
medBlessG=zeros(m,n);
medRlessB=zeros(m,n);

ff=[1 1 1]/3;

% refining of the green
for i=2:2:m-1
    for j=3:2:n-1
        if matScelta(i,j)==1
            medBlessG(i,j)=ff*BlessG(i,j-1:j+1).'; 	
        else
            medBlessG(i,j)=ff*BlessG(i-1:i+1,j);
        end
    end
end
for i=3:2:m-1
    for j=2:2:n-1
        if matScelta(i,j)==1
            medRlessG(i,j)=ff*RlessG(i,j-1:j+1).'; 	
        else
            medRlessG(i,j)=ff*RlessG(i-1:i+1,j);
        end
    end
end
G(3:2:m-1,2:2:n-1)=R(3:2:m-1,2:2:n-1)-medRlessG(3:2:m-1,2:2:n-1);
G(2:2:m-1,3:2:n-1)=B(2:2:m-1,3:2:n-1)-medBlessG(2:2:m-1,3:2:n-1);

RlessG=R-G;
BlessG=B-G;

% refining of the red in the green pixels
i=2:2:m-1;
j=2:2:n-1;
medRlessG(i,j)=(RlessG(i-1,j)+RlessG(i+1,j))/2;
R(i,j)=G(i,j)+medRlessG(i,j);

i=3:2:m-1;
j=3:2:n-1;
medRlessG(i,j)=(RlessG(i,j-1)+RlessG(i,j+1))/2;
R(i,j)=G(i,j)+medRlessG(i,j);
  
% refining of the blue in the green pixels
i=2:2:m-1;
j=2:2:n-1;
medBlessG(i,j)=(BlessG(i,j-1)+BlessG(i,j+1))/2;
B(i,j)=G(i,j)+medBlessG(i,j);
  
i=3:2:m-1;
j=3:2:n-1;
medBlessG(i,j)=(BlessG(i-1,j)+BlessG(i+1,j))/2;
B(i,j)=G(i,j)+medBlessG(i,j);      


RlessB=R-B;
% refining of the red in the blue pixels
for i=2:2:m-1,
    for j=3:2:n-1,
        if matScelta(i,j)==1
            medRlessB(i,j)=ff*RlessB(i,j-1:j+1).'; 	
        else
            medRlessB(i,j)=ff*RlessB(i-1:i+1,j);
        end
        R(i,j)=B(i,j)+medRlessB(i,j);
     end
end

% refining of the blue in the red pixels
for i=3:2:m-1,
    for j=2:2:n-2,
        if matScelta(i,j)==1
           medRlessB(i,j)=ff*RlessB(i,j-1:j+1).'; 	
        else
           medRlessB(i,j)=ff*RlessB(i-1:i+1,j);
        end
        B(i,j)=R(i,j)-medRlessB(i,j);
     end
end

img(:,:,1)=R;
img(:,:,2)=G;
img(:,:,3)=B;

