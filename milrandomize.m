%MILRANDOMIZE
%
%     A = MILRANDOMIZE(A,SEED)
%
% INPUT
%   A      MIL dataset
%   SEED   Seed for random number generator
%
% OUTPUT
%   A      MIL dataset
%
% DESCRIPTION
% Randomize the bags in MIL dataset A. When no SEED is given, the
% computer clock is used as seed.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [a,I] = milrandomize(a,seed)
if nargin<2
	seed = sum(100*clock);
end

rand('state',seed);
[baglab tmp Ibag] = getbaglabs(a); %VC: We don't need the actual bags, this is faster/less memory

% randomize the order of the elements of a
n = size(Ibag,1);
I = randperm(n);
J = cell2mat(Ibag(I));
a = a(J,:);

return
