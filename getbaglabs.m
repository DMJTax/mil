%GETBAGLABS Get bag labels from MIL set
%
%      [LAB,BAGID,IBAG] = GETBAGLABS(X)
%
% INPUT
%    X          MIL-dataset or MIL-datafile
%
% OUTPUT
%    LAB        Bag labels
%    BAGID      Original identifier of each bag
%    IBAG       Indices of the objects in the bags
%
% DESCRIPTION
% Same as GETBAGS(X) without the actual bags. This only retrieves the
% labels and is faster for large datasets, if you only need the labels.
%
% SEE ALSO
%  GETBAGS

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [lab,bagll,Ibag] = getbaglabs(x)

% Check:
% 1.check if the bags are defined
if ~hasmilbags(x)
	error('Dataset X should have MIL bag identifiers defined.');
end
% 2.check if the labels are defined or needed
if ismillabeled(x)
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

Ibag = cell(n,1);
% and go:
for i=1:n
	Ibag{i} = find(bagnlab==bagid(i));
    
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
