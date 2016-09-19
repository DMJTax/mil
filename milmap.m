%MILMAP Map multi-instance dataset
%
%      OUT = MILMAP(Z,W,MISSINGVALUES)
%
% INPUT
%    Z              MIL-dataset or MIL-datafile
%    W              MIL-classifier
%    MISSINGVALUES  Setting to deal with missing values
%
% OUTPUT
%    OUT            Classifier output for data Z
%
% DESCRIPTION
% The official function to map a Multi-Instance dataset Z by
% Multi-instance classifier W. When Z is a standard dataset, this is
% identical to OUT=Z*W. But when Z is a datafile, Z will be mapped
% bag-by-bag (i.e. file-by-file), and not item-by-item (which is kind of
% essential for MIL).  For MIL, each bag only generates a single output,
% defined by W.
%
% If needed, you can supply an additional MISSINGVALUES, to deal with
% missing values in the data (see MILMISSINGVALUES.M for options).
%
% SEE ALSO
%  GENMIL, GETBAGS, MILCOMBINE, MILMISSINGVALUES

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = milmap(z,w,missingvalues)
if nargin<3
	missingvalues = '';
end

if isdataset(z)
% for datasets it is simple
%out = genmil(z)*w;
%out = setprior(out,getprior(z,0));
    % It is actually not simple, because map.m wants to break up the
    % dataset in smaller batches. Because it can skrew up the bags, we
    % should avoid that:
    if isuntrained(w)
        %train:
        pars = getdata(w);
        out = feval(getmapping_file(w),genmil(z),pars{:});
    else
        %evaluate
        out = feval(getmapping_file(w),genmil(z),w);
    end
elseif isdatafile(z)
%for datafiles we run over the individual bags:
	bags = getbags(z);
	n = length(bags);
	% which version is better? This one:
	pr = getprior(z,0);
	out = zeros(n,size(w,2)); lab = [];
	for i=1:n
		tmp = milfile2set(bags{i},missingvalues)*w;
		bagid(i,:) = getident(tmp(1,:),'milbag');
		out(i,:) = +tmp;
		lab = [lab;getlabels(tmp)];
	end
	%out = prdataset(out,lab,'featlab',getlabels(w),'prior',pr);
	out = prdataset(out,lab,'featlab',getlabels(w));
	out = setident(out,bagid,'milbag');
	% or this one:
%	out = milfile2set(bags{1})*w;
%	for i=2:n
%		out = [out; milfile2set(bags{i})*w];
%	end

else
	error('Mileval requires a dataset or datafile.');
end

