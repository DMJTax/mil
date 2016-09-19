%GETPOSITIVEBAGS
%
%    [XP,XN,IP,IN] = GETPOSITIVEBAGS(X)
%    [XP,XN,IP,IN] = GETPOSITIVEBAGS(BAGS,BAGLAB)
%
% INPUT
%   X       MIL dataset
%   BAGS    cell array with bags
%   BAGLAB  Bag labels
%
% OUTPUT
%   XP      cell array with positive bags
%   XN      cell array with negative bags
%   IP      indices of positive bags
%   IN      indices of negative bags
%
% DESCRIPTION
% Split the dataset X into the positive bags XP and the negative bags
% XN. The labels inside on bag are combined using the combination rule
% (see also labelset.m) that is stored in the definition of the MIL
% dataset. The indices of the objects inside the bag are returned in IP
% and IN.
%
% Instead of extracting the bags from the dataset you can also extract
% it from already extracted BAGS with their labels BAGLAB.
%
% SEE ALSO
%   LABELSET, GETBAGS, FIND_POSITIVE

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function [xp,xn,Ip,In] = getpositivebags(x,lab)
if nargin<2
	lab = '';
end

% First the bags:
if ismilset(x)
	[bags,lab,bagid,Ibag] = getbags(x);
	if isempty(lab)
		error('No labels have been defined.');
	end
else
	bags = x;
end
[labpos,labneg] = find_positive(lab);

% Collect the positive and negative bags:
xp = bags(labpos);
xn = bags(labneg);
if nargout>2
	Ip = Ibag(labpos);
	In = Ibag(labneg);
end
return
