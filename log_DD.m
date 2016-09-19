%LOG_DD Log diverse density, and derivative
%
%     [P,DER] = LOG_DD(PARS,BAGS,BAGLABS)
%
% INPUT
%   PARS       Params encoding location and scale
%   BAGS       Cell array of bags
%   BAGLABS    Bag labels
%
% OUTPUT
%   P          (log)probability per bag
%   DER        Derivative w.r.t. PARS
%
% DESCRIPTION
% Support function for the Maximum Diverse Density algorithm.
% See maxDD_mil.m
function [p,der] = log_DD(pars,bags,baglabs)

dim = size(pars,2);
n = size(baglabs,1);
d2 = size(bags{1},2);
concept = pars(1:d2);
s = pars((d2+1):end);

prob = zeros(n,1);
der = zeros(n,dim);
for i=1:n
	[prob(i), der(i,:)] = bagprob(bags{i},baglabs(i),concept,s);
end
prob = max(prob,1e-12);
der = -(1./prob)'*der;
p = -sum(log(prob));

return


