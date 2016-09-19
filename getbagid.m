%GETBAGID Extract bag identifiers from MIL dataset
%
%     BAGID = GETBAGID(X)
%
% INPUT
%   X       MIL dataset
%
% OUTPUT
%   BAGID   Bag labels
%
% DESCRIPTION
% Extract the bag identifiers for each instance from MIL dataset X.
%
% SEE ALSO
%  GETBAGS, GENMIL, BAGSIZES

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function baglab = getbagid(x)

% the exception is when we don't have milbag identifiers, but we have a
% useFileAsBag flag in the user field
if ~isempty(getmilinfo(x,'useFileAsBag'))
	baglab = getident(x,'file_index');
else
	baglab = getident(x,'milbag');
end

