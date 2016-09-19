%UNMIL Remove MIL bag identifiers
%
%      X = UNMIL(X)
%
% INPUT
%     X   MIL dataset
%
% OUTPUT
%     X   Standard prtools dataset
%
% DESCRIPTION
% Remove the 'milbag' identifiers and mil-meta-data stored in the
% user-field from dataset X.
%
% SEE ALSO
%  GENMIL, ISMILSET, RMMILINFO

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = unmil(x)

% test if we are working with a datafile with the bag identifiers stored
% in the file_index field, or in the 'milbag' identifier.
if isempty(getmilinfo(x,'useFileAsBag'))
	id = x.ident;
	if ~isfield(id,'milbag')
		warning('mil:unmil:noMilIdent','No milbag-identifier defined. Nothing to do.');
		return
	end
	id = rmfield(id,'milbag');
	x.ident = id;  %this is all folks
end
x = rmmilinfo(x); % remove all other data in the userfield

return
