%EMDD_MIL Expectation Maximization Maximum Diverse Density
%
%        W = EMDD_MIL(X,FRAC,K,EPOCHS,TOL)
%        W = X*EMDD_MIL([],FRAC,K,EPOCHS,TOL)
%        W = X*EMDD_MIL(FRAC,K,EPOCHS,TOL)
% 
% INTPUT
%     X      MIL dataset
%     FRAC   Fraction/number of instances taken into account in
%            evaluation (frac = 1)
%     K      Number of objects (or fraction of objects when K<1) used as
%            random initialisation (default = 10)
%     EPOCHS Number of runs in the maxDD (default = [4 4])
%     TOL    Tolerances (default = [1e-5 1e-5 1e-7 1e-7])
%
% OUTPUT
%     W      Trained EMDD mapping
%
% Use the Expectation Maximization version of the Maximum Diverse
% Density. It is an iterative EM algorithm, requiring a sensible
% initialisation. By giving ALF or K, you can specify how many times you
% would like to run the algorithm. From the K tries the best one (on the
% training set) is returned.
%
% SEE ALSO
% maxDD_mil

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = emdd_mil(x,frac,alf,epochs,tol)
function W = emdd_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],eps,10,[4 4],[1e-5 1e-5 1e-7 1e-7]);

if mapping_task(argin,'definition')
   [x,frac,alf,epochs,tol] = deal(argin{:});
   W = define_mapping(argin,'untrained','EMDD (%f)',alf);
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')

   [x,frac,alf,epochs,tol] = deal(argin{:});
	% initialize, find the bags
	[bags,baglab,bagid,Ibag] = getbags(x);
	nrbags = length(bags);
	bagI = ispositive(baglab);
	dim = size(x,2);
	epochs = epochs*dim;

	% define how many (and which) points are used for initialization
	startpoint = bags(find(bagI));
	startpoint = cell2mat(startpoint);
	I = randperm(size(startpoint,1));
	if (alf<1) % fraction
		k = max(round(alf*length(I)),1);
	else
		k = alf;
	end
	if k>size(startpoint,1)
		warning('mil:emdd_mil',...
			'Asking for too many starting points, just use all data');
		k = size(startpoint,1);
	else
		startpoint = startpoint(I(1:k),:);
	end
	%NOTE: magic number here: normalize data to unit variance before!
	scales = repmat(0.1,k,dim);
	pointlogp = repmat(inf,k,1);
	% start the optimization k times:
	for i=1:k
		bestinst = cell(nrbags,1);
		logp1 = log_DD([startpoint(i,:),scales(i,:)],bags,bagI);
		% do a few runs to optimize the concept and scales in an EM
		% fashion:
		for r=1:10
			mil_message(5,'*');
			% find the best fitting instance per bag
			for j=1:nrbags
				dff = bags{j}-repmat(startpoint(i,:),size(bags{j},1),1);
				dff = (dff.^2)*(scales(i,:)').^2;
				[mn,J] = min(dff);
				bestinst{j} = bags{j}(J,:);
			end
			% run the maxDD on only the best instances
			maxConcept = maxdd(startpoint(i,:),scales(i,:),...
				bestinst,bagI,epochs,tol);
			startpoint(i,:) = maxConcept{1,1}(1:dim);
			scales(i,:) = maxConcept{1,1}(dim+1:end);
			% do we improve?
			logp0 = logp1;
			logp1 = log_DD(maxConcept{1,1},bags,bagI);
			if abs(exp(-logp1)-exp(-logp0))<0.01*exp(-logp0)
				break;
			end
		end
		mil_message(5,'.');
		pointlogp(i) = logp1;
	end
	% now we did it k times, what is the best one?
	[mn,J] = min(pointlogp);
	maxConcept = [startpoint(J,:), scales(J,:)];
	% invent a threshold...:
	out = zeros(nrbags,1);
	for i=1:nrbags
		out(i) = log_DD(maxConcept,bags(i),1);
	end
	% WHAT TO DO NOW???
	tmp = prdataset(out,baglab,'prior',[0.5 0.5]);
%	wf = fisherc(tmp);
	wf = loglc(tmp);

	W.frac = frac;
	W.maxConcept = maxConcept;
	W.wf = wf;

	W = prmapping(mfilename,'trained',W,getlablist(x),size(x,2),2);
	W = setbatch(W,0);  %NEVER use batches!!
	W = setname(W,'EM-DD (%f)',alf);

elseif mapping_task(argin,'trained execution')
   [x,frac,alf,epochs,tol] = deal(argin{:});
	x = genmil(x);
	W = getdata(frac);
	[m,p] = size(x);
	% process all the bags:
	[bags,baglab,bagid] = getbags(x);
	n = size(bags,1);
	out = zeros(n,1);
	for i=1:n
		out(i) = log_DD(W.maxConcept,bags(i),1);
	end
	out = prdataset(out,baglab)*W.wf;
	W = setident(out,bagid,'milbag');

end

return;

