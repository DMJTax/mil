%GENDATMILG Generate Gaussian MIL problem
%
%      X = GENDATMILG([N1 N2],NP,D,DIM)
%
% INPUT
%    N1,N2     Number of pos. and neg. bags
%    NP        Number of instances in the concept (default=1)
%    D         Position of the positive concept (default=7)
%    DIM       Number of features (only the first two are informative)
%
% OUTPUT
%    X         Artificial MIL dataset
%
% DESCRIPTION
% Generate an artificial multi-instance learning problem.  For the N1
% positive bags NP(1) instances are drawn from the positive concept
% Gaussian centered around (D,1), and a random set of instances is drawn
% from a background Gaussian distribution round (0,0). This number is
% between 1 and 10-NP.  For the N2 negative bags, NP(2) instances are
% drawn from the positive concept, and the rest is drawn from the
% background distribution. When NP(2) is not defined, NP(2)=0.
%
% When DIM>2 is defined, extra features are added such that the total
% number of features is DIM. The added features all have an identical
% unit-variance Gaussian distribution.
%
% SEE ALSO
%   GENMIL, GENDATMIL, GENDATMILD, GENDATMILC

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function x = gendatmilg(n,np,d,dim)
if nargin<4
	dim = 2;
end
if nargin<3
	d = 7;
end
if nargin<2
	np = 1;
end
if nargin<1
	n = 50;
end
if length(n)<2
	n = genclass(n,[0.6 0.4]);
end

% how many instances are maximally per bag?
instperbag = [5 10];
if any(np>instperbag(2))
	error('Only maximally %d instance per bag can be positive.',...
	instperbag(2));
end
% number of instances per bag:
m = floor((instperbag(2)-instperbag(1))*rand(sum(n),1)) + instperbag(1);

% generate the positives
meanp = repmat([d 1],np(1),1);
x = [];
for i=1:n(1)
	x = [x; randn(np(1),2)+meanp; randn(m(i)-np(1),2)];
end
% and the negatives
if length(np)==1
	np(2) = 0;
end
meanp = repmat([d 1],np(2),1);
for i=(n(1)+1):(n(1)+n(2))
	x = [x; randn(np(2),2)+meanp; randn(m(i)-np(2),2)];
end
% Extend the features by just adding identical gaussian noise
if dim>2
	x = [x randn(size(x,1),dim-2)];
end

nn = [sum(m(1:n(1)));
      sum(m((n(1)+1):(n(1)+n(2))))];

% and the labels:
classlab = genlab(nn,{'positive';'negative'});
baglab = genlab(m);

% store everything:
x = genmil(x,classlab,baglab,np(1));
x = setname(x,'Gaussian-MI (np=%d,nn=%d)',np(1),np(2));

return

