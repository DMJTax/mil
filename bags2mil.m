%BAGS2MIL Combine a cell-array of bags to MIL dataset
%
%    A = BAGS2MIL(BAGS,BAGLAB,COMBRULE)
%
% INPUT
%   BAGS        Cell-array of bags
%   BAGLAB      Label vector
%   COMBRULE    Rule for instance to bag label
%
% OUTPUT
%   A           MIL dataset
%
% DESCRIPTION
% Combine the bags that are stored as cell-array BAGS into a new MIL
% dataset A. The bags/instances will be labeled according to the labels
% that are stored in BAGLAB. The instances will be consistently labeled,
% i.e. all instances get the same label as the bag. The combination rule
% to get from instance labels to bag labels can be given in COMBRULE
% (see MILCOMBINE to find the possible values). In a way, BAGS2MIL is the
% inverse of GETBAGS.
%
% SEE ALSO
% getbags, genmil, milcombine

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function b = bags2mil(a,laba,combrule)
if nargin<3
	combrule = 'presence';
end

% check that a is a cellarray:
if ~isa(a,'cell')
	error('A should be a cell array');
end

n = length(a);
if size(laba1)~=n
	error('The number of labels should match the number of cells.');
end
% run over the bags and combine
b = []; labb = []; baglab = [];
for i=1:n
	m = size(a{i},1);
	b = [b; a{i}];
	labb = [labb; repmat(laba(i,:),m,1)];
	baglab = [baglab; repmat(i,m,1)];
end

b = genmil(b,labb,baglab,combrule);

return
