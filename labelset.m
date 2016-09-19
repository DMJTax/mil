%LABELSET Derive label from set of labels
%
%    NLAB = LABELSET(NLABS,COMBRULE)
%
% INPUT
%    NLABS       Numerical instance labels
%    COMBRULE    Method to derive bag labels from instance labels
%
% OUTPUT
%    NLAB        New numeric label (for a bag)
%
% DESCRIPTION
% Derive the numberic label NLAB from a set of labels NLABS, using the
% combination method COMBRULE. Typically it is assumed that NLAB=1
% indicates the target/positive class, and NLAB=0 indicates the
% background/negative class.
% The combination method COMBRULE can be:
%   'first'      just copy the first label
%   'majority'   use the majority class
%   'presence'   label '1' when any NLABS>0 is present
%    f (double)  label '1' when more than a fraction f of the points is
%                positive
% Note that 'presence' is the same as using f=eps.
% It is assumed that NLABS is either logical or numeric.
%
% The difference with MILCOMBINE is, that here labels are combined, and
% in MILCOMBINE the classifier outputs are combined.
%
% SEE ALSO
%    MILCOMBINE, GETBAGS, SETMILINFO

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function nlab = labelset(nlabs,combrule)

% First check:
if ~isa(nlabs,'logical') & ~isa(nlabs,'double')
	error('I only deal with logical/numeric labels here.');
end

% When one object is supplied, it is simple, we just return the same
% label:
if size(nlabs,1)==1
	nlab = nlabs;
	return;
end

% The exception, when you supply a fraction/number:
if isa(combrule,'double')
	nr = combrule;
	combrule = 'fraction';
	if nr<1
		nr = ceil(nr*size(nlabs,1));
	end
end

% Invent the nlabel of a bag:
switch combrule
case 'first'
	% now: copy the label of the first element
	nlab = nlabs(1,:);
case 'majority'
	% count how many objects there are in each of the classes:
	v = size(nlabs,1);
	s = full(sparse(1:v,nlabs+1,ones(1,v)));
	s = sum(s,1);
	% take the maximum class:
	[maxnr,nlab] = max(s);
	nlab = nlab-1;
case 'fraction'
	nlab = (sum(nlabs)>=nr);
case 'presence'
	nlab = (sum(nlabs)>0);

otherwise
	error(['This combrule ',combrule,' is not defined.']);
end

return
