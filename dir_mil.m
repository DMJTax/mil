%DIR_MIL Direction MIL
%
%    W = DIR_MIL(A,FRAC,K,EVALFUNC)
%
% INPUT
%    A         MIL-dataset or MIL-datafile
%    FRAC      Quantile fraction (default = 1)
%    K         Number of directions (default = 5)
%    EVALFUNC  Cluster evaluation function (default = 'auc')
%
% OUTPUT
%    W         MIL-classifier using projection on direction
%
% DESCRIPTION
% Direction MIL that uses the difference vector from the mean of the
% data to the center of a cluster as a projection direction. K clusters
% are tried, and the best one is used. The closest fraction FRAC of each
% of the bags is not used in this selection procedure (to avoid too much
% overtraining). The selection is based on the evaluation criterion
% EVALFUNC. This can be an untrained mapping, or EVALFUNC = 'auc'.
% In the evaluation the FRAC-quantile object is used to classify a bag.
%
% SEE ALSO
%   CLUST_MIL

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = dir_mil(a,frac,k,evalfunc)
function W = dir_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],1,5,'auc');

if mapping_task(argin,'definition')
   [a,frac,k,evalfunc] = deal(argin{:});
   W = define_mapping(argin,'untrained','Direction MIL (k=%d)',k);
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,k,evalfunc] = deal(argin{:});

	if ~ismilset(a)
		error('I need a MIL dataset.');
	end
	[m,dim,c]=getsize(a);

	% do clustering on a subset of all data:
	M = 1000;
	tmpa = +gendat(a,M);
	D = +distm(tmpa);
	[lab,J] = kcentres(D,k,25); %(repeat 25 times)
	k = length(J);  %GRRR sometimes I don't get enough clusters back!!
	dirs = tmpa(J,:) - repmat(mean(+a),k,1); %clear tmpa;
	% now see how each bag is represented by the direction to the clusters:
	[bags,baglab] = getbags(a);
	nrbags = size(baglab,1);
	d = []; labd = [];
	for i=1:nrbags
		if frac<1
			f_obj = ceil(frac*size(bags{i},1));
		else
			f_obj = frac;
		end
		D = bags{i}*dirs';
		% is this the correct distance definition??
		sD = sort(D,1,'descend'); % take the highest pick
		% use the closest fraction of the data only, for training (the
		% rest of the data is just removed)
		newd = sD(f_obj,:);
		d = [d; newd];
		labd = [labd; repmat(baglab(i,:),size(newd,1),1)];
	end
	% which cluster is the best?
	% this depends on the evaluation criterion:
	pr = repmat(1/c,1,c); % GRRRRR!
	if ismapping(evalfunc)
		beste = inf;
		for i=1:k
			x = prdataset(d(:,i),labd,'prior',pr);
			w = fisherc(x);
			newe = x*w*testc;
			if newe<beste
				beste = newe; bestw = w; bestc = i;
			end
		end
		outlab = getlabels(w);
	elseif strcmp(evalfunc,'auc')
		Ilab = ispositive(labd);
		beste = 0;
		for i=1:k
			newauc = dd_auc(simpleroc(+d(:,i),Ilab));
			%if (newauc<0.5), newauc = 1- newauc; end
			if newauc>beste
				beste = newauc; bestc = i;
			end
		end
		% hmmm, a hack:
		x = prdataset(d(:,bestc),labd,'prior',pr);
		bestw = loglc(x);
	else
		error('The evaluation function %s is unknown.',evalfunction);
	end

	%and save all useful data in a structure:
	W.dir = dirs(bestc,:)';
	W.w = bestw;
	W.beste = beste;
	W.frac = frac;  % a threshold should *always* be defined
	W = prmapping(mfilename,'trained',W,getlabels(bestw),dim,c);
	W = setbatch(W,0);  %NEVER use batches!!
	W = setname(W,sprintf('Clustering MIL using %d clusters',k));

elseif mapping_task(argin,'trained execution')
   [a,frac,k,evalfunc] = deal(argin{:});

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
		d = (+bags{i})*W.dir;
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
else
   error('Illegal call to dir_mil.');
end

return

