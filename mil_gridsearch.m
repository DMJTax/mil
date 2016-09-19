%MIL_GRIDSEARCH Parameter optimization of MILs
%
%     [W,BESTARG] = MIL_GRIDSEARCH(A,CLNAME,NRFOLDS,ARGVAL1,ARGVAL2,...)
%     [W,BESTARG] = A*MIL_GRIDSEARCH([],CLNAME,NRFOLDS,ARGVAL1,ARGVAL2,...)
%     [W,BESTARG] = A*MIL_GRIDSEARCH(CLNAME,NRFOLDS,ARGVAL1,ARGVAL2,...)
%
% INPUT
%   A             MIL dataset
%   CLNAME        Classifier name (string) (default = 'simple_mil')
%   NRFOLDS       Nr folds in crossvalidation (default = 10)
%   ARGVAL1,...   Range of values of input arguments
%                 (default = {0.1 0.2 0.3}, {ldc qdc})
%
% OUTPUT
%   W             Optimized classifier
%   BESTSRG       Optimized input arguments 
%
% DESCRIPTION
% Optimize classifier with the name CLNAME on dataset A, by varying all
% input arguments of the classifier. The best parameter settings BESTARG
% are estimated using NRFOLDS-cross validation on dataset A, using the
% Area under the ROC curve performance measure (dd_auc). The classifier
% is trained using the optimized BESTARG on all training data A.
% An example would be:
% >> w = mil_gridsearch(a,'simple_mil',10,{0.1 0.2 0.3},{ldc qdc})
%
% Note, the best performance is found by using 'max'. When more than one
% combination of parameter values obtain the best performance, the first
% combination is taken!
%
% SEE ALSO
% milcrossval, dd_auc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function [w,bestarg,perf] = mil_gridsearch(a,clname,nrfolds,varargin)
function [w,bestarg,perf] = mil_gridsearch(varargin)

argin = shiftargin(varargin,'char');
argin = setdefaults(argin,[],'simple_mil',10,{0.1 0.2 0.3},{ldc qdc});

if mapping_task(argin,'definition')
   [a,clname,nrfolds] = deal(argin{1:3});
   w = define_mapping(argin,'untrained','Opt.%s',clname);
   w = setbatch(w,0);

elseif mapping_task(argin,'training')
   [a,clname,nrfolds] = deal(argin{1:3});
   pars = argin(4:end);

   % do some checking:
   if ~isa(clname,'char')
      error('The classifier name should be a string.');
   end
   if ~isa(nrfolds,'double')
      error('Please don''t forget to define the NRFOLDS first.');
   end

   % find first all combinations of parameters:
   nrpars = length(pars);
   arg = pars{1};
   arg = arg(:); % make sure it is a column vector
   for i=2:nrpars
      newarg = pars{i};
      newarg = newarg(:)'; % make sure it is a row vector
      n = length(newarg);
      m = size(arg,1);
      newarg = repmat(newarg,m,1);
      arg = [repmat(arg,n,1) newarg(:)];
   end

   % now run over all combinations (ooph)
   nrcomb = size(arg,1);
   perf = zeros(nrcomb,nrfolds);
   for i = 1:nrcomb
      mil_message(6,'(%d/%d)',i,nrcomb);
      thisarg = arg(i,:);
      I = nrfolds;
      for j=1:nrfolds
         [x,z,I] = milcrossval(a,I);
         w = feval(clname,x,thisarg{:});
         r = milroc(z,w);
         perf(i,j) = dd_auc(r);
      end
   end
   % average over the runs:
   perf = mean(perf,2);

   % and who is the winner?
   [mx,I] = max(perf);
   % retrain this on all data:
   bestarg = arg(I,:);
   w = feval(clname,x,bestarg{:});
else
   error('Illegal call to mil_gridsearch');
end

