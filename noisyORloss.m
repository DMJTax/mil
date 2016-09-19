%NOISYORLOSS Loss for MILBoost
%
%  [LOGL,W] = NOISYORLOSS(ALPHA,PREV_OUT,THIS_OUT,BAGY,IBAG)
%
% INPUT
%   ALPHA       Weighting of the new weak classifier
%   PREV_OUT    Boosting output prev. round, H
%   THIS_OUT    Output current weak classifier h_t
%   BAGY        Bag labels
%   IBAG        Bag indices
%
% OUTPUT
%   LOGL        Log-likelihood
%   W           Weight for each bag
%
% DESCRIPTION
% Define a Noise-OR loss for the MILBoost classifier. It is used to
% compute the weights W for each of the instances, or to find the
% optimal mapping-weight LAMBDA by minimizing the (log)loss.
%
%   alpha = argmin_a Loss( H + a*h_t )
%
% where H is the output of the already trained linear combination of
% weak classifiers (PREV_OUT), and h_t is the output of the additional
% weak classifier (THIS_OUT).
%
% SEE ALSO
% milboostc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [logL,w] = noisyORloss(alpha,prev_out,this_out,bagy,Ibag)

B = length(Ibag);
N = size(prev_out,1);
% initialize all:
if isempty(alpha),
	pij = 1./(1+exp(-prev_out));
else
	pij = 1./(1+exp(-prev_out-alpha*this_out));
end
pi = zeros(B,1);
logL = 0;
if nargout>1
	w = zeros(N,1);
end
% run over the bags
for i=1:B
	pi(i) = 1 - prod(1-pij(Ibag{i}));
	if nargout==1
		if (bagy(i)==1)
			logL = logL - log(pi(i)+eps);
		else
			logL = logL - log(1-pi(i)+eps);
		end
	else 
		if (bagy(i)==1)
			w(Ibag{i}) = (1-pi(i))*pij(Ibag{i})/pi(i);
		else
			w(Ibag{i}) = -pij(Ibag{i});
		end
	end
end

if (nargout>1)
   % I run into problems when the weights are virtually zero, so avoid that
   % it really becomes too small:
   tol = 1e-10;
   I = find(abs(w)<tol);
   if ~isempty(I)
      %sgn = sign(w(I));
      sgn = (w(I)>=0)*2-1;  % fix by Marc-André Carbonneau
      w(I) = sgn.*tol;
   end
end

