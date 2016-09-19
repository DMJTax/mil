%MILESPROXM MILES inspired vector representation of a bag
%
%      W = MILESPROXM(X,RTYPE,PAR,PROTOSEL)
%
% INPUT
%     X           MIL dataset
%     RTYPE       Method for obtaining a vector from a bag
%                 (default = 'rbf')
%     PAR         Parameter of the method (default = [])
%     PROTOSEL    Reduce the nr of instances (default.type = 'all',
%                 default.N = [])
%
% OUTPUT
%     W           MIL Proximity mapping
%
% DESCRIPTION
% Compute a single feature vector from each bag of instances in X.
% It defines a (dis)similarity between all bags, and all (or a subset
% of) instances in X.
% The following measures are defined between bags {x_i} and instance z:
%   RTYPE:             DOES:       
%    'rbf'        max_i  exp(-(x_i-z)^2/par^2 )
%    'mindist'    min_i  (x_i-z)^2
%
% For very large datasets X the number of (dis)similarities can become
% very large, and therefore some prototype selection may be useful. For
% this, define a structure PROTOSEL with two fields, 'type' and 'N':
%   PROTOSEL.type
%      'all'          use all instances
%      'random'       select randomly PROTOSEL.N instances
%
% SEE ALSO
%    MILCOMBINE, LABELSET

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function y = milproxm(x,rtype,par,protosel)
function y = milproxm(varargin)

argin= shiftargin(varargin,'char');
argin = setdefaults(argin,[],'rbf',10,'all');

if mapping_task(argin,'definition')
   [x,rtype,par,protosel] = deal(argin{:});
   W = define_mapping(argin,'untrained','MilesVector');
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [x,rtype,par,protosel] = deal(argin{:});
   [n,p] = size(x);
   switch protosel.type
   case 'all'
      I = 1:n;
   case 'random'
      I = randperm(n);
      I = I(1:protosel.N);
   case 'kmeans'
      [labs,means] = mykmeans(+x,protosel.N);
      D = sqeucldistm(+x,means);
      [~,I] = min(D);
   otherwise
      error('I do not know this prototype selection method');
   end
   W.X = +x(I,:);
   W.type = rtype;
   W.par = par;
	y = prmapping(mfilename,'trained',W,[],p,length(I));
	y = setbatch(y,0); % NEVER do batches!
elseif mapping_task(argin,'trained execution')
   [x,rtype] = deal(argin{1:2});

	x = genmil(x); % I need a MIL dataset to derive the bag labels
	% now we have data, and we *apply* the mapping:
   W = getdata(rtype);

	% now we only have one feature type to take care of:
	[bags,lab,bagid] = getbags(x);
	[m,p] = size(x);
	n = length(bags);
   out = zeros(n,size(W.X,1));
	switch W.type
	case {'r','rbf'}
      for i=1:n
         mind = min(sqeucldistm(bags{i},W.X),[],1);
         out(i,:) = exp(-mind/(W.par*W.par));
      end
	case 'mindist'
      for i=1:n
         out(i,:) = min(sqeucldistm(bags{i},W.X),[],1);
      end
	otherwise
		error('Type %s is not defined.',W.type);
	end
	% we have the new features, and the feature labels, so go:
	y = prdataset(out,lab,'prior',0);
   [nlab,ll] = renumlab(lab,getlablist(x));
   y = setlablist(y,getlablist(x));
   y = setnlab(y,nlab);
	y = setident(y,(1:n)','milbag');
	y = setname(y,getname(x));
	y = setprior(y,getprior(x,0)); %DXD well, is this a good idea? What
	                               % alternative do we have?
else
   error('Illegal call to milesvector.');
end

