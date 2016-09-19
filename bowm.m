%BOWM Bag Of Words representation
%
%         W = BOWM(X,K)
%         W = BOWM(X,K,'soft')
%         W = BOWM(X,K,'soft',CTYPE)
%
% INPUT
%   X      MIL dataset
%   K      Number of 'words' (default = 10)
%   CTYPE  Type of covariance matrix (default = 'diag')
%
% OUTPUT
%   W      Bag of Words mapping
%
% DESCRIPTION
% Fit on MIL dataset X a Bag of Words representation, using a Mixture of
% Gaussian model with K Gaussians with diagonal covariance matrices.
% In the standard version we only estimate the frequency how often a
% certain cluster is chosen to represent an instance. When the third
% input parameter indicates 'soft', we use the (normalized) cluster
% probability to represent each instance.
%
% When CTYPE is given, another shape of the covariance matrix can be set
% (see mog_init for more details).
%
% SEE ALSO
% mog_init, mog_P

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = bowm(x,k,bowtype,ctype)
function W = bowm(varargin)

argin = shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],10,'','diag');

if mapping_task(argin,'definition')
   [x,k,bowtype,ctype] = deal(argin{:});
   W = define_mapping(argin,'untrained','Bag of Words (k=%d)',k);
	B = setbatch(W,0);  %NEVER use batches!!

elseif mapping_task(argin,'training')
   [x,k,bowtype,ctype] = deal(argin{:});
	[W.m, W.ic, W.p] = mog_init(x,k,ctype);
	W.k = k;
	W.ctype = ctype;
	W.bowtype = bowtype;
	W = prmapping(mfilename,'trained',W,[],size(x,2),k);
	W = setbatch(W,0);  %NEVER use batches!!
elseif mapping_task(argin,'trained execution')  % evaluation: estimate MoG probabilities
   [x,k] = deal(argin{1:2});
	w = getdata(k);
	[bags,baglab,bagid] = getbags(x);
	n = size(bags,1);
	out = zeros(n,w.k);
	for i=1:n % evaluate each bag:
		P = mog_P(bags{i},w.ctype,w.m,w.ic,w.p);
		switch w.bowtype
		case 'soft'
			out(i,:) = mean(P,1);
		otherwise
			% find the best match:
			[mx,I] = max(P,[],2);
			J = 1:size(P,1);
			h = zeros(size(P));
			h(J'+(I-1)*size(P,1))=1;
			out(i,:) = mean(h);
		end
	end
	W = prdataset(out,baglab);
	W = setprior(W, getprior(x,0));
	W = setident(W,bagid,'milbag');
	W = setname(W,getname(x));
else
   error('Illegal call to bowm.');
end
