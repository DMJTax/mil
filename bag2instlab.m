%BAG2INSTLAB Copy bag to instance labels
%
%    A = BAG2INSTLAB(A)
%
% INPUT
%   A     MIL dataset
%
% OUTPUT
%   B     MIL dataset
%
% DESCRIPTION
% Copy the bag labels of dataset A to instance labels in dataset B. This
% will result in identical labels for all instances in one bag.
%
% SEE ALSO
% getbags, labelset, genmil

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = bag2instlab(a)

[bag,baglab,bagID,Ibag]=getbags(a);
lab = getlab(a);
for i=1:length(bag)
   lab(Ibag{i},:) = repmat(baglab(i,:),length(Ibag{i}),1);
end
a = setlabels(a,lab);

