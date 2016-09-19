%HASMILBAGS Check for MIL bags
%
%   OUT = HASMILBAGS(A)
%
% INPUT
%   A      dataset
%
% OUTPUT
%   OUT    true if A has bags
%
% DESCRIPTION
% Check if dataset A contains bags of instances that are recognized in
% the MIL toolbox. For that, extra identifiers have to be defined for
% each object, indicating the index of the bag the object belongs to.
% The identifier should be called 'milbag'.
%
% SEE ALSO
% ismillabeled, ismilset, genmil

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = hasmilbags(a)

if ~isdataset(a)
   out = 0;
   return
end
bagid = [];
% first check if I use the file_index as milbag:
if ~isempty(getmilinfo(a,'useFileAsBag'))
	% check if the file_index is anyway present
	id = a.ident;
	if isfield(id,'file_index')
		bagid = 1;
	end
else
	% check if the bag identifier is present
	id = a.ident; % this is harsh, but I want to avoid a warning when the
					  % identifier does not exist
	if isfield(id,'milbag')
		bagid = 1;
	end
end
out = ~isempty(bagid);
if (nargout==0) & ~out
	error('Identifier milbag is not present.');
end

return
