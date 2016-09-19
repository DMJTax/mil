%GETMILINFO  Get MIL info from dataset
%
%     VALUE = GETMILINFO(A,FIELD)
%
% INPUT
%   A         MIL dataset
%   FIELD     Info field name (default = 'combinerule')
%
% OUTPUT
%   VALUE     Some output
%
% DESCRIPTION
% Retrieve the MIL parameters, given by FIELD, from dataset A. Possible
% parameters are given in SETMILINFO.
%
% SEE ALSO
%    SETMILINFO, RMMILINFO

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function value = getmilinfo(a,field)
if nargin<2
	field = 'combinerule';
end

ud = getuser(a);
if isempty(ud) | ~isfield(ud,'mil')
	value = [];
	return;
end
switch field % consistent with setmilinfo.m and rmmilinfo
case {'combrule' 'combinerule'}
	if ~isfield(ud.mil,'combinerule')
		warning('No MIL combine rule defined, using ''presence'.');
		value = 'presence';
	else
		value = ud.mil.combinerule;
	end
case {'useFileAsBag','usefileasbag'}
	if ~isfield(ud.mil,'useFileAsBag')
		value = '';
	else
		value = ud.mil.useFileAsBag;
	end
otherwise
	error('This field is not defined in a MIL dataset.');
end

return
