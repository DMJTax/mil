%BAGSIZES Get sizes of the bags from MIL set
%
%      N = BAGSIZES(X)
%
% INPUT
%    X          MIL-dataset or MIL-datafile
%
% OUTPUT
%    N          Vector containing the size of each bag
%
% DESCRIPTION
% Extract the size of each individual bags from MIL dataset X.
%
% SEE ALSO
%  MILCOMBINE, GETBAGS, GETPOSITIVEBAGS, GENMIL, SETMILINFO

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function sz = bagsizes(x)

% I allow two possibilities: (1) a cell array, or (2) a MIL dataset:
if isa(x,'cell')
    n = length(x);
    sz = zeros(n,1);
    for i=1:n
        sz(i) = size(x{i},1);
    end
    return
end

% Check for MIL dataset:
% 1.check if the bags are defined
if ~hasmilbags(x)
	error('Dataset X should have MIL bag identifiers defined.');
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

% Make sure we are not going to change the order of the bags
% (so we are not forced to use the order that renumlab gave us)
df = [1; find(diff(bagnlab))+1];
bagid = bagnlab(df);

% Initialize:
sz = zeros(n,1);
% and go:
for i=1:n
	sz(i) = sum(bagnlab==bagid(i));
end

return
