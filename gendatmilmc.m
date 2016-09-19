%GENDATMILMC Generate MIL problems with multiple concepts
%
%    A = GENDATMILMC(N,C,SIG)
%
% INPUT
%   N      Number of positive and negative bags
%   C      One of the four concepts (default = 1)
%   SIG    Variance (default = 0.1)
%
% OUTPUT
%   A      MIL dataset
%
% DESCRIPTION
% Generation of a MIL dataset where 4 concepts are defined. These
% concepts are far from the bulk/background of the data, and have a
% Gaussian distribution with variance SIG. Positive bags have 50% chance
% to generate an instance in each concept, and there is 100% chance to
% generate an instance in concept C.
% 
% SEE ALSO
% genmil
function a = gendatmilmc(n,c,sig)
if nargin<3
	sig = 0.1;
end
if nargin<2 || isempty(c)
	c = 1;
end
if nargin<1 || isempty(n)
	n = [10 20];
end

if isempty(intersect(c,[1 2 3 4]))
	error('Please choose one concept between 1 and 4.');
end

% how many bags?
prior = [0.5 0.5];
n = genclass(n,prior);
%minimum nr background bags
Nbg = 10;
Nbg = 1;
% distance of concepts to origin:
D = 6;
cpos = [D D; D -D; -D -D; -D D];

x = [];
lab = [];
baglab = [];
% positive bags:
for i=1:n(1)
	% negative instances:
	nrneg = ceil(5*rand(1))+Nbg;
	x = [x; randn(nrneg,2)];
	% pos. instances:  (pfff, do it explicitly:)
	for j=1:4
		if (rand(1)>0.5) || (j==c)
			x = [x; sig*randn(1,2)+cpos(j,:)];
		else
			x = [x; randn(1,2)];
		end
	end
	% labels
	lab = [lab; ones(nrneg+4,1)];
	baglab = [baglab; repmat(i,nrneg+4,1)];
end
% negative bags:
for i=1:n(2)
	% only negative instances:
	nr = ceil(5*rand(1))+Nbg+4;
	x = [x; randn(nr,2)];
	lab = [lab; zeros(nr,1)];
	baglab = [baglab; repmat(i+n(1),nr,1)];
end

% finally:
lab = genmillabels(lab==1);
a = genmil(x,lab,baglab);
a = setname(a,'Multi-concept data');

a = setprior(a,prior);

