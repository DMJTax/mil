%MISSINGVALUES Fix the missing values in a dataset
%
%          [Y,MSG] = MILMISSINGVALUES(X,VAL)
%
% INPUT
%   X       Dataset
%   VAL     String or value
%
% OUTPUT
%   Y       Dataset
%   MSG     String
%
% DESCRIPTION
% Fix the missing values (represented by NaN's) in dataset X. String MSG
% gives a text message of what has been done.
%
% The following values VAL are possible:
%          'remove'     remove entries that contain missing values
%          'mean'       fill the entries with the mean of their 
%                       respective column
%          <value>      fill the entries with a fixed constant
%
% SEE ALSO
% datasets

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [x,msg] = milmissingvalues(x,val)

% do nothing if val is empty
msg = '';
if isempty(val)
	return;
end

% Where are the offenders?
%I = isnan(x);
I = ~isfinite(x); % also capture inf and -inf

% If there are missing values, go:
if any(I(:))
	switch val
	case {'remove' 'delete'}
		I = find(sum(I,2)==0);
		x = x(I,:);
		msg = 'Entries with missing values have been removed.';
	case 'mean'
		k = size(x,2);
		for i=1:k
			J = ~I(:,i);
			if any(I(:,i)) %is there a missing value in this feature?
				if ~any(J)
					error('Missing value cannot be filled: all values are NaN.');
				end
				mn = mean(x(J,i));
				x(find(I(:,i)),i) = mn;
			end
		end
		msg = 'Missing values have been replaced by the mean of the feature.';
	otherwise
		if ~isa(val,'double')
			error('Missing values can only be filled by scalars.');
		end
		x(I) = val;
		msg = sprintf('Missing values have been replaced by %f.',val);
	end
end
return

