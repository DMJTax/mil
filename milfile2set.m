%MILFILE2SET Convert MIL datafile to dataset
%
%      X = MILFILE2SET(X,MISSINGVALUES)
%
% INPUT
%     X               Datafile MIL set
%     MISSINGVALUES   Parameter for milmissingvalues.m (default = '')
%
% OUTPUT
%     X               MIL dataset
%
% DESCRIPTION
% Convert the MI data*file* X into a MIL dataset. Note that you cannot
% simply use DATASET(X), because then the bag identifiers will get lost
% (they are not stored in the identifiers, but in the file_index
% identifier).
%
% Because the MI datafile often contains quite noisy files, it is
% sometimes necessary to clean/treat the data. It is possible to give an
% optional parameter MISSINGVALUES to do that. See for the options
% milmissingvalues.m
%
% SEE ALSO
%   GENMIL, UNMIL, MILMISSINGVALUES

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = milfile2set(x,missingvalues)
if nargin<2
	missingvalues = '';
end

if ~isdatafile(x)
	% we already have a dataset
	return;
end
if ~hasmilbags(x)
	warning('No MIL bags are defined in x.');
end
if ~isempty(getmilinfo(x,'useFileAsBag'))
	% copy it to the normal milbag identifier
	fi = getident(x,'file_index');
	x = setident(x,fi(:,1),'milbag');
	% remove the useFileAsBag-flag
	x = rmmilinfo(x,'useFileAsBag');
end
% do the conversion by standard prtools
x = prdataset(x);

% some nans/inf may exist, do something about it:
if ~isempty(missingvalues)
	[x,msg] = milmissingvalues(x,missingvalues);
	if ~isempty(msg)
		mil_message(1,'milfile2set: %s',msg);
	end
end

return
