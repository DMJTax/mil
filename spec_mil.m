%SPEC_MIL Specializing MIL
%
%    W = SPEC_MIL(A, FRAC, W_U, N, INIT)
%
% INPUT
%   A       Dataset
%   FRAC    Fraction of positive instances (default = 0.1)
%   W_U     Untrained classifier (default = loglc)
%   N       Number of iterations (default = 100)
%   INIT    Initial labels (default = [])
%
% OUTPUT
%   W       Classifier
%
% DESCRIPTION
% Specializing multi-instance learner. Trains classifier W_U on all the
% data. Then relabels all data according to the output of this
% classifier. Then it checks that at least one instance in the positive
% bags is labeled positive, and if not, it changes the least negative
% instance to a have a positive label. This is iterated N times, or
% until the labels do not change anymore.
%
% When supplied, the instance-labels INIT_LABELS are used for
% initialization of the instances. The labels should be [0,1], where
% 0=negative, 1=positive.
%
% This procedure is a generalization of the miSVM.
%
% SEE ALSO
%   misvm, mil_combine.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function w = spec_mil(a, frac, w_u, maxiter, init_labels)
function [w,w2] = spec_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,loglc,100,[]);

if mapping_task(argin,'definition')
   [a,frac,w_u,maxiter,init_labels] = deal(argin{:});
   W = define_mapping(argin,'untrained','mi-%s',getname(w_u));
	w = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,w_u,maxiter,init_labels] = deal(argin{:});

	%extract the bags, set params:
	[bags,baglab,bagid,Ibag] = getbags(a);
	B = length(bags);
	[N,dim] = size(a);

	% first copy the labels from the bags to the instances:
	baglab = ispositive(baglab);
	if isempty(init_labels)
		y = zeros(N,1); % instance labels
		for i=1:B
			y(Ibag{i}) = 2*baglab(i)-1;
		end
	else
		if length(init_labels)~=N
			error('Please make the initial label vector %dx1.',N);
		end
         y = init_labels;
	end
	% index of all instances in positive bags:
	pos_I = find(y>0);
	nrpos_I = length(pos_I);

	% now run:
	iter = 0;
	labchanged = 1;
	while (labchanged==1)&&(iter<maxiter)
		labchanged = 0;
		iter = iter+1;
		% train the classifier:
		w = setlabels(a,y)*w_u;
		% find the output of the positive class:
		Ipos = find(getlabels(w)==1);

		% now go over the bags:
		oldy = y;
		for i=1:B
			if baglab(i)==1 % only work on positive bags
				% find the output for this bag...
				out = bags{i}*w;
				newy = out*labeld;
				% and check that it is well classified
				if all(newy==-1) %apparently, all were labeled negative, so...
					%disp('Make one instance positive...')
					% now make use that at least 1 is positive:
					[mx,mxI] = max(+out(:,Ipos));
					newy(mxI) = +1;
					y(Ibag{i}) = newy;
				end
			end
		end
		% has something changed?
		if (labchanged==0) && any(y~=oldy)
			labchanged = 1;
		end
	end
	
	% fix the labels, -1->negative, +1->positive
	ll = ['negative';'positive'];
	w2 = setlabels(w, ll((getlabels(w)+3)/2,:));
	% make it a true MIL classifier:
	w = w2*milcombine([],frac);
	% change the name of the final classifier:
	w = setname(w,'mi-%s',getname(w_u));
end




