%ISMILSET Check if dataset is MIL
%
%    OUT = ISMILSET(A,LABELED)
%
% INPUT
%   A         Dataset
%   LABELED   Flag to test for correct labels (default = 1)
%
% OUTPUT
%   OUT       True if A is correctly MIL 
%
% DESCRIPTION
% Test if dataset A is MIL. It should have
% 1. bags defined,
% 2. 'positive'/'negative' labels defined.
% When LABELED=0, the second check is not performed, but only the first
% one.
%
% SEE ALSO
% ismillabelled, hasmilbags

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function out = ismilset(a,labeled)
if nargin<2
	labeled=1;
end

% We start with a positive attitude:
out = 1;

% check if it is a dataset (pretty basic...)
if ~isdataset(a)
	out = 0;
	if nargout==0
		disp('A is not a dataset.');
      clear out;
	end
   return
end

% bags defined?
out = hasmilbags(a);

% if the bags are defined, and the user also want to check the labels,
% then also look if the labels are correct:
if out & labeled
	out = ismillabeled(a);
end

% give something on the commandline when nargout=0
if (nargout==0) & ~out
	error('Dataset is not MIL.');
end
return
