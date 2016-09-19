%SETMILINFO Set MIL parameters in dataset
%
%       A = SETMILINFO(A,FIELD,VALUE)
%
% INPUT
%   A      MIL dataset
%   FIELD  Field to set
%   VALUE  Value to store
%
% OUTPUT
%   A      MIL dataset
%
% DESCRIPTION
% Set some parameters, given by FIELD, in dataset A to a value VALUE.
% The possible parameters are:
%    FIELD          VALUE
%    'combinerule'  Combination rule to fuse instance labels to bag
%                   labels (see also  LABELSET)
%    'useFileAsBag' = 1 Use each file in a datafile object as a bag
%
%SEE ALSO
%    LABELSET, GETMILINFO, RMMILINFO, MILBAG

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function a = setmilinfo(a,field,value)

ud = getuser(a);
if ~isempty(ud) & isfield(ud,'mil')
	mil = ud.mil;
else
	mil = [];
end
switch field % consistent with setmilinfo.m and rmmilinfo
case {'combrule' 'combinerule'}
	mil.combinerule = value;
case {'useFileAsBag','usefileasbag'}
	mil.useFileAsBag = value;
otherwise
	error('This field is not defined in a MIL dataset.');
end
ud.mil = mil;
a = setuser(a,ud);

return

