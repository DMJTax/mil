%RMMILINFO Remove MIL info from dataset
%
%    A = RMMILINFO(A,FIELD)
%
% INPUT
%   A        MIL dataset
%   FIELD    Field name
%
% OUTPUT
%   A        MIL dataset
%
% DESCRIPTION
% Remove the MIL meta data that may be present in dataset A.
% Possible FIELDs are defined in setmilinfo.m
%
%SEE ALSO
%    SETMILINFO, GETMILINFO, LABELSET

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function a = rmmilinfo(a,field)
if nargin<2
   field = [];
end

ud = getuser(a);
if ~isempty(ud) & isfield(ud,'mil')
	if isempty(field)
		ud = rmfield(ud,'mil');
	else
		mil = ud.mil;
		switch field % consistent with setmilinfo.m and rmmilinfo
		case {'combrule' 'combinerule'}
			mil = rmfield(mil,'combinerule');
		case {'useFileAsBag','usefileasbag'}
			mil = rmfield(mil,'useFileAsBag');
		otherwise
			error('This field is not defined in a MIL dataset.');
		end
		ud.mil = mil;
	end
	a = setuser(a,ud);
end

return


