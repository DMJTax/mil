%TRAINDECSTUMP
%
%      [H,BESTERR] = TRAINDECSSTUMP(X,W)
%
% INPUT
%   X          Dataset
%   W          Weight per object
%
% OUTPUT
%   H          Decision stump
%   BESTERR    Lowest error
%
% DESCRIPTION
% Train a decision stump on dataset X. Each object in X is weighted by a
% weight W. Objects from the positive class have a positive weight, and
% otherwise the weights should be negative.
%
% The result is returned in vector H:
%   H(1)    the feature to threshold
%   H(2)    the threshold set on that feature
%   H(3)    the sign (+: right side is positive class, -: neg. side)
% Also the minimum error is returned in BESTERR.
%
% SEE ALSO
% milboostc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [h,besterr] = traindecsstump(x,w)

[n,dim] = size(x);

sumneg = (w<0)'*w;
sumpos = (w>0)'*w;
besterr = inf;
bestfeat = 1;
bestthr = 0;
bestsgn = 0;

for i=1:dim
   % find the best threshold for feature i
   % assume that the positive class is on the right of the decision
   % threshold:
	[sx,J] = sort(x(:,i));
	z = cumsum(w(J));

	err1 = -sumneg + z;
	[minerr,I] = min(err1);
	if (minerr<besterr)
		besterr = minerr;
		bestfeat = i;
		if (I==n)
			bestthr = sx(I)+10*eps;
		else
			bestthr = (sx(I)+sx(I+1))/2;
		end
		bestsgn = +1;
		mil_message(7,'Found better error %f for feature %d, pos. dir., thr=%f\n',...
         besterr, bestfeat,bestthr);
	end

   % Now assume that the positive class is on the left of the decision
   % threshold:
	err2 =  sumpos - z;
	[minerr,I] = min(err2);
	if (minerr<besterr)
		besterr = minerr;
		bestfeat = i;
		if (I==n)
			bestthr = sx(I)+10*eps;
		else
         bestthr = (sx(I)+sx(I+1))/2 + eps;
		end
		bestsgn = -1;
		mil_message(7,'Found better error %f for feature %d, neg. dir., thr=%f\n',...
         besterr, bestfeat,bestthr);
	end

end

h = [bestfeat bestthr bestsgn];

