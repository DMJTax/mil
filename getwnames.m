%GETWNAMES Extract names from cell array of mappings
%
%    STR = GETWNAMES(W)
%
% INPUT
%   W    Cell-array of prmappings
%
% OUTPUT
%   STR  Cell-array of strings
%
% DESCRIPTION
% Extract the classifier names from a cell array of (possibly untrained)
% mappings. When the mapping is sequential, each mapping name is
% concatenated to the final string STR.
%
% SEE ALSO
% cellprintf, sprintf

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
function str = getwnames(w)

str = [];
if isa(w,'cell')
	% process each cell element separately:
	n = length(w);
	str = cell(n,1);
	for i=1:n
		str{i} = getwnames(w{i});
	end
else
	if ~ismapping(w)
		error('I cannot extract the classifier name.');
	end
	if isempty(getname(w)) && strcmp(getmapping_file(w),'sequential')
		% we are dealing with a combined mapping 
		% (recursion is cool... )
		str = [getwnames(w.data{1}),'+',getwnames(w.data{2})];
	else
		str = getname(w);
	end
end
return
