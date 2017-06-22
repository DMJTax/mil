%SUBSAMPLE_BAGS
%
%    B = SUBSAMPLE_BAGS(A,FRAC)
%
% Randomly subsample a fraction FRAC of the instances from bags in A,
% and store it in B. The number of bags should not change.

function b = subsample_bags(a,frac,seed)
if nargin<3
   seed = [];
end
if nargin<2
   frac = 0.5;
end

% check
if (frac<=0) || (frac>1)
   error('Fraction should be between 0 and 1.');
end
% unpack
[bag, baglab, bagid] = getbags(a);
N = length(bag);
% subsample:
for i=1:N
   n = size(bag{i},1);
   if ~isempty(seed)
      rng(seed);
   end
   I = randperm(n);
   f = ceil(frac*n);
   bag{i} = bag{i}(I(1:f),:);
end
% pack again:
b = genmil(bag,baglab,bagid);
aname = getname(a);
if isempty(aname)
   b = setname(b,'Subsampled %4.2f',frac);
else
   b = setname(b,sprintf('%s, subsampled %4.2f',getname(a),frac));
end
