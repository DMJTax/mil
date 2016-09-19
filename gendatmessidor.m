%GENDATMESSIDOR Messidor retinopathy dataset
%
%     A = GENDATMESSIDOR
% OUTPUT
%   A          MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem Messidor. 
%
% The public data consists of 1200 eye fundus images from 654 diseased and 546 healthy patients. 
% Disease is quantified in 3 stages, all stages are converted to the
% positive class. 
% Each image is rescaled to 700x700 pixels and spilt up into patches of 135x135 pixels. 
% Patches which do not have a sufficient amount of foreground are
% discarded. 
%
% The features used are: 
% - intensity histogram of RGB channels for 26 bins
% - mean of local binary pattern histograms of 20x20 pixel grids
% - mean of SIFT descriptors
% - box count for grid sizes 2,3,...8
%
% REFERENCE
%
% Original data is kindly provided by the Messidor program partners (see http://messidor.crihan.fr)
%
% Processed for MIL by Dr. Melih Kandemir
%
% @article{kandemir2014computer,
%  title={Computer-aided diagnosis from weak supervision: A benchmarking study},
%  author={Kandemir, Melih and Hamprecht, Fred A},
%  journal={Computerized Medical Imaging and Graphics, in press},
%  year={2014}
% }
%
%
% SEE ALSO
% mildatapath
function a = gendatmessidor


datanr = [11 12 13 14 21 22 23 24 31 32 33 34]; 

mildata = [];
instlab = [];
bagid = [];


for j=1:length(datanr)
    load(fullfile(mildatapath,['messidor/MessidorBase' num2str(datanr(j)) '_scale4.mat']));
   

    bl = [data.label]';   %Labels are 0 (normal), 1, 2 and 3 (varying degrees of disease)
    bl = bl(1:2:end);     %There are actually two label lists, but we use only the first one... I want to do [data.label(:,1)]' but this is not possible 
    %unique(bl)
    bl = double(bl>0);       %Keep 0 as 0 (negative) and convert others to 1 (positive)
   
    
    
    for i=1:length(data)
       
 
        
        mildata = [mildata; data(i).instance]; 
        bagsize = size(data(i).instance,1); 
        instlab = [instlab; repmat(bl(i), bagsize,1)];
        
        bagid = [bagid; repmat((j-1)*100+i, bagsize, 1)];
       
    end


    
end

instlab = genmillabels(instlab, 1);

a = genmil(double(mildata),instlab,bagid,'presence');

a(isnan(a)) = 0; %There are some NaNs in the data (23 instances in total). The exact reason is not known, but presumably has to do with the types of features extracted (NaNs only occur in certain consecutive features). Dr Kandemir recommended to replace the NaNs with 0's.

a=setname(a, 'Messidor retinopathy');

return
