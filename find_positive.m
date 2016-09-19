%FIND_POSITIVE Find objects labeled positive 
%
%     [I1,I2] = FIND_POSITIVE(A)
%
% INPUT
%    A       MIL dataset
%
% OUTPUT
%    I1      Indices of the objects labeled 'positive'
%    I2      Indices of the objects labeled 'negative'
%
% SEE ALSO
%   ISPOSITIVE,GETBAGS

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [I1,I2] = find_positive(a)

% first find the logical vector of the positive objects:
I = ispositive(a);

% extract the indices:
I1 = find(I);

% if requested, also find the negative objects:
if (nargout>1)
	I2 = find(~I);
end

return
