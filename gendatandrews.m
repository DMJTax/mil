%GENDATANDREWS Fox, Tiger and Elephant datasets used by Andrews
%
%     A = GENDATANDREWS(CLASSNAME)
%
% INPUT
%   CLASSNAME     Class to make positive
%
% OUTPUT
%   A             MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem where the classes 'Fox',
% 'Tiger' or 'Elephant' can be positive.
% This dataset originates from http://www.cs.columbia.edu/~andrews/mil/datasets.html
%
% SEE ALSO
% mildatapath

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = gendatandrews(classname)
if nargin<1
	classname = 'Fox';
end


	allnames = {'Fox', 'Tiger', 'Elephant'};
	
	if isempty(strmatch(classname,allnames))
		error('Class %s is not present in the Andrews dataset.',classname);
    end
   
    
   prload(fullfile(mildatapath,'StuartAndrews', [lower(classname) '_100x100_matlab.mat']));
   
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
