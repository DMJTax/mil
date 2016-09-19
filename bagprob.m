%BAGPROB Probability (and derivat.) per bag
%
%   [BAGP,DERP] = BAGPROB(BAG,LAB,CONCEPT,S)
%
% INPUT
%   BAG       Data matrix of one bag
%   LAB       Bag label
%   CONCEPT   Feature vector
%   S         Scale per feature
%
% OUTPUT
%   BAGP      Probability per bag
%   DERP      Derivative
%
% Auxiliary function for log_DD.
%
function [bagp,derp] = bagprob(bag,lab,concept,s)

nrpar = 2*size(concept,2);
m = size(bag,1);
dff = bag - repmat(concept,m,1);
dff2 = dff.^2;
s2 = s.^2;
% first the probability:
p = exp( -dff2*s2' );
p1minp = prod(1-p); %DXD: here at least 1 high detection will give 0
% then the derivative:
der = 2*repmat(p,1,nrpar).*[dff.*repmat(s2,m,1) -dff2.*repmat(s,m,1)];
%der = (1./(1-p))'*der;
der = sum(der./repmat(max(1-p,1e-12),1,nrpar),1);

if lab>0
	% here is the OR function:
	bagp = 1-p1minp;
	derp = p1minp*der;
else
	bagp = p1minp;
	derp = -p1minp*der;
end

return
