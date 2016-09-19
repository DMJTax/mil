%MAXDD_MIL Maximum diverse density MIL
%
%       W = MAXDD_MIL(X,FRAC,ALF,SCALES,EPOCHS,TOL)
%       W = X*MAXDD_MIL([],FRAC,ALF,SCALES,EPOCHS,TOL)
%       W = X*MAXDD_MIL(FRAC,ALF,SCALES,EPOCHS,TOL)
%       W = MAXDD_MIL(X,FRAC,SPOINTS,SCALES,EPOCHS,TOL)
%
% INPUT
%    X        MIL dataset
%    FRAC     The method of deriving bag labels from Instance labels
%    ALF      Fraction of obj. used as concept prototypes
%    SPOINTS  Initial concept prototypes
%    SCALES   Initial scales around concepts
%    EPOCHS   nr of runs
%    TOL      Likelihood change tolerances
%
% OUTPUT
%    W        Maximum diverse density
%
% DESCRIPTION
% Maximum diverse density Multi-instance learner. This implementation is
% actually completely inspired by the MIL toolbox by Min-Ling ZHANG with
% some minor changes and tweaks.
% It optimizes the diverse density using gradient descent, starting from
% initial points SPOINTS and initial scales SCALES. Then the
% optimization is run for EPOCHS epochs, and it is stopped when the
% likelihood changes less than TOL.
%
% Per default, ALF is the total number of training instances in the
% positive bags.
%
% SEE ALSO
%    log_DD, bagprob

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function out = maxDD_mil(x,frac,spoints,scales,epochs,tol)
function out = maxDD_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],1,[],[],[4 4],[1e-5 1e-5 1e-7 1e-7]);

if mapping_task(argin,'definition')
   [x,frac,spoints,scales,epochs,tol] = deal(argin{:});
   W = define_mapping(argin,'untrained','DiverseDensity (%f)',spoints);
	out = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [x,frac,spoints,scales,epochs,tol] = deal(argin{:});

	% get the bags
	[bags,baglab] = getbags(x);
	bagI = ispositive(baglab);
	pbags = bags(find(bagI));
	% get the starting positions:
	dim = size(x,2);
	if isempty(spoints) % take them all!
		spoints = cell2mat(pbags);
	else % take a subset: a fraction or a number
		if size(spoints,2)~=dim % (we are not given a small dataset)
			if size(spoints,1)>1
				error('I expect just a single value for the fraction/number of starting points.');
			end
			tmp = cell2mat(pbags);
			I = randperm(size(tmp,1));
			if spoints<1
				spoints = ceil(spoints*size(tmp,1));
			else
				if spoints>size(tmp,1)
					warning('mil:maxDD_mil',...
						'Asking for too many starting points, just use all data');
					spoints = size(tmp,1);
				end
			end
			spoints = tmp(I(1:spoints),:);
		end
	end
	% other initialization:
	if isempty(scales)
		scales = 0.1*ones(1,dim);
	else
		if length(scales)==1
			scales = repmat(scales,1,dim);
		end
	end
	epochs = epochs*dim;

	% begin diverse density maximization
	[maxConcept,concepts] = maxdd(spoints,scales,bags,bagI,epochs,tol);
	% invent a threshold...:
	n = size(bags,1);
	out = zeros(n,1);
	for i=1:n
		out(i) = bagprob(bags{i},1,maxConcept{1}(1:dim),maxConcept{1}(dim+1:end));
	end
	% WHAT TO DO NOW???
	tmp = prdataset(out,baglab,'prior',[0.5 0.5]);
%	wf = fisherc(tmp);
	wf = loglc(tmp);

	W.maxConcept = maxConcept{1};
	W.maxVal = maxConcept{2};
	W.concepts = concepts;
	W.wf = wf;
	W.frac = frac;
	out = prmapping(mfilename,'trained',W,getlabels(wf),dim,2);
	out = setbatch(out,0);  %NEVER use batches!!
	out = setname(out,'Diverse Density');

elseif mapping_task(argin,'trained execution')
   [x,frac,spoints,scales,epochs,tol] = deal(argin{:});
	x = genmil(x);
	W = getdata(frac);
	% now process all the bags:
	[bags,baglab,bagid] = getbags(x);
	dim = size(x,2);
	n = size(bags,1);
	out = zeros(n,1);
	for i=1:n
		% check if any objects fall inside the bounds
		out(i) = bagprob(bags{i},1,W.maxConcept(1:dim),W.maxConcept(dim+1:end));
	end
	out = prdataset(out,baglab)*W.wf;
	out = setident(out,bagid,'milbag');

	% ... binary things:
%	out = dataset([-out out],baglab,'featlab',getlabels(frac));
else
   error('Illegal call to maxDD_mil.');
end

return


