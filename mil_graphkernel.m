%MIL_GRAPHKERNEL miGraph kernel between bags
%
%      K = MIL_GRAPHKERNEL(BAG1,BAG2,W1,W2,GAMMA)
%
% Compute the miGraph kernel between BAG1 and BAG2, where a weighted sum
% of the RBF kernel values between all instances in BAG1 and BAG2 is
% taken. The weights per bag instance is defined by W1 and W2, the
% sigma-parameter is given by GAMMA = 1/sigma^2.
% This idea is from Zhou, Sun, Li, ICML 2009.
%
% SEE ALSO
%   INCKERNEL, MILPROXM, MIL_KERNEL
function k = mil_graphkernel(bag1,bag2,w1,w2,gamma)

Z1 = 1./sum(w1);
Z2 = 1./sum(w2);

K = exp(-gamma*sqeucldistm(bag1,bag2));

K = repmat(Z1',1,size(bag2,1)).*repmat(Z2,size(bag1,1),1).*K;

k = sum(sum(K))/sqrt(sum(Z1))/sqrt(sum(Z2));

