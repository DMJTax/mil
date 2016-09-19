%MILROC Receiver Operating Characteristic curve 
%
%     [E, THR] = MILROC(A,W)
%
% INPUT
%    A    MIL-set
%    W    MIL-classifier
%
% OUTPUT
%    E    Structure containing the ROC curve
%    THR  Vector containing the threshold values
%
% DESCRIPTION
% Computation of the ROC curve over the output of MIL-dataset A after
% mapping through W. Each bag in A will give a single output. Next to
% the structure E that contains the false positive and false negative
% fractions for each threshold, also the vector of thresholds THR is
% returned.
%
% SEE ALSO
%   DD_ROC, MILMAP

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [e, thr] = milroc(a,w)
% Use the same setup as testc

% When no input arguments are given, return an empty mapping
if nargin==0
	
	e = prmapping(mfilename,'fixed');
	e = setbatch(e,0);  %NEVER use batches!!

elseif nargin == 1

	% Now we should have a mapped dataset, so the real work is done!

	% for evaluation, we need both target and outlier objects:
	I = ispositive(a);
	It = find(I); Io = find(~I);
	if isempty(It)
		error('Dataset A does not contain positive objects');
	end
	if isempty(Io)
		error('Dataset A does not contain negative objects');
	end

	% get the labels of A:
	truelab = zeros(size(a,1),1);
	truelab(It) = 1;

	% check if we have sane results:
	if ~all(isfinite(+a))
		% only keep the outputs which have finite values:
		I = all(isfinite(+a),2);
		a = a(I,:);
		if isempty(a)
			warning('mil:milroc:AllNonfiniteOutputs',...
				'ALL classifier outputs are non-finite!');
			%a = prdataset([1 1;1 1]); truelab = [0;1];   %VC: This gives errors because there are no MIL labels... 
			            
            b = prdataset([1 1;1 1]); truelab = [0;1]; baglab=[0;1];
            a = genmil(b, truelab, baglab, 'presence');
			a = setfeatlab(a,{'positive' 'negative'});
		else
			warning('mil:milroc:NonfiniteOutputs',...
				'Some strange (non-finite) classifier outputs: can you check your classifier?');
		end
	end
	% store the operating point for later:
	% First check if we are dealing with a mapping, or a classifier:
	fl = getfeatlab(a);
	if size(fl,1)<2 % it is a mapping, so no OP available
		e.op = [];
	else % it is a classifier, we can just apply dd_error
		e.op = mil2ocset(a)*dd_error;
	end

	% first find out where the output for the target objects are stored:
	if ~isempty(fl)
		tcolumn = strmatch('positive',fl);
		if isempty(tcolumn)
			tcolumn = strmatch('negative',fl);
			if isempty(tcolumn)
				warning('mil:milroc:noPositiveFeature',...
				'I cannot find the target feature, using feature 1.');
				a = +a(:,1);
			else
				a = -double(a(:,tcolumn));
			end
		else
	% and now extract the required column 'resemblance to target set':
			a = double(a(:,tcolumn));
		end
	else  % there are no feature labels defined... suspicious...
		a = +a(:,1);
		warning('mil:milroc:noFeatureLab',...
		   'No feature labels defined, using feature 1.');
	end

	% now the real computation is done:
	[err, thr] = simpleroc(a,truelab);
	e.err = err;

	% Find the errors and the thresholds between the points on the curve:
	derr = diff(err)/2;
	e.thrcoords = [err(1,:); err(1:(end-1),:)+derr; err(end,:)];
	dthr = diff(thr)/2;
	if ~isempty(dthr) % in some cases there is just 1 threshold value
		               % defined :-( (sigh)
		e.thresholds = [thr(1); thr(1:(end-1))+dthr; thr(end)];
	else
		e.thresholds = [thr(1); thr(end)];
	end

else

	% Separate mapping and dataset are given, so we have to map the data
	% first:
	ismapping(w);
	istrained(w);
	w = setbatch(w,0);  %NEVER use batches!!

	e = feval(mfilename,a*w);

end

return
