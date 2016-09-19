%SV_MIL Support Vector using a bag kernel
% 
% 	W = SV_MIL(A,C,KERNELMAP)
%
% INPUT
%   A	          Dataset
%   C           Regularization parameter (default = 1)
%   KERNELMAP   Kernel between bags (default = milproxm([],'h'))
%
% OUTPUT
%   W           Bag Support Vector Classifier
%
% DESCRIPTION
% Optimizes a support vector classifier on MIL dataset A. It is assumed
% that the KERNELMAP, defined in function milproxm transforms the MIL
% dataset into a BxB kernel matrix (where B=number of training bags), so
% that we have a kernel between BAGS, instead of between instances.
%
% An example can be:
% >> a = gendatmilg;
% >> w = sv_mil(a,10,milproxm([],'h'));
% >> w = sv_mil(a,10,milproxm([],'g',[1,5])) % or something else...
%
% SEE ALSO
%  milkernel, milproxm

% Copyright: D.M.J. Tax
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
  
%function [W,J] = sv_mil(a,C,kernelmap)
function [W,J] = sv_mil(varargin)
	
argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],1,milproxm([],'h'));

if mapping_task(argin,'definition')
   [a,C,kernelmap] = deal(argin{:});
   if isa(kernelmap,'char')
      kernelmap = milproxm(kernelmap);
   end
   kname = getname(kernelmap);
   W = define_mapping(argin,'untrained','SVmil %s',kname);
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,C,kernelmap] = deal(argin{:});

   if isa(kernelmap,'char')
      kernelmap = milproxm(kernelmap);
   end
	[bags,nlab,bagid,Ibag] = getbags(a);
	k = size(a,2);
	nlab = ispositive(nlab)+1;
	if ~istrained(kernelmap)
		trkernelmap = a*kernelmap;
	else
		trkernelmap = kernelmap;
	end
	n = size(bagid,1);
	% compute bag kernel:
	K = +(a*trkernelmap);
	%K = max(K,K'); % make sure kernel is symmetric (DXD: is this the way??)
	%K = (K+K')/2; % make sure kernel is symmetric (DXD: is this the way??)
i = -30;
while (pd_check(K + (10.0^i)*eye(n)) == 0)
	i = i + 1;
end
if (i > -30),
	prwarning(2,'K is not positive definite. The kernel is regularized by adding 10.0^(%d)*I',i);
end
K = K + (10.0^(i+2))*eye(n);
	
	% Compute the parameters for the optimization:
	y = 3 - 2*nlab;
	% Perform the optimization:
	if ~isempty(which('svmpredict'))
		% Use 'svmpredict' instead of svmtrain, because svmtrain is also
		% defined in the Bioinformatics toolbox in matlab (sigh!)
		% we use libsvm with precomputed kernel
		opt = ['-c ' num2str(C) ' -t 4 -s 0 -q'];
		model = svmtrain(y,[(1:size(K,1))' K], opt);
		J = full(model.SVs);
		v = [-model.sv_coef; model.rho];
	else
		% we use the old and trusted qld:
		[v,J] = svo(K,y,C);
		% or use the dd_tools version, incsvc? No, because there we cannot
		% easily just supply the kernel matrix...
	end
	% note that we get back the indices of the bags: we should store
	% all instances of these bags:
	I = cell2mat(Ibag(J));
	% if the kernelmap was untrained, we can actually retrain it using
	% only the support vectors:
	if istrained(kernelmap)
		% fill in zeros in the right places:
		newv = zeros(size(kernelmap,2),1);
		newv(J) = v(1:end-1);
		newv = [newv;v(end)];
		v = newv;
	else
		% retrain the kernel map:
		trkernelmap = a(I,:)*kernelmap;
	end
	% Store the results:
	W.alpha = v;
	W.kmap = trkernelmap;
	W = prmapping(mfilename,'trained',W,getlablist(a),k,2);
	W = setbatch(W,0);  %NEVER use batches!!
	W = setname(W,'SVmil %s',getname(kernelmap));
	W = setcost(W,a);
		
elseif mapping_task(argin,'trained execution')
   [a,C,kernelmap] = deal(argin{:});
	
	a = genmil(a);
	W = getdata(C);
	m = size(a,1);
	% also the number of bags:
	[bags,baglab,bagid] = getbags(a);
	n = size(bags,1);
	
	% compute kernel:
	d = a*W.kmap;
    % and the classifier outcome per bag:
	d = [d ones(n,1)] * W.alpha;
	d = sigm([d -d]);
	W = prdataset(d,baglab,'featlab',getlabels(C));
	W = setident(W,bagid,'milbag');
	W = setname(W,getname(a));
	
end
	
return

