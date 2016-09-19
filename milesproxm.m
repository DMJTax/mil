%MILESPROXM Dissimilarity representation as used in MILES
%
%     W = MILESPROXM(A,S)
%     W = MILESPROXM(A,S,SELTYPE,N)
%
% INPUT
%   A      MIL dataset
%   S      Sigma (default = 1)
%
% OUTPUT
%   W      Proximity mapping
%
% DESCRIPTION
% Compute the MILES-type dissimilarity representation for each bag in
% MIL dataset A. Each bag is represented by its similarity to all
% instances X_i in dataset A:
%
%       m_i(B) = max_j exp(-(x_j-X_i)^2/S^2 )
%
% where the x_j are instances from bag B.
%
% You can also select a subset of the instances (when data is very
% large). Define SELTYPE and N as:
%   'all'     use all instance (no selection)
%   'random'  use a random of N instances
%   'kmeans'  use N-means clustering, and use the cluster centers
%
%
% SEE ALSO
% MILPROXM

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = milesproxm(a,s)
function W = milesproxm(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],1,'all',inf);

if mapping_task(argin,'definition')
   [a,s,seltype,n] = deal(argin{:});
   W = define_mapping(argin,'untrained','MILESproxm');
   W = setbatch(W,0);

elseif mapping_task(argin,'training')
   [a,s,seltype,n] = deal(argin{:});

   % potentially train/ select instances:
   switch seltype
   case 'all'
      x = +a;
      tname = '';
   case 'random'
      I = randperm(size(a,1));
      x = +a(I(1:n),:);
      tname = sprintf(' %d random',n);
   case 'kmeans'
      [lab,b] = prkmeans(a,n);
      x = +meancov(b);
      tname = sprintf(' %d-means',n);
   end

   % ...
   dim = size(x,1);
   W.x = x;
   W.s = s;
   W = prmapping(mfilename,'trained',W,[],size(x,2),dim);
   W = setname(W,['MILESproxm' tname]);
   W = setbatch(W,0);

elseif mapping_task(argin,'trained execution')  % evaluate

   [a,s] = deal(argin{1:2});
   a = genmil(a);
   W = getdata(s);
   N = size(W.x,1);
   [bags,labs,bagid] = getbags(a);
   B = length(bags);
   x = zeros(B,N);
   for i=1:B
      for j=1:N
         d = sqeucldistm(bags{i},W.x(j,:));
         x(i,j) = exp(-min(d)/(W.s*W.s));
      end
   end
   W = prdataset(x,labs);
   W = setident(W,bagid);
   W = setname(W,getname(a));
   W = setprior(W,getprior(a,0));
else
   error('Illegal call to MILESproxm');

end

