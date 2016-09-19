%PPOSTERIOR_MIL
%
%     W = PPOSTERIOR_MIL(A,FRAC,N,NRP)
%
% INPUT
%   A     MIL dataset
%   FRAC  Fraction of positive instances (default = 'presence')
%   N     Number of words (default = 30)
%   NRP   Number of degrees to try (default = 10)
%
% OUTPUT
%   W     Pposterior MIL classifier
%  
% DESCRIPTION
% Train a p-posterior mixture model on dataset A. This is basically a
% SVM trained on a Bag-of-Words representation. The only extra thing is
% that the degree of the polynomial kernel is optimized using kernel
% alignment. The degree is between 0 and 3, and in NRP steps different
% classifiers are trained.
% N indicates the number of words (or clusters) used in the Bag of Words
% representation. 
%
% REFERENCE
%@inproceedings{WanYanZha2008,
%	author = {Wang, H.-Y. and Yang, Q. and Zha, H.},
%	title = {Adaptive p-posterior mixture-model kernels for multiple
%		instance learning},
%	booktitle = {Proc. 25th Int'l Conf. Machine learning},
%	pages = {1136-1143},
%	year = {2008}}
%
% SEE ALSO
% bowm, milvector, milproxm, svm, misvm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = pposterior_mil(a,frac,N,nrp)
function W = pposterior_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],'presence',30,10);

if mapping_task(argin,'definition')
   [a,frac,N,nrp] = deal(argin{:});
   W = define_mapping(argin,'untrained','PposteriorMIL');
	w = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,N,nrp] = deal(argin{:});

	if ~ismilset(a)
		error('I need a MIL dataset.');
	end
	% first train a Bag of Words:
	v = bowm(a,N,'soft');
	b = a*v;
	y = 2*ispositive(b)-1;
	% then try several values for 'p' in the kernel:
	p = linspace(0,3,nrp+1); p(1)=[];
	alig = zeros(nrp,1);
	gt = y*y'; gtnorm = sum(sum(gt.*gt));
	for i=1:nrp
		bb = double(b).^p(i);
		Kp = bb*bb';
      alig(i) = sum(sum(Kp.*gt))/sqrt(sum(sum(Kp.*Kp))*gtnorm);
	end
	[amin,I] = max(alig);
	p = p(I);
	% make the classifier:
	w = svc(b.^p,'h',1,1);
	% in total:
   W.v = v;
	W.p = p;
   W.w = w*sigm;

	%and save all useful data in a structure:
	W.frac = frac;  % a fraction should *always* be defined
	W = prmapping(mfilename,'trained',W,getlabels(W.w),size(a,2),2);
	W = setbatch(W,0);  %NEVER use batches!!
	W = setname(W,'Pposterior MIL with N=%d',N);

elseif mapping_task(argin,'trained execution')  %testing
   [a,frac,N,nrp] = deal(argin{:});

	% Unpack the mapping and dataset:
	W = getdata(frac);
   b = a*W.v;
   bb = b.^W.p;
	W = bb*W.w;
end

return

