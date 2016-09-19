%CONSISTENTMILLAB Consistently label all instances in a bag
%
%       B = CONSISTENTMILLAB(A)
%
% INPUT
%   A      MIL dataset
%
% OUTPUT
%   B      MIL dataset
%
% DESCRIPTION
% Relabel all instances from the bags in A, such that the instances in a
% positive bag will all get a positive label, and all other instances
% will be negative. Obviously, you should not do that when you put a lot
% of effort in labeling each instance in A. It is maybe interesting in the
% case that the labelings are not very trustworthy, and you want to have
% a very clear distinction between positive and negative bags.
%
% SEE ALSO
%    GETBAGS, GENMIL

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function b = consistentmillab(a)

[bags,lab,bagid,I] = getbags(a);
labb = zeros(size(a,1),8);
for i=1:length(I)
	labb(I{i},:) = repmat(lab(i,:),length(I{i}),1);
end
labb = char(labb);
b = setlabels(a,labb);

return

