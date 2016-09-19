%ISMILLABELED Test if dataset is MIL and labeled
%
%    OUT = ISMILLABELED(A)
%
% INPUT
%   A     Dataset
%
% OUTPUT
%   OUT   True if A is correctly MIL labeled
%
% DESCRIPTION
% Test if dataset A is a correctly labeled MIL dataset. For that it
% should have: the correct class labels ('positive' and 'negative') in
% the 'millab' lablist.
%
% SEE ALSO
%  ISMILSET, HASMILBAGS

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = ismillabeled(a)
out = 1;
% check if it is a dataset
if ~isdataset(a)
   out = 0;
   if nargout==0
      disp('Input is not a dataset.');
      clear out;
   end
   return
end
% check if the milclass is present
names = getlablistnames(a);
if isempty(strmatch('millab',names))
	% maybe the current labels are positive-negative, but does it only
	% have a wrong lablist name:

   if ~isempty(getlab(a))
      out = ismillabeled(addlabels(a,getlab(a),'millab'));
   else
      out = 0;
   end
	if nargout>0
		return
	else
		if ~out
			error('Labels millab is not present.');
		end
	end
else
	% now check if the lablist of milclass contains only positive and/or
	% negative:
	[thisnr,thisname] = curlablist(a);
	if ~strcmp(thisname,'millab')
		warning('mil:ismillabeled:NotCurrentLab',...
			'Current label is not ''millab''.');
		a = changelablist(a,'millab');
	end
	lablist = getlablist(a);
	if isempty(lablist)
		%warning('mil:ismillabeled:EmptyLables','No labels are defined.');
		I = 0;
	else
		I = zeros(size(lablist,1),1);
	end
	% flag all labels that are 'positive'
	I(strmatch('positive',lablist)) = 1;
	% flag all labels that are 'negative'
	I(strmatch('negative',lablist)) = 1;
	% sooo, and who is not flagged?
	if any(I==0)
		out = 0;
		if nargout>0
			return
		else
			error('Lablist millab contains other labels than positive and negative.');
		end
	else
		if nargout==0
			%disp('The set is MIL. Congratulations.');
		end
	end
end
