%GENDATMILR Rotated MIL dataset
%
%      A = GENDATMILR(N,PHI,DIM)
%
% INPUT
%   N      Number of pos. and neg. bags
%   PHI    Angle (default = pi/18)
%   DIM    Dimensionality (default = 2)
%
% OUTPUT
%   A      MIL dataset
%
% DESCRIPTION
% Make a MIL dataset where all instances in a bag are informative, but
% where the positive and negative instances have a different
% distribution. The instances are drawn from an elongated Gaussian
% distribution. Instances from positive bags are drawn from a slightly
% rotated version of the negative instance distribution.
%
% When DIM>2, additional features are added where all the instances just
% have a unit-variance Gaussian distribution.
%
% SEE ALSO

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = gendatmilr(n,phi,dim)
if nargin<3
	dim = 2;
end
if nargin<2
	phi = pi/18; % 10 degrees
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

% Define the cov.matrix and rotation matrix:
S = sqrt([1 40]);
R = [1 -1; 1 1]./sqrt(2); % standard 45 degrees
Rp = [cos(phi) sin(phi); -sin(phi) cos(phi)];

% Generate positive bags:
xp = [];
for i=1:n(1)
	xp = [xp; randn(m(i),2).*repmat(S,m(i),1)];
end
% rotate it:
xp = xp*R*Rp;

% and the negative bags:
xn = [];
for i=(n(1)+1):(n(1)+n(2))
	xn = [xn; randn(m(i),2).*repmat(S,m(i),1)];
end
% rotate it:
xn = xn*R;
% Combine the positive and negative:
x = [xp;xn];

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
x = setname(x,'Rotated-MI (phi=%f)',phi);

return


