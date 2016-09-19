%CLUST_MIL Clustering MIL
%
%    W = CLUST_MIL(A,FRAC,K,EVALFUNC,FLIPSIGN,NRTRIES)
%    W = A*CLUST_MIL([],FRAC,K,EVALFUNC,FLIPSIGN,NRTRIES)
%    W = A*CLUST_MIL(FRAC,K,EVALFUNC,FLIPSIGN,NRTRIES)
%
% INPUT
%    A         MIL-dataset
%    FRAC      Quantile fraction (default = eps)
%    K         Number of clusters (default = 5)
%    EVALFUNC  Cluster evaluation function (default = 'auc')
%    FLIPSIGN  Use inverted distance when AUC<0.5 (default = 0)
%    NRTRIES   Nr. of retries in kcenters (default = 25)
%
% OUTPUT
%    W         MIL-classifier using distance to a prototype
%
% DESCRIPTION
% Clustering MIL that uses the distance to the center of a cluster as a
% classification measure. K clusters are tried, and the best one is
% used. The closest fraction FRAC of each of the bags is considered in
% this selection procedure and all the other data is discarded. The
% selection of the cluster is based on the evaluation criterion
% EVALFUNC. This can be an untrained mapping, EVALFUNC = 'auc' or
% EVALFUNC='meanprec'.  In the evaluation the FRAC-quantile object is
% used to classify a bag.
%
% SEE ALSO
% DIR_MIL

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = clust_mil(a,frac,k,evalfunc,flipsign,nrretries)
function W = clust_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],eps,5,'auc',0,25);

if mapping_task(argin,'definition')
   [a,frac,k,evalfunc,flipsign,nrretries] = deal(argin{:});
   W = define_mapping(argin,'untrained','ClustMIL (k=%d)',k);
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')

   [a,frac,k,evalfunc,flipsign,nrretries] = deal(argin{:});
	if ~ismilset(a)
		error('I need a MIL dataset.');
	end
	% first check if FRAC is sensible
	if strcmp(frac,'presence')
		frac = 1;
	end
	if ~isa(frac,'double')
		frac
		error('FRAC should be a fraction or number.');
	end
	[m,dim,c]=getsize(a);

	% do clustering on a subset of the positive data:
	M = 5000;
	tmpa = double(gendat(a(find_positive(a),:),M));
	k = min(k,size(tmpa,1));
	D = +distm(tmpa);
	[lab,J] = kcentres(D,k,nrretries);
	k = length(J); %GRRR in some rare occasions, not enough clusters are returned
	centers = tmpa(J,:); clear tmpa;
	% now see how each bag is represented by the clusters:
	[bags,baglab] = getbags(a);
	nrbags = size(baglab,1);
	d = []; labd = [];
	for i=1:nrbags
		if frac<1
			f_obj = ceil(frac*size(bags{i},1));
		else
			f_obj = frac;
		end
		% is this the correct distance definition??
		D = +distm(double(bags{i}),centers);
		sD = sort(D,1);
		% use the closest fraction of the data only, for training (the
		% rest of the data is just removed)
		d = [d; sD(1:f_obj,:)];
		labd = [labd; repmat(baglab(i,:),f_obj,1)];
	end
	% which cluster is the best?
	% this depends on the evaluation criterion:
	pr = repmat(1/c,1,c); % GRRRRR!
	if ismapping(evalfunc)  % the user supplied an evaluation func
		beste = inf;
		for i=1:k
			x = prdataset(d(:,i),labd,'prior',pr);
			w = x*evalfunc;
			newe = x*w*testc;
			if newe<beste
				beste = newe; bestw = w; bestc = i;
			end
		end
		outlab = getlabels(w);
	elseif strcmp(evalfunc,'auc')  % the pre-defined AUC is used.
		Ilab = 1-ispositive(labd);
		beste = 0;
		for i=1:k
			% positive objects have small distance, so invert the +1-0
			% identifiers:
			newauc = dd_auc(simpleroc(+d(:,i),Ilab));
			% be resistant again flipping of the sign?
			if flipsign
				if newauc<0.5, newauc = 1-newauc; end
			end
			% include the margin when the data is separable (AUC=1)
			% (how often does that happen in a 'real' dataset?)
			if newauc==1
				margin = min(d(Ilab==1,i)) - max(d(Ilab==0,i));
				newauc = newauc + margin;
			end
			% now find out if it is better than we already had:
			if newauc>beste
				beste = newauc; bestc = i;
			end
		end
		% hmmm, the final classifier is a logistic classifier:
		x = prdataset(d(:,bestc),labd,'prior',pr);
		bestw = loglc(x);
	elseif strcmp(evalfunc,'meanprec')
		truelab = 1-ispositive(labd);
		beste = 0;
		bestc = 0;
		for i=1:k
			e = dd_meanprec(simpleprc(+d(:,i),truelab));
			if (e>beste)
				beste = e;
				bestc = i;
			end
		end
		% hmmm, the final classifier is a logistic classifier:
		x = prdataset(d(:,bestc),labd,'prior',pr);
		bestw = loglc(x);
	else
		error('The evaluation function %s is unknown.',evalfunc);
	end

	%and save all useful data in a structure:
	W.center = centers(bestc,:);
W.all = centers;
	W.w = bestw;
	W.beste = beste;
	W.frac = frac;  % a threshold should *always* be defined
	W = prmapping(mfilename,'trained',W,getlabels(bestw),dim,c);
	W = setbatch(W,0);  %NEVER use batches!!
	W = setname(W,sprintf('Clust-MIL with %d cl. q=%4.2f',k,frac));

elseif mapping_task(argin,'trained execution')  %testing

   [a,frac,k,evalfunc,flipsign,nrretries] = deal(argin{:});

	% Unpack the mapping and dataset:
	W = getdata(frac);
	a = genmil(a);
	[m,k] = size(a); 

	% run over the bags:
	[bags,baglab,bagid] = getbags(a);
	n = size(bags,1);
	in = zeros(n,1);
	for i=1:n
		% is this the correct distance definition??
		d = +distm(double(bags{i}),W.center);
		d = sort(d);
		if W.frac<1
			f_obj = ceil(W.frac*size(bags{i},1));
		else
			f_obj = min(W.frac,size(bags{i},1));
		end
		in(i) = d(f_obj,:);
	end
	% make the output
	if isempty(baglab)
		W = prdataset(in)*W.w;
	else
		W = prdataset(in,baglab,'prior',0)*W.w;
	end
	W = setident(W,bagid,'milbag');
end

return

