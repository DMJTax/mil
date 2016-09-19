%MILBOOST Boosted MIL classifier
%
%   W = MILBOOSTC(A,FRAC,T)
%
% INPUT
%   A       MIL dataset
%   FRAC    Fraction of informative instances (default = 'presence')
%   T       Nr of boosting rounds (default = 100)
%   LOSS    Loss function (default = @noisyORloss)
%
% OUTPUT
%   W       Milboost classifier
%
% DESCRIPTION
% Train a MILBoost classifier on MIL dataset A. The weak classifiers are
% decision stumps, and in total T decision stumps are trained.
%
% REFERENCE
% Babenko, B., Dolla ́r, P., Tu, Z., Belongie, S.: Simultaneous learning and alignment:
% Multi-instance and multi-pose boosting. Technical Report CS2008, UCSD (2008)
%
% SEE ALSO
%   NOISYORLOSS, TRAINDECSTUMP

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function w = milboostc(a,frac,T,milloss)
function w = milboostc(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],'presence',100,@noisyORloss);

if mapping_task(argin,'definition')
   [a,frac,T,milloss] = deal(argin{:});
   W = define_mapping(argin,'untrained','MILBoost (%d rounds)',T);
	w = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,T,milloss] = deal(argin{:});
	errtol = 1e-15;

	x = +a;
	t = ispositive(a);
	y = 2*t-1;
	[bags,baglab,bagid,Ibag] = getbags(a);
	B = length(bags);
	bagy = ispositive(baglab);
	[N,dim] = size(a);

	% init
	h = zeros(T,3);
	alpha = zeros(T,1);
	pij = zeros(N,1);
	pi = zeros(B,1);
	prev_out = zeros(N,1);
	opts = optimset('fminunc');
	opts = optimset(opts,'Display','off','LargeScale','off');

	for t=1:T
		mil_message(6,'Run %d\n',t);
		% train weights
		[tmp,w] = milloss([],prev_out,[],bagy,Ibag);
		% find the best weak classifier:
		[h(t,:),besterr] = traindecstump(x,w);
		% this classifier gives output:
		this_out = h(t,3)*sign(x(:,h(t,1))-h(t,2));
		% find the best alpha:
		alpha(t) = fminunc(@(alpha) milloss(alpha,prev_out,this_out,bagy,Ibag),1,opts);
		% update output full classifier:
		prev_out = prev_out + alpha(t)*this_out;
		% extra check:
		if (besterr<=errtol), break; end
	end
	if (t<T)
		T=t;
		h=h(1:T,:);
		alpha=alpha(1:T,:);
	end
	W.T = T;
	W.h = h;
	W.alpha = alpha;

	ll = ['positive';'negative'];
	w = prmapping(mfilename,'trained',W,ll,dim,2);
	w = setname(w,'MILBoost (%d rounds)',T);

elseif mapping_task(argin,'trained execution')
   [a,frac] = deal(argin{1:2});

	a = genmil(a);
	W = getdata(frac);
	n = size(a,1);
	z = +a;
	out = zeros(n,1);
	for i=1:W.T
		out = out + W.alpha(i)*W.h(i,3)*sign(z(:,W.h(i,1))-W.h(i,2));
	end
	pij = 1./(1+exp(-out));
	[bags,baglab,bagid,Ibag] = getbags(a);
	B = length(bags);
	out = zeros(B,1);
	for i=1:B
		out(i) = 1-prod(1-pij(Ibag{i}));
	end
	w = prdataset([out 1-out],baglab,'featlab',getlabels(frac));
	w = setident(w,bagid,'milbag');

else
   error('Illegal call to milboostc.');
end


