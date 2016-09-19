%GETBAGS Get bags from MIL set
%
%      [BAG,LAB,BAGID,IBAG] = GETBAGS(X)
%
% INPUT
%    X          MIL-dataset or MIL-datafile
%
% OUTPUT
%    BAG        A cell array containg in each element one bag.
%    LAB        Bag labels
%    BAGID      Original identifier of each bag
%    IBAG       Indices of the objects in the bags
%
% DESCRIPTION
% Extract the individual bags from MIL dataset X. Dataset X should
% contain the lablistset 'milbag'.  All the instances in the bag are
% stored in the cell-array BAG.
%
% You can also request the bag-labels LAB. The bag labels are derived
% from the instance labels and the combination rule that should be
% stored inside dataset X. This is done by using
% setmilinfo(X,'combrule',rule).
%
% Finally, additionally you can request the bag identifiers BAGID, and
% the indices IBAG of the instances from each bag in the original
% dataset X.
%
% SEE ALSO
%  BAGSIZES, GETPOSITIVEBAGS, GENMIL, SETMILINFO

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function [bag,lab,bagll,Ibag] = getbags(x)

% Check:
% 1.check if the bags are defined
if ~hasmilbags(x)
	error('Dataset X should have MIL bag identifiers defined.');
end
% 2.check if the labels are defined or needed
if ismillabeled(x) & (nargout>1)
	makelab = 1;
	Ipos = ispositive(x);
else
	makelab = 2;
	Ipos = getlabels(x);
end
lab = [];
% 3. check if the combination rule is defined
copymethod = getmilinfo(x,'combinerule');
if isempty(copymethod)
	warning('No combining rule for instance labels to bag labels is defined, using ''presence''.');
	copymethod = 'presence';
end
	
% Extract the bag labels from x:
% the exception is when we don't have milbag identifiers, but we have a
% useFileAsBag flag in the user field
if ~isempty(getmilinfo(x,'useFileAsBag'))
	fi = getident(x,'file_index');
	[bagnlab,bagll] = renumlab(fi(:,1));
else
	[bagnlab,bagll] = renumlab(getident(x,'milbag'));
end
n = size(bagll,1);
% Just to be sure:
if ~isempty(find(bagnlab==0))
	warning('Some instances do not have a bag label!');
end

% For speedup (datasets only, they fit in memory):
if isdataset(x), x = +x; end

% Make sure we are not going to change the order of the bags
% (so we are not forced to use the order that renumlab gave us)
%first occurance of instances of all bags:
[foundll,I] = unique(bagnlab,'first');
% now, do not change the order of instances:
sortI = sort(I);
bagid = bagnlab(sortI);
bagll = bagll(bagid,:);

% Initialize:
bag = cell(n,1);
Ibag = cell(n,1);
% and go:
for i=1:n
	Ibag{i} = find(bagnlab==bagid(i));
	bag{i} = x(Ibag{i},:);
	% Invent the label of this bag:
	if makelab==1
		lab = [lab; labelset(Ipos(Ibag{i},:),copymethod)];
	elseif makelab==2
		lab = [lab; Ipos(Ibag{i}(1),:)]; % copy the first label...
	end
end
if makelab==1
	% transform the lab back from a numeric label to a string label:
	% (we know that 1=positive and 0=negative from labelset)
	ll = ['negative';'positive'];
	lab = ll(lab+1,:);
end

return
