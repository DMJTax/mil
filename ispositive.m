%ISPOSITIVE
%
%     OUT = ISPOSITIVE(A)
%
% INPUT
%   A     Dataset or label
%
% OUTPUT
%   OUT   True if A is 'positive', otherwise false.
%
% DESCRIPTION
% Returns TRUE (=1) when an object or label in A is 'positive' and FALSE
% (=0) otherwise. When A is a dataset, the output will be a vector
% containing 0 or 1 per object/row.
%
% SEE ALSO
% ismillabeled, hasmilbags, find_positive

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function I = ispositive(a)

if isdataset(a)
	%if ismillabeled(a)
	if ~isempty(strmatch('millab',getlablistnames(a)))
		a = changelablist(a,'millab');
	end
	[nlab,lablist] = getnlab(a);
elseif isa(a,'char')
	[nlab,lablist] = renumlab(a);
elseif isa(a,'cell')
   a = cell2mat(a);
	[nlab,lablist] = renumlab(a);
else
	%error('I cannot handle input A.');
    nlab = zeros(size(a,1),1); lablist = [];
end

nr_p = strmatch('positive',lablist);
if isempty(nr_p)
	if nargout<1
		warning('mil:ispositive:NoPositivePresent',...
			'Cannot find positive objects in dataset.');
	end
	I = zeros(size(nlab,1),1);
else
	if length(nr_p)>1
		warning('More than one class is ''positive''.');
	end
	I = (nlab==nr_p);
end

return

