%CITATION_MIL kNN-MIL using Haussdorf distance
%
%   W = CITATION_MIL(A,FRAC,K)
%   W = CITATION_MIL(A,FRAC,K,CITERANK)
%
% INPUT
%   A           MIL dataset
%   FRAC        Combining fraction to get bag label from inst. label
%   K           Number of neighbors (default = 1)
%   CITERANK    Number of citers (default = 3)
%   KTYPE       Bag distance (default = 'h')
%   KPAR        Parameter for bag distance (default = [])
%
% OUTPUT
%   W           Citation kNN classifier
%
% DESCRIPTION
% Train a Citation K-nearest neighbors on dataset A. The classifier uses
% the (maximum) Haussdorff distance between the bags of instances.
% Majority voting is used to obtain a final label given the labels of
% the K nearest bags.
%
% When CITERANK>0 is defined, not only the K nearest bags to the test
% bag is considered, but also the closeness of the test object to all
% the training objects is taken into account. When the test bag is
% closer than the CITERANK-nearest neighbors to a certain training bag,
% the label of this training bag is also taken into account. This label
% is appended to the labels of the K nearest bags of the test bag.
%
% SEE ALSO
% milcombine, milkernel

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = citation_mil(a,frac,num_ref,rank_citer,ktype,kpar)
function W = citation_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],'presence',1,3,'h',{});

if mapping_task(argin,'definition')
   [a,frac,num_ref,rank_citer,ktype,kpar] = deal(argin{:});
   W = define_mapping(argin,'untrained','Citation %dNN, c=%d',num_ref,rank_citer);
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,num_ref,rank_citer,ktype,kpar] = deal(argin{:});
	if ~ismilset(a)
		error('I need a MIL dataset.');
	end

	% Get the bags:
	[bags,baglab] = getbags(a);
	n = length(bags);
	if (num_ref>n)||(rank_citer>n)
		error('num_ref or rank_citer are too large.');
	end

	% compute all distances between the training bags:
	D = milkernel(a,[],ktype,kpar);
	% find the 'critical' distance for each bag, that is, the distance to
	% it's rank_citer-neighbor bag:
	[Ds,I] = sort(D,1);
	D = Ds(rank_citer+1,:);

	%and save all useful data in a structure:
	%W.bags = bags;
	W.ktype = ktype;
	W.kpar = kpar;
	W.x = a;
	W.lab = ispositive(baglab);
	W.num_ref = num_ref;
	W.D = D;
	W.frac = frac;  % a threshold should *always* be defined
	W = prmapping(mfilename,'trained',W,['positive';'negative'],size(a,2),2);
	W = setname(W,'Citation %dNN, c=%d (%s)',...
	   num_ref,rank_citer,getname(milproxm(ktype)));
	W = setbatch(W,0);  %NEVER use batches!!

elseif mapping_task(argin,'trained execution')  %testing
   [a,frac,num_ref,rank_citer,ktype,kpar] = deal(argin{:});

	% Unpack the mapping and dataset:
	a = genmil(a);
	W = getdata(frac);
	n = size(W.lab,1);

	% run over the bags:
	[bags,baglab,bagid] = getbags(a);
	out = zeros(length(bags),1);
	% compute distances to training bags:
	dz = milkernel(a,W.x,W.ktype,W.kpar);
	for i=1:length(bags)
		% find the num_ref closest training bags:
		[mind,I1] = sort(dz(i,:));
		% furthermore, find which bags has the test bag inside its
		% rank_citer-neighbors:
		I2 = find(dz(i,:)<W.D);
		lab = W.lab([I1(1:W.num_ref) I2],:);

		out(i) = mean(lab);
	end
	out = [out 1-out];

	%W = prdataset(out,baglab,... %'prior',getprior(a,0), ...
	W = prdataset(out,baglab,'prior',getprior(a,0), ...
		'featlab',getlabels(frac),'featsize',getsize_out(frac));
	W = setident(W,bagid,'milbag');
else
   error('Illegal call to citation_mil.');
end

return

