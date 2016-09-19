%GENDATMILD Difficult MIL dataset
%
%      X = GENDATMILD([N1,N2],NP,D,DIM)
%
% INPUT
%     N1,N2       Number of pos. and neg. bags
%     NP          Number of instances in the concept (default = [1 0])
%     D           Position of positive concept (default = 4)
%     DIM         Number of features (default = 2)
%
% OUTPUT
%     X           Artificial MIL dataset
%
% DESCRIPTION
% Generate a 'difficult' MIL dataset X, where the positive instances are
% very close to the negative ones. Both positive and negative instances
% are drawn from very elliptical Gaussian distributions, that differ in
% mean in the first feature by a value of D. Only the first
% 2 features of the total of DIM features are informative, the other are
% Gaussian noise. The number of positive instances in each positive (and
% negative) bag is NP(1) (or NP(2), respectively).
%
% SEE ALSO
% genmil

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = gendatmild(n,np,d,dim)

if nargin<4
	dim = 2;
end
if nargin<3
	d = 4;
end
if nargin<2
	np = 1;
end
if nargin<1
	n = [10 40];
end

% Determine the number of bags per class:
if length(n)<2
	n = genclass(n,[0.2 0.8]);
end

% Determine how many instances per bag:
instperbag = [5 10];
if any(np>instperbag(2))
	error('Only %d instances per bag can be positive.', instperbag(2));
end
m = floor((instperbag(2)-instperbag(1))*rand(sum(n),1)) + instperbag(1);

% Define the cov.matrix and rotation matrix:
S = sqrt([1 40]);
R = [1 -1; 1 1]./sqrt(2);

% Generate positive bags:
x = [];
meanp = repmat([d 1],np(1),1);
for i=1:n(1)
	x = [x; randn(np(1),2).*repmat(S,np(1),1)+meanp; ...
	     randn(m(i)-np(1),2).*repmat(S,m(i)-np(1),1)];
end
% and the negative bags:
% (when the number of positive instances in the negative bags is not
% defined, set it to zero)
if length(np)==1 
	np(2) = 0;
end
meanp = repmat([d 1],np(2),1);
for i=(n(1)+1):(n(1)+n(2))
	x = [x; randn(np(2),2).*repmat(S,np(2),1)+meanp; ...
	     randn(m(i)-np(2),2).*repmat(S,m(i)-np(2),1)];
end
% rotate it:
x = x*R;
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
x = genmil(x,classlab,baglab,np(1));
x = setname(x,'Difficult-MI (np=%d,nn=%d)',np(1),np(2));

return
