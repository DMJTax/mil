%MILVECTOR Vector representation of a bag
%
%      W = MILVECTOR(X,RTYPE)
%
% INPUT
%     X           MIL dataset
%     RTYPE       Method for obtaining a vector from a bag
%                 (default = 'm')
%
% OUTPUT
%     W           Standard Prtools mapping
%
% DESCRIPTION
% Extract a single feature vector from each bag of instances in X and
% store it in Y. The following features are defined:
%   RTYPE:             DOES:       
%    'm'        mean per bag  (default)
%    'e'        extreme (min and max) values per feature per bag
%    'c'        covariance matrix elements
%    'n'        number of instances per bag
%
% The parameter COPYMETHOD determines what label each feature vector
% obtains, given the labels of the instances in the bag.
%
% Note that this is a *trained* mapping, so this:
% >> y=milvector(x,'m')  will result in y being a mapping. To get a
% dataset, you have to do:
% >> y=x*milvector(x,'m')
%
% SEE ALSO
%    MILCOMBINE, LABELSET

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function y = milvector(x,rtype)
function y = milvector(varargin)

argin= shiftargin(varargin,'char');
argin = setdefaults(argin,[],'m');

if mapping_task(argin,'definition')
   [x,rtype] = deal(argin{:});
   W = define_mapping(argin,'untrained',milvectorname(rtype));
	y = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [x,rtype] = deal(argin{:});
	if	size(rtype,1)==1 && size(rtype,2)>1
		warning('Please make RTYPE a column matrix.');
		rtype = rtype';
	end
	if isa(rtype,'cell')
		rtype = cell2mat(rtype);
	end
% 'train' the mapping:
% (training is bullshit here, but we have to make sure that the input
% and output dimensionalities are correct...)
	if	size(rtype,1)==1 && size(rtype,2)>1
		warning('Please make RTYPE a column matrix.');
		rtype = rtype';
	end
	if isa(rtype,'cell')
		rtype = cell2mat(rtype);
	end
	if size(rtype,1)>1
		p = size(x,2);
		pnew = 0;
		for i=1:length(rtype)
			pnew = pnew + size(milvector(x,rtype(i,:)),2);
      end
	else
		% define here the output dimensionality for each of the feature
		% definitions:
		[m,p] = size(x);
		switch rtype
		case 'm'
			pnew = p;
		case 'e'
			pnew = 2*p;
		case 'u'
			pnew = 2*p;
		case 'c'
			pnew = p*(p+1)/2;
		case 'n'
			pnew = 1;
		end
	end
	y = prmapping(mfilename,'trained',{rtype},[],p,pnew);
	y = setname(y,milvectorname(rtype));
	y = setbatch(y,0); % NEVER do batches!

elseif mapping_task(argin,'trained execution')  %testing
   [x,rtype] = deal(argin{:});

	%x = genmil(x); % I need a MIL dataset to derive the bag labels
	% now we have data, and we *apply* the mapping:
	if ismapping(rtype)
		W = getdata(rtype);
		rtype = W{1};
	end
	% if we give it a cell array full of options, we do each in turn:
	if size(rtype,1)>1
		y = x*milvector(x,rtype(1,:));
		for i=2:length(rtype)
			y = [y x*milvector(x,rtype(i,:))];
		end
		return
	end
	% now we only have one feature type to take care of:
	[bags,lab,bagid] = getbags(x);
	[m,p] = size(x);
	n = length(bags);
	switch rtype
	case 'm'   % only the mean vector of a bag
		y = zeros(n,p);
		for i=1:n
			y(i,:) = mean(bags{i},1);
		end
		oldfl = getfeatlab(x);
		if ~isempty(oldfl)
			fl = [repmat('mean ',p,1) num2str(oldfl)];
		else
			fl = cellprintf('mean %d',1:p);
		end
	case 'e'  % the min and max values of a bag
		y = zeros(n,2*p);
		for i=1:n
			y(i,:) = [min(bags{i},[],1) max(bags{i},[],1)];
		end
		oldfl = getfeatlab(x);
		if ~isempty(oldfl)
			fl = num2str(oldfl);
		else
			fl = num2str((1:p)');
		end
		fl = [ [repmat('min ',p,1) fl]; [repmat('max ',p,1) fl]];
	case 'u'  % the min and max values of a bag, but differently
		y = zeros(n,2*p);
		for i=1:n
			x1 = min(bags{i},[],1);
			x2 = max(bags{i},[],1);
			y(i,:) = [(x1+x2)/2  x2-x1];
		end
		oldfl = getfeatlab(x);
		if ~isempty(oldfl)
			fl = num2str(oldfl);
		else
			fl = num2str((1:p)');
		end
		fl = [ [repmat('centr ',p,1) fl]; [repmat('width ',p,1) fl]];
	case 'c'  % the elements in the cov. matrix
		% first define the indices
		D = p*(p+1)/2; % total nr of unique elements
		I = [];
		for i=1:p
			I = [I (i-1)*p+(i:p)];
		end
		y = zeros(n,D);
		for i=1:n
			if size(bags{i},1)==1 % sigh, when we have one instance...
				c = zeros(size(bags{i},2));
			else
				c = cov(bags{i});
			end
			y(i,:) = c(I);
		end
		fl = cellprintf('cov %d',I);
	case 'n'
		for i=1:n
			y(i,1) = size(bags{i},1);
		end
		fl = 'nr.inst';
	otherwise
		error('Type %s is not defined.',rtype);
	end
	% we have the new features, and the feature labels, so go:
	y = prdataset(y,lab,'prior',0,'featlab',fl);
   [nlab,ll] = renumlab(lab,getlablist(x));
   y = setlablist(y,getlablist(x));
   y = setnlab(y,nlab);
	y = setident(y,(1:n)','milbag');
	y = setname(y,getname(x));
	y = setprior(y,getprior(x,0)); %DXD well, is this a good idea? What
	                               % alternative do we have?
end

function name = milvectorname(rtype)

if size(rtype,1)>1
	name = 'milvector';
else
	switch rtype
	case 'm'
		name = 'mean-inst';
	case 'e'
		name = 'extremes';
	case 'u'
		name = 'extremes2';
	case 'c'
		name = 'cov-coef';
	case 'n'
		name = 'nr.inst';
	otherwise
		error('rtype is not recognized');
	end
end


