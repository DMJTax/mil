%SPARSELOGLC Sparse logistic classifier
%
%   W = SPARSELOGLC(A,LAMBDA,POSW,SCALEL)
%
% INPUT
%   A        Dataset
%   LAMBDA   Regularization parameter (default = 0.1)
%   POSW     Only use positive weights (default = 0)
%   SCALEL   Scale regularization parameter (default = 0)
%
% OUTPUT
%   W        Logistic classifier
%
% DESCRIPTION
% Sparse logistic classifier as implemented by the SLEP package.
% Train the classifier on dataset A (only two-class for now), using
% regularization parameter RHO.
% A sparse logistic classifier optimizes the logistic loss on the
% trainingset, regularized by the L_1 norm of the weigths:
%
%   min  sum_i log(1+exp(-y_i (w^T x_i + w_0))) + LAMBDA |w|_1
%    w
% When you only want to get solutions with positive weights, use POSW=1.
% It is also possible to use a rescaled version of LAMBDA, between 0 and
% 1. Set SCALEL=1 if you want to use that.
%
% REFERENCE
%      Jun Liu, Jianhui Chen, and Jieping Ye, 
%      Large-Scale Sparse Logistic Regression, KDD, 2009.
% The toolbox can be downloaded from:
%    http://www.public.asu.edu/~jye02/Software/SLEP/
% SEE ALSO
% loglc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function w = sparseloglc(a,lambda,useposweights,scalelambda)
function w = sparseloglc(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,0,0);

if mapping_task(argin,'definition')
   [a,lambda,useposweights,scalelambda] = deal(argin{:});
   W = define_mapping(argin,'untrained','SparseLogLc');
	w = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,lambda,useposweights,scalelambda] = deal(argin{:});

	if ~exist('LogisticR')
		addpath(genpath('~/matlab/extern/SLEP_package_4.1/'));
		if ~exist('LogisticR')
			error('The SLEP package is not in your path!');
		end
	end
   [n,k,c] = getsize(a);
   if c>2
      error('I only implemented this for two-class problems.');
   end
   x = +a;
   y = 2*(getnlab(a)==1)-1;  %+1/-1 labels; first class is +1

   opts = [];
   opts.init = 2; % starting from a zero point
   opts.tFlag = 5; %run .maxIter iterations
   opts.maxIter = 100;

   opts.rsL2 = 0;  % no rho.
   opts.nFlag = 0; % no normalization of data
   opts.rFlag = scalelambda; % use the given lambda
   % weight for positive and negative examples
   sz = classsizes(a);
   opts.Weight = [1/sz(1) 1/sz(2)];

   opts.mFlag = 0; % treating it as a compositive function (DXD???)
   opts.lFlag = 0; % Nemirovski's line search

   if useposweights
      [w1,w0,funVal1] = nnLogisticR(x,y,lambda,opts);
   else
      [w1,w0,funVal1,ValueL1] = LogisticR(x,y,lambda,opts);
   end

   W.w1 = w1;
   W.w0 = w0;

   w = prmapping(mfilename,'trained',W,getlablist(a),k,2);
   w = setname(w,'Sparse Logistic');

elseif mapping_task(argin,'trained execution')  %testing
   [a,lambda] = deal(argin{1:2});

   % get data
   W = getdata(lambda);
   out = (+a)*W.w1+W.w0;

   w = setdat(a,[out -out],lambda);
   w = w*sigm;

end


