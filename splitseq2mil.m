%SPLITSEQ2MIL Split sequence to MIL dataset
%
%        [Y,BAGLAB] = SPLITSEQ2MIL(X,N,DELTAT)
%
% INPUT
%   X        Data matrix or dataset
%   N        Length of subsequence
%   DELTAT   Time step
%
% OUTPUT
%   Y        Data matrix with subsequences
%   BAGLAB   Label per sequence
%
% DESCRIPTION
% Consider each row in matrix X as a timeseries, and extract
% subsequences of length N from each row. When DELTAT is not given, the
% subsequences are non-overlapping, but when given, DELTAT defines the
% stride.
% When X is a labeled dataset, Y becomes a MIL dataset where bags are
% the collection of subsequences. When X is not labeled, Y is just a
% matrix with N columns, and BAGLAB contains the indices that indicate
% from which fow of X each row of Y is generated.  
%
% SEE ALSO
% mil2ocset, oc2milset

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [y,baglab] = splitseq2mil(x,N,deltaT)

if nargin<3
	deltaT = N;  % non-overlapping
end
if nargin<2
	N = 10;   % arbitrary default...
end

[n,m] = size(x);
if (m<N)
	error('Not enough samples to extract subsequences of length %d.',N);
end
if isdataset(x)
	name = getname(x);
	lab = getlab(x);
	x = +x;
else
	name = [];
	lab = [];
end
I = 1:deltaT:(m-N+1);
J = 1:N;

% storage:
y = zeros(length(I)*n,N);
% and go:
nr = 1;
for i=1:n
	for j=0:length(I)-1
		y(nr,:) = x(i, j*deltaT+J);
		nr = nr+1;
	end
end
% define the bag labels
baglab = repmat(1:n,length(I),1);
baglab = baglab(:);
% and, if requested, store it in a MIL dataset
if ~isempty(lab)
	[nlab,lablist] = renumlab(lab);
	nlab = repmat(nlab,1,length(I))';
	lab = lablist(nlab(:),:);
	y = genmil(y,lab,baglab);
	y = setname(y,name);
end

