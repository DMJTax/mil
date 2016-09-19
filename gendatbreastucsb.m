%GENDATBREAST UCSB Breast dataset
%
%     A = GENDATBREAST
% OUTPUT
%   A          MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem UCSB Breast. 
%
% The public data consists of 58 TMA image excerpts of 896 × 768 pixel size taken from 32 benign and 26
% malignant breast cancer patients. The learning task is to classify images
% as benign (negative) or malignant (positive).
%
% Patches of 7x7 size are extracted. The image is thresholded to segment the content from the white background (threshold of 0.9), and 
% discard the patches that contain background more than 75% of their area. 
% The features used are 657 features are global to the patch (histogram,
% LBP, SIFT), and averaged features extracted from the cells, detected in each patch.
%
% REFERENCE
% Empowering multiple instance histopathology cancer diagnosis by cell graphs 
% M. Kandemir, C. Zhang, F.A. Hamprecht 
% MICCAI, To Appear, (2014)
%
% In the above paper, the original data was converted to a MIL setting
% (patch and feature extraction). The original data is available from:
%
% http://www.bioimage.ucsb.edu/research/biosegmentation
%
% SEE ALSO
% mildatapath
function a = gendatbreastucsb


  
load(fullfile(mildatapath,'BreastUCSD.mat'));
   

numbags = size(data, 2);
baglab = [data.label]';

mildata = [];
instlab = [];
bagid = [];

for i=1:58
    mildata = [mildata; data(i).instance]; 
    bagsize=size(data(i).instance,1); 
    instlab = [instlab; repmat(baglab(i), bagsize,1)];
    bagid = [bagid; repmat(i, bagsize, 1)];
end


instlab = genmillabels(instlab, 1);



a = genmil(double(mildata),instlab,bagid,'presence');


a=setname(a, 'UCSB Breast cancer');

return
