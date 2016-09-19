%GENDATMILM Generate Maron's MIL problem
%
%      X = GENDATMILM([N1 N2],NR_POS,INSTPERBAG)
%
% INPUT
%    N1,N2       Number of pos. and neg. bags
%    NR_POS      Number of positive instances in a positive bag
%                (default = 1)
%    INSTPERBAG  Minimum and maximum number of instances per bag
%                (default = [50 50])
%
% OUTPUT
%    X           Artificial MIL dataset
%
% DESCRIPTION
% Generate an artificial multi-instance learning problem, that of the
% Maron paper.  For the N1 positive bags at least 1 instance is drawn
% from the positive concept (a block in the middle of a field of
% 100x100).  A random set of instances is drawn from a uniform
% background distribution.
%
% SEE ALSO
%   GENMIL, GENDATMIL, GENDATMILG, GENDATMILC

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function x = gendatmilm(n,np,instperbag)
if nargin<3
	% how many instances are maximally per bag?
	instperbag = [50 50];
end
if nargin<2
	% number of positive instances per bag
	np = 1;
end
if nargin<1
	n = 10;
end
if length(n)<2
	n = genclass(n,[0.5 0.5]);
end

% number of instances per bag:
m = floor((instperbag(2)-instperbag(1))*rand(sum(n),1)) + instperbag(1);

% generate the positives
meanp = repmat([50 50],np,1);
x = [];
for i=1:n(1)
	x = [x; 5*rand(np,2)+meanp; 100*rand(m(i)-np,2)];
end
poslen = size(x,1);
% and the negatives
for i=(n(1)+1):(n(1)+n(2))
	x = [x;100*rand(m(i),2)];
end

nn = [sum(m(1:n(1)));
      sum(m((n(1)+1):(n(1)+n(2))))];

% and the labels:
classlab = genlab(nn,{'positive';'negative'});
baglab = genlab(m);

% store everything:
x = genmil(x,classlab,baglab,np(1));
x = setname(x,'Maron-MI');

%AARGH, by the random generateion of negative objects, they can appear
%inside the block!!
% remove them:
I1 = (+x(:,1)>=50)&(+x(:,1)<=55);
I2 = (+x(:,2)>=50)&(+x(:,2)<=55);
%I1 = (+x(:,1)>=40)&(+x(:,1)<=65);
%I2 = (+x(:,2)>=40)&(+x(:,2)<=65);
I = (I1&I2);
% do not remove instances from the first n(1) bags, they are positive:
I(1:poslen) = 0;
x = x(~I,:);

return

