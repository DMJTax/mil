%GENDATANDREWS TREC datasets used by Andrews
%
%     A = GENDATTREC(CLASSNR)
%
% INPUT
%   CLASSNR    Positive class (default = 1)
%
% OUTPUT
%   A          MIL dataset
% 
% DESCRIPTION
% This dataset originates from http://www.cs.columbia.edu/~andrews/mil/datasets.html
% There are 7 possible classes to choose from for the positive class:
% 'trec_1', 'trec_2', 'trec_3', 'trec_4', 'trec_7', 'trec_9', or
% 'trec_10'. To choose for instance the last class, use CLASSNR = 10.
%
% SEE ALSO
% mildatapath

function a = gendattrec(classnr)

if nargin<1
	classnr = 1;
end

    classname = ['trec_' num2str(classnr)];


	allnames = {'trec_1', 'trec_2', 'trec_3', 'trec_4', 'trec_7', 'trec_9', 'trec_10'};
	
	if isempty(strmatch(classname,allnames))
		error('Class %s is not present in the TREC dataset.',classname);
    end
   
    
   prload(fullfile(mildatapath,'StuartAndrews', [lower(classname) '_200x200_matlab.mat']));
   
   %VC: This seems trivial, but the data is in an (index, index) value
   %format instead of just value, and I don't see a simpler way to get rid
   %of that
   
   newfeatures = zeros(size(features));
   newlabels = cell(length(labels),1);
   
   for i=1:length(labels)
       
       newfeatures(i,:) = features(i,:);
       
       if(labels(i) == 1)
           newlabels{i} = 'positive';
       else
           newlabels{i} = 'negative';
       end
       
   end   
    
   a = genmil(newfeatures,newlabels,bag_ids','presence');
   a = setname(a,'%s (Andrews)',classname);

return
