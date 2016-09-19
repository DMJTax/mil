%LOGLC_WEIGHTED Weighted Logistic Linear Classifier
% 
%   W = LOGLC_WEIGHTED(A, W, L)
% 
% INPUT
%   A   Dataset
%   W   Weight per instance 
%   L   Regularization parameter (L2, default = 0)
%
% OUTPUT
%   W   Logistic linear classifier 
%
% DESCRIPTION  
% Computation of the linear classifier for the dataset A by maximizing the
% L2-regularized likelihood criterion using the logistic (sigmoid) function.
% The default value for L is 0.
%
% SEE ALSO 
%  mappings, datasets, ldc, fisherc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function [B, ll] = loglc_weighted(A, L)
function [B, ll] = loglc_weighted(varargin)

name = 'Logistic regressor (implementation 2)';
warning off MATLAB:dispatcher:pathWarning
addpath(genpath('~/matlab/extern/minFunc'));
warning on MATLAB:dispatcher:pathWarning

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0);

if mapping_task(argin,'definition')
   [A,L] = deal(argin{:});
   W = define_mapping(argin,'untrained',name);
	B = setbatch(W,0);  %NEVER use batches!!

elseif mapping_task(argin,'training')
   [A,L] = deal(argin{:});
	W = getident(A,'weights');
	if isempty(W)
		W = ones(size(A, 1));
	end
	islabtype(A, 'crisp');
	isvaldfile(A, 1, 2);
	A = testdatasize(A, 'features');
	A = setprior(A, getprior(A)); 
	[m, k, c] = getsize(A);

	% Train the logistic regressor
	[data.E, data.E_bias] = train_logreg(+A', getnlab(A)', W, L);
	B = prmapping(mfilename, 'trained', data, getlablist(A), k, c);
	B = setname(B, name);

elseif mapping_task(argin,'trained execution')  % evaluation
	
   [A,L] = deal(argin{1:2});


	% Evaluate logistic regressor
	[test_labels, test_post] = eval_logreg(+A', L.data.E, L.data.E_bias);
	A = prdataset(A); 
	B = setdata(A, test_post', getlabels(L));
	ll = [];

else
   error('Illegal call to loglc_weighted.');
end

end

function [E, E_bias] = train_logreg(train_X, train_labels, weights, lambda, E_init, E_bias_init)

    % Uses fancy optimizer
    addpath(genpath('minFunc'));

    % Initialize solution
    D = size(train_X, 1);
    [lablist, foo, train_labels] = unique(train_labels);
    K = length(lablist);
    if ~exist('E_init', 'var') || isempty(E_init)
        E = randn(D, K) * .0001;
    else
        E = E_init; clear E_init
    end
    if ~exist('E_bias_init', 'var') || isempty(E_bias_init)
        E_bias = zeros(1, K);
    else
        E_bias = E_bias_init; clear E_bias_init;
    end
    
    % Compute weighted data set
    if size(weights, 2) == 1
        weights = weights';
    end
    weighted_train_X = bsxfun(@times, weights, train_X);
    
    % Compute positive part of gradient
    pos_E = zeros(D, K);
    pos_E_bias = zeros(1, K);
    for k=1:K
        pos_E(:,k) = sum(weighted_train_X(:,train_labels == k), 2);            
    end
    for k=1:K
        pos_E_bias(k) = sum(weights(train_labels == k));
    end
    
    % Perform learning using L-BFGS
    x = [E(:); E_bias(:)];
    options.Method = 'lbfgs';
    options.Display = 'on';
    options.TolFun = 1e-7;
    options.TolX = 1e-7;
    options.MaxIter = 2500;   
    options.Display = 'OFF';
%     checkgrad('logreg_grad', x, 1e-7, train_X, train_labels, weighted_train_X, weights, lambda, pos_E, pos_E_bias)
    x = minFunc(@logreg_grad, x, options, train_X, train_labels, weighted_train_X, weights, lambda, pos_E, pos_E_bias);
    
    % Decode solution
    E = reshape(x(1:D * K), [D K]);
    E_bias = reshape(x(D * K + 1:end), [1 K]);
end


function [est_labels, posterior] = eval_logreg(test_X, E, E_bias)

    % Perform labeling
    if ~iscell(test_X)
        log_Pyx = bsxfun(@plus, E' * test_X, E_bias');
    else
        log_Pyx = zeros(length(E_bias), length(test_X));
        for i=1:length(test_X)
            for j=1:length(test_X{i})
                log_Pyx(:,i) = log_Pyx(:,i) + sum(E(test_X{i}{j},:), 1)';
            end
        end
        log_Pyx = bsxfun(@plus, log_Pyx, E_bias');
    end
    [foo, est_labels] = max(log_Pyx, [], 1);
    
    % Compute posterior
    if nargout > 1
        posterior = exp(bsxfun(@minus, log_Pyx, max(log_Pyx, [], 1)));
        posterior = bsxfun(@rdivide, posterior, sum(posterior, 1));
    end
end


function [C, dC] = logreg_grad(x, train_X, train_labels, weighted_train_X, weights, lambda, pos_E, pos_E_bias)
%LOGREG_GRAD Gradient of L2-regularized logistic regressor
%
%   [C, dC] = logreg_grad(x, train_X, train_labels, weighted_train_X, weights, lambda, pos_E, pos_E_bias)
%
% Gradient of L2-regularized logistic regressor.


    % Decode solution
    [D, N] = size(train_X);
    K = numel(x) / (D + 1);
    E = reshape(x(1:D * K), [D K]);
    E_bias = reshape(x(D * K + 1:end), [1 K]);

    % Compute p(y|x)
    gamma = bsxfun(@plus, E' * train_X, E_bias');
    gamma = exp(bsxfun(@minus, gamma, max(gamma, [], 1)));
    gamma = bsxfun(@rdivide, gamma, max(sum(gamma, 1), realmin));
    
    % Compute conditional log-likelihood
    C = 0;
    for n=1:N
        C = C - weights(n) .* log(max(gamma(train_labels(n), n), realmin));
    end
    C = C + lambda .* sum(x .^ 2);
    
    % Only compute gradient when required
    if nargout > 1
    
        % Compute positive part of gradient
        if ~exist('pos_E', 'var') || isempty(pos_E)
            pos_E = zeros(D, K);
            for k=1:K
                pos_E(:,k) = sum(weighted_train_X(:,train_labels == k), 2);
            end
        end
        if ~exist('pos_E_bias', 'var') || isempty(pos_E_bias)
            pos_E_bias = zeros(1, K);
            for k=1:K        
                pos_E_bias(k) = sum(weights(train_labels == k));
            end
        end

        % Compute negative part of gradient    
        neg_E = weighted_train_X * gamma';
        neg_E_bias = sum(bsxfun(@times, gamma, weights), 2)';
        
        % Compute gradient
        dC = -[pos_E(:) - neg_E(:); pos_E_bias(:) - neg_E_bias(:)] + 2 .* lambda .* x;
    end    
end
