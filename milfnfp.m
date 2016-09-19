%MILFNFP Compute the false negative, false positive fraction
%
%     ERR = MILFNFP(Z,W)
%
% INPUT
%     Z    MIL dataset
%     W    MIL mapping
%
% OUTPUT
%     ERR  vector containing the FN and FP rate
%
% DESCRIPTION
% Compute the false negative and false positive rate for MIL dataset Z
% after it is mapped by W.
%
% SEE ALSO
% MILMAP, MILROC

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = fnfp(z,w)

d = z*w;
truelab = getlab(d);
outlab = z*w*labeld;

truelab = ispositive(truelab);
outlab = ispositive(outlab);

out = repmat(NaN,size(d,1),2);
It = find(truelab);
out(It,1) = ~outlab(It);
Io = find(~truelab);
out(Io,2) = outlab(Io);

return
