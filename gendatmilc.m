%GENDATMILC Concept MIL dataset
%
%     X = GENDATMILC(N,DIM,S,INSTPERBAG)
%
% INPUT
%    N     Number of objects (poss. per class) (default = 10)
%    DIM   Dimensionality (default = 2)
%    S     Cluster variance in all directions (default = 1)
%    INSTPERBAG  Number of instances per bag (default = [5 10])
%
% OUTPUT
%    X     MIL dataset
%
% DESCRIPTION
% Generation of the MIL dataset X. Instances are randomly drawn from 4
% standard Gaussian distributions with centers [+2,-2], [-2,+2] or
% [-2,-2].  When the bag is positive, at least one instance is also
% drawn from [+2,+2]. The total number of instances per bag is uniform
% between INSTPERBAG(1) and INSTPERBAG(2).
%
% When the dimensionality DIM >2 there is Gaussian noise added in the
% other dimensions. The variance can changed by adapting S.
%
% SEE ALSO
%   GENMIL, GENDATMILG

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = gendatmilc(n,dim,s,instperbag)
if nargin<4
	% define the minimum and maximum number of instances per bag
	instperbag = [5 10];
end
if nargin<3
	s = 1;
end
if nargin<2
	dim = 2;
end
if nargin<1
	n = 10;
end
if length(n)<2
	n = genclass(n,[0.5 0.5]);
end
% for small dimensions it will not work:
if dim<2
	error('For dimensionality<2 this dataset is not defined.');
end
% number of instances per bag:
m = floor((instperbag(2)-instperbag(1))*rand(sum(n),1)) + instperbag(1);

% choose positives:
I = [];
for i=1:n(1)
	J = ceil(4*rand(m(i),1));  % index of the clusters.
	isJ1 = find(J==1);
	if isempty(isJ1)
		%at least one instance should be positive
		% I take it the first one:
		J(1) = 1;
	else % swap it with the first position:
		J(isJ1(1)) = J(1);
		J(1) = 1;
	end
	I = [I;J];
end
% and the negatives:
for i=1:n(2)
	I = [I; 1+ceil(3*rand(m(i+n(1)),1))];
end
% define cluster centers:
meanc = [+2 +2; +2 -2; -2 -2; -2 +2];
meanc = [meanc zeros(4,dim-2)];

% now create the dataset:
x = zeros(sum(m),dim);
for i=1:4
	J = find(I==i);
	x(J,:) = repmat(meanc(i,:),length(J),1) + s*randn(length(J),dim);
end
% and the labels:
nn = [sum(m(1:n(1)));
      sum(m((n(1)+1):(n(1)+n(2))))];

% and the labels:
classlab = genlab(nn,{'positive';'negative'});
baglab = genlab(m);

% store everything:
x = genmil(x,classlab,baglab,'presence');
x = setname(x,'MI-concept'); 

return

