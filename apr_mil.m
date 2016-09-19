% Iterative discrim APR MIL
%
%    OUT = APR_MIL(X,FRAC,THRES,TAU,EPSILON,STEP)
%
% INPUT
%    X       MIL dataset
%    FRAC    Quantile fraction (default = eps)
%    THRES   Threshold (default = 0.01)
%    TAU     Tau param. in expansion of rectangle (default = 0.995)
%    EPSILON epsilon? (default = 0.02)
%    STEP    step? (default = 0.1)
%
% OUTPUT
%    W       Axis parallel rectangle description
%
% DESCRIPTION
% The classic Iterated discriminative Axis Parallel Rectangle of
% Dietterich.
% FRAC should indicate what fraction (or number of instances) in a bag
% should be positive in order to call a bag positive.
% To be really honest, I never get this to work. There are too many
% parameters for which it is hard to set correctly. The default
% parameters are set so that it appears to work on the Musk1.
%
% REFERENCE
%@article{DieLatLaz1997,
%    author = {Dietterich, T.G. and Lathrop, R.H. and Lozano-Perez, T.},
%    title = {Solving the Multiple Instance Problem with Axis-Parallel
%		 Rectangles},
%    journal = {Artificial Intelligence},
%    volume = {89},
%    number = {1-2},
%    pages = {31-71},
%    year = {1997}}
%
% SEE ALSO
% apr_grow, apr_discrim, apr_expand

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

%function out = apr_mil(x,frac,thres,tau,epsilon,step)
function out = apr_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],eps,0.01,0.995,0.02,0.1);

if mapping_task(argin,'definition')
   out = define_mapping(argin,'untrained','APR');
   
elseif mapping_task(argin,'training')
   [x,frac,thres,tau,epsilon,step] = deal(argin{:});
	if ~ismilset(x)
		error('I am expecting a MIL dataset.');
	end
	[xp,xn] = getpositivebags(x);
	p = size(x,2);
	rel = ones(1,p);

	converged = 0;
	while ~converged
		[mn,mx] = apr_grow(xp,rel);

		[rel,converged] = apr_discrim(xn,mn,mx,rel,thres);
	end

	[mn,mx] = apr_expand(xp,mn,mx,rel,tau,epsilon,step);
	W.mn = mn;
	W.mx = mx;
	W.rel = find(rel);
	W.frac = frac;
	out = prmapping(mfilename,'trained',W,getlablist(x),p,2);
	out = setbatch(out,0);  %NEVER use batches!!
	%out = setname(out,'APR fr=%1.3f, thr=%1.3f, tau=%1.3f, eps=%1.3f, step=%1.3f',frac,thres,tau,epsilon,step);
	out = setname(out,'APR tau=%1.3f',tau);
elseif mapping_task(argin,'trained execution')

   [x,frac] = deal(argin{1:2});
	% don't get confused when no bags are defined:
	x = genmil(x);
	% preprocess the data (feature selection)
	W = getdata(frac);
	x = x(:,W.rel);
	[m,p] = size(x);
	if (p~=size(W.mn,2))
		error('Feature sizes do not match.');
	end
	% now process all the bags:
	[bags,baglab,bagid] = getbags(x);
	n = size(bags,1);
	out = zeros(n,1);
	for i=1:n
		% check if any objects fall inside the bounds
		m = size(bags{i},1);
		I1 = (bags{i} >= repmat(W.mn,m,1));
		I2 = (bags{i} <= repmat(W.mx,m,1));
		I = (I1 & I2);

		% now invent what to return:
		% output a 1 if it is inside, otherwise 0:
		out(i) = any(all(I,2));
	end

	% ... and return the new dataset
	% (AYY, we have to copy the 'true' labels by hand in the dataset,
	% danger danger danger)
	out = prdataset([1-out out],baglab,'featlab',getlabels(frac));
	out = setident(out,bagid,'milbag');
	%out = setprior(out,getprior(x));
else
   error('Illegal call to apr_mil.');

end

return


