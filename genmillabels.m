%GENMILLABELS Generate MIL labels
%
%     LAB2 = GENMILLABELS(LAB1,TARGETCL)
%     LAB2 = GENMILLABELS(NLAB)
%
% INPUT
%    LAB1       vector of (string) labels
%    TARGETCL   class name that will be 'positive'
%    NLAB       vector of (numeric) labels
%
% OUTPUT
%    LAB2       vector of labels
%
% DESCRIPTION
% Make a MIL labeling containing 'positive' and 'negative' labels, by
% replacing the label TARGETCL in labels LAB1 by 'positive' and all the
% others by 'negative'.  When TARGETCL is not given, 'target' is
% assumed.
%
% When an index vector NLAB is given, 'positive' is returned for NLAB=1
% and 'negative' for NLAB=0.
%
% SEE ALSO
% genmil, find_positive

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [lab,I,ll] = genmillabels(a,targetcl)

if nargin<2
	targetcl = '1';
end
if isdataset(a)
	a = getlab(a);
end

if nargin<2 & isa(a,'logical')
	% generate 'positive'/'negative' from an index array
	I = a;
else
	% the labels are strings, and we have to match:
	I = zeros(size(a,1),1);
	if nargin<2  % when no targetcl is given, assume 'target'
		I(strmatch('target',a)) = 1;
	else
		targetcl = strvcat(targetcl);
		for i=1:size(targetcl,1)
			I(strmatch(targetcl(i,:),a)) = 1;
		end
	end
end

if sum(I)==0
	warning('mil:genmillabels:noLabelsFound',...
	   'No labels %s found.\n',targetcl);
end

ll = ['negative';
      'positive'];
I = I+1;
lab = ll(I,:);

return
