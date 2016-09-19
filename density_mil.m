%DENSITY_MIL Density MIL
%
%    W = DENSITY_MIL(A,W)
%
% INPUT
%    A         MIL-dataset
%    W         Untrained density mapping (default= parzenm)
%
% OUTPUT
%    W         MIL-classifier using densities.
%
% DESCRIPTION
% Estimate the densities of the instances that come from both the
% positive bags and the negative bags. This is done using the untrained
% mapping W. A new bag is classified by multiplying all class
% conditional probabilities of all instances. The prior is not taken
% into account yet.
%
% SEE ALSO
%    MAXDD_MIL, PARZENM

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = parzen_mil(a,w_u)
function W = parzen_mil(varargin)

argin= shiftargin(varargin,'prmapping');
argin = setdefaults(argin,[],parzenm);

if mapping_task(argin,'definition')
   [a,w_u] = deal(argin{:});
   W = define_mapping(argin,'untrained','DensityMIL');
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,w_u] = deal(argin{:});
	if ~ismilset(a)
		error('I need a MIL dataset.');
	end
	if length(w_u)>1
		error('Frac can only be a fraction or number');
	end
	[m,dim,c]=getsize(a);

	% do the two densities:
	I = ispositive(a);
	wp = +a(find(I),:)*w_u;
	wn = +a(find(I==0),:)*w_u;

	%and save all useful data in a structure:
	W.wp = wp;
	W.wn = wn;
	W.frac = 0.1;  % a threshold should *always* be defined
	W = prmapping(mfilename,'trained',W,{'positive' 'negative'},dim,c);
	W = setbatch(W,0);  %NEVER use batches!!
	W = setname(W,'DensityMIL');

elseif mapping_task(argin,'trained execution')
   [a,w_u] = deal(argin{:});

	% Unpack the mapping and dataset:
	W = getdata(w_u);
	a = genmil(a);
	[m,k] = size(a); 

	% run over the bags:
	[bags,baglab,bagid] = getbags(a);
	n = size(bags,1);
	out = zeros(n,2);
	for i=1:n
		% estimate the densities:
		p = [+(bags{i}*W.wp) +(bags{i}*W.wn)];
		% check if we don't have nans:
		%sump = sum(p,2); p = p(isfinite(sump),:);
		%forget further normalization
		%px = sum(prod(p));
		%finally:
		out(i,1) = sum(log(p(:,1)));
		out(i,2) = sum(log(p(:,2)));
	end
	% make the output
	W = prdataset(exp(out),baglab,'prior',0);
	W = setfeatlab(W,{'positive' 'negative'});
	W = setident(W,bagid,'milbag');
end

return

