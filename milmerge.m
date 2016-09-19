%MILMERGE Merge two MIL datasets
%
%       C = MILMERGE(A,B)
%
% INPUT
%   A,B    MIL dataset
%
% OUTPUT
%   C      MIL dataset
%
% DESCRIPTION
% Concatenate two MIL datasets, taking care that the bag identifiers are
% not clashing. When the bag identifiers in dataset A and B are
% somewhere equal, bag identifiers are changed such that in C still the
% original bags can be stored.
%
% SEE ALSO
%  BAGSIZES, GETBAGS, GENMIL

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function c = milmerge(a,b)

% get the different bag-labels
[abags,alab,abagll] = getbags(a);
[bbags,blab,bbagll] = getbags(b);
if ~isa(abagll,class(bbagll))
	error('The bag identifiers are not compatible.');
end

% and check if there is overlap between these identifiers:
i = intersect(abagll,bbagll,'rows');

if isempty(i)
	% no overlap: no danger, so just concatenate and leave:
	c = [a;b];
	return;
end

% Otherwise we have to work:
if ~isempty(getmilinfo(a,'useFileAsBag'))
	error('Identical bagidentifiers in first datafile found; I cannot rename files.');
end
if ~isempty(getmilinfo(b,'useFileAsBag'))
	error('Identical bagidentifiers in second datafile found; I cannot rename files.');
end

if isa(abagll,'double')
	% when the bag identifiers are doubles, we can just *add* a number to
	% the identifiers of b (the maximum what appears in a):
	newlab = getident(b,'milbag') + max(abagll);
	b = setident(b,newlab,'milbag');
else
	%disp('Identical bag identifiers found! Now what....');
	newlaba = [repmat([inputname(1),'_'],size(a,1),1),getident(a,'milbag')];
	a = setident(a,newlaba,'milbag');
	newlabb = [repmat([inputname(2),'_'],size(b,1),1),getident(b,'milbag')];
	b = setident(b,newlabb,'milbag');
end

c = [a;b];

