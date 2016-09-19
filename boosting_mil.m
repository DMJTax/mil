%BOOSTING_MIL Boosted (logistic) MIL classifier
%
%   W = BOOSTING_MIL(X,FRAC,W_U,M)
%   W = X*BOOSTING_MIL([],FRAC,W_U,M)
%   W = X*BOOSTING_MIL(FRAC,W_U,M)
%
% INPUT
%   X       MIL dataset
%   FRAC    (not used anymore...)
%   W_U     Untrained classifier (default = loglc_weighted)
%   M       Number of boosting rounds (default = 10)
%
% OUTPUT
%   W       Boosted MIL classifier
%
% DESCRIPTION
% Boost the (untrained) mapping W_U by reweighting objects in X and
% retraining W_U M times. The mapping should be able to handle objects
% with weights (in this version it is a weighted logistic, created by
% Laurens vd Maaten).
%
% REFERENCE
% This algorithm is taken from 'Multiple Instance Boosting for Object
% Detection", P. Viola, J.C. Platt, C. Zhang, NIPS 2006, pg 1417-1426.
%
% SEE ALSO
% loglc_weighted

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = boosting_mil(a,frac,w_u,M)
function W = boosting_mil(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,loglc_weighted([],0.01),10);

if mapping_task(argin,'definition')
   [a,frac,w_u,M] = deal(argin{:});
   W = define_mapping(argin,'untrained','Boosting (M=%d)',M);
	W = setbatch(W,0);  %NEVER use batches!!

elseif mapping_task(argin,'training')
   [a,frac,w_u,M] = deal(argin{:});
	ws = scalem(a,'variance');
	a = a*ws;

	% extract all useful stuff from dataset:
	[bags,baglab,bagid,Ibag]= getbags(a);
	t = ispositive(baglab);
	B = length(bags);
	N = size(a,1);

	% setup:
	w = ones(N,1); % in the beginning all weights are 1.
	y_ij = zeros(N,1);  % storage for other params:
	p_i = zeros(B,1);
	h = zeros(N,1);

	for T=1:M

		% train the weighted logistic:
		x = setident(a,w,'weights');
		w_tr{T} = x*w_u;
		% and collect the outcomes:
		out = x*w_tr{T};
		h(:,T) = 2*double(out(:,'positive')>out(:,'negative'))-1;

		%now we have to optimize the lambda for this classifier:
		% use the Matlab optimizer for this:
		optl = fminbnd('boosting_err',-10,10,[],h(:,T),y_ij,Ibag,t);
		% (check that it went well??)
		lambda(T) = optl;

		% now we want to have new weights, for that we need:
		y_ij = y_ij + lambda(T)*h(:,T);
		p_ij = 1./(1+exp(-y_ij));
		for i=1:B
			p_i(i) = 1-prod(1-p_ij(Ibag{i}));
			if (p_i(i)==0)
				% use some Taylor expansion, only use linear term:
				p_i(i) = sum(p_ij(Ibag{i}));
			end
			if (p_i(i)==0) % it can still happen...
				w(Ibag{i}) = t(i);
			else
				w(Ibag{i}) = ((t(i)-p_i(i))/p_i(i)) * p_ij(Ibag{i});
			end
		end
	end

	W.frac = frac;
	W.ws = ws;
	W.w = w_tr;
	W.lambda = lambda;
	W = prmapping(mfilename,'trained',W,['positive'; 'negative'],size(x,2),2);
	W = setname(W,'Boosting MIL M=%d',M);
	W = setbatch(W,0);  %NEVER use batches!!

elseif mapping_task(argin,'trained execution')  % evaluation
	
   [a,frac] = deal(argin{1:2});
	W = getdata(frac);
	a = genmil(a)*W.ws;
	% extract the useful stuff:
	[bags,lab,bagid,Ibag] = getbags(a);
	B = length(bags);
	M = length(W.w);
	% initialize:
	p_i = zeros(B,1);
	y_ij = zeros(size(a,1),1);
	% output per weak classifier:
	for i=1:M
		out = a*W.w{i};
		y_ij = y_ij + ...
			W.lambda(i)*(2*double(out(:,'positive')>out(:,'negative'))-1);
	end
	p_ij = 1./(1+exp(-y_ij));
	% now the output per bag:
	for i=1:B
		p_i(i) = 1-prod(1-p_ij(Ibag{i}));
	end

	W = prdataset([p_i 1-p_i],lab,'featlab',['positive'; 'negative']);

else
   error('Illegal call to boosting_mil.');
end

return
