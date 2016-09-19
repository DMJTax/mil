%OC2MILSET Convert a OC to a MIL set
%
%       A = OC2MILSET(B)
%
% INPUT
%   B     OC Dataset
%
% OUTPUT
%   A     MIL dataset
%
% Convert the labels of a one-class set B to a multi-instance-learning
% label set A. It means that labels 'target'/'outlier' are converted
% into 'positive'/'negative'.
% Note that no MIL identifiers are added/changed.
%
% SEE ALSO
% mil2ocset

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = oc2milset(b)

isocset(b);
% find the targets in the milset:
Itar = istarget(b);
% generate occ labels:
ll = ['negative';'positive'];
lab = ll(Itar+1,:);
% add a new labelset
names = getlablistnames(b);
if isempty(strmatch('millab',names))
	a = addlabels(b,lab,'millab');
else
	a = changelablist(b,'millab');
end

% shall we also change the feature labels??
fl = getfeatlab(b);
ind = zeros(size(fl,1),1);
Ip = strmatch('target ',fl);
In = strmatch('outlier',fl);
ind(Ip) = 1;
ind(In) = 1;
if all(ind)
	warning('mil:mil2ocset:PosNeg',...
	   'The feature labels contained target and outlier.\n         This is changed to positive and negative.',1);
	if ~isempty(Ip)
		newlab(Ip,:) = 'positive';
	end
	if ~isempty(In)
		newlab(In,:) = 'negative';
	end
	a = setfeatlab(a,newlab);
end

