%GENDATMILW Widened MIL dataset
%
%     a = gendatmilw(n,width,dim)
%
% INPUT
%   N       Number of pos. and neg. bags
%   WIDTH   Multiplication factor for the width (default = 1.1)
%   DIM     Dimensionality (default = 2)
%
% OUTPUT
%   A       MIL dataset
%
% DESCRIPTION
% Make a MIL dataset where all instances in a bag are informative. The
% positive class distribution is slightly wider (multiplied by WIDTH)
% than the negative class distribution. 
%
% SEE ALSO
% GENDATMILR

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = gendatmilw(n,wscale,dim)
if nargin<3
	dim = 2;
end
if nargin<2
	wscale = 1.1; % 10% wider
end
if nargin<1
	n = [30 30];
end

% Determine the number of bags per class:
if length(n)<2
	n = genclass(n,[0.5 0.5]);
end

% Determine how many instances per bag:
instperbag = [15 30];
m = floor((instperbag(2)-instperbag(1))*rand(sum(n),1)) + instperbag(1);

% Generate positive bags:
x = [];
for i=1:n(1)
	x = [x; wscale*randn(m(i),2)];
end
% and the negative bags:
for i=(n(1)+1):(n(1)+n(2))
	x = [x; randn(m(i),2)];
end

% Extend the features if required:
if dim>2
	x = [x randn(size(x,1),dim-2)];
end

% The total number of positive and negative instances:
nn = [sum(m(1:n(1)));
      sum(m((n(1)+1):(n(1)+n(2))))];
% Generate the labels:
classlab = genlab(nn,{'positive';'negative'});
baglab = genlab(m);

% Store everything:
x = genmil(x,classlab,baglab);
x = setname(x,'Widened-MI (w=%f)',wscale);

return


