%INC_SPEC_MIL Incrementally Specializing MIL
%
%    W = INC_SPEC_MIL(A, FRAC, W_U, REDUCEFRAC, LABELTONEGATIVE)
%
% INPUT
%   A            MIL dataset
%   FRAC         Fraction of instances that should be positive 
%                (default = 0.1)
%   W_U          Untrained mapping (default = ldc)
%   REDUCEFRAC   Fraction of reduction towards FRAC (default = 0.2)
%   LABELTONEGATIVE Relabel positive instances (default = 0)
%
% OUTPUT
%   W            MIL classifier
%
% DESCRIPTION
% Specializing multi-instance learner. Trains classifier W_U on all the
% data. Then relabels all data according to the output of this
% classifier. 
% 1. it labels instances according to their bag label
% 2. a classifier is trained
% 3. then a fraction REDUCEFRAC of the most negative instances in the
%    positive bags is removed (lab is set to 0), until a minimum FRAC is left
%    When LABELTONEGATIVE=TRUE, the most negative instances are relabeld
%    to the negative class.
% 4. goto 2.
%
% So to clarify: when REDUCEFRAC=0.2, in each round 20% of the most
% negative instances in the positive bags is *ignored*, until a fraction
% FRAC of the instances is left.
%
% SEE ALSO
%   SPECSVDDMIL, MISVM

%function w = inc_spec_mil(a, frac, w_u, reducefrac,labeltonegative)
function w = inc_spec_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],0.1,ldc,0.2,0);

if mapping_task(argin,'definition')
   [a,frac,w_u,reducefrac,labeltonegative] = deal(argin{:});
   if labeltonegative>0
      w = define_mapping(argin,'untrained','IncSpec-%s (relabel inst.)',getname(w_u));
   else
      w = define_mapping(argin,'untrained','IncSpec-%s (ignore inst.)',getname(w_u));
   end
	w = setbatch(w,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')

   [a,frac,w_u,reducefrac,labeltonegative] = deal(argin{:});
	%extract the bags, set params:
	[bags,baglab,bagid,Ibag] = getbags(a);
	B = length(bags);
	[N,dim] = size(a);
	% what label to use for the instances that are rejected/ignored:
	if labeltonegative
		rej_label = -1;
	else
		rej_label = NaN;
	end

	% first copy the labels from the bags to the instances:
	baglab = ispositive(baglab);
	y = zeros(N,1); % instance labels
	for i=1:B
		y(Ibag{i}) = 2*baglab(i)-1;
	end
	% make sure the output is normalized??
	w_u = w_u*classc;
	% train classifier on all:
	x = prdataset(+a,y);
	x = setprior(x,getprior(a,0));
	w = x*w_u;
	% what output is the positive class?
	featnr = find(getlabels(w)==+1);

	%startup
	rejfrac = 0;
	done = 0;

	while (~done)
		% adjust frac to reject:
		rejfrac = rejfrac+reducefrac;
		if (rejfrac>1-frac)
			done = 1;
			rejfrac = 1-frac;
		end
		% relabel some instances:
		newy = y;
		for i=1:B
			if baglab(i)
				out = bags{i}*w;  
				[sout,I] = sort(+out(:,featnr));
				n = floor(size(out,1)*rejfrac);
				newy(Ibag{i}(I(1:n))) = rej_label;  % find the guys to relabel
			end
		end
		% retrain the classifier:
		w = seldat(prdataset(x,newy))*w_u;
	end

	% fix the labels, -1->negative, +1->positive
	ll = ['negative';'positive'];
	w = setlabels(w, ll((getlabels(w)+3)/2,:));
	% make it a true MIL classifier:
	W.frac = frac;
	W.w = w;
	w = prmapping(mfilename,'trained',W,getlabels(w),size(a,2),2);
	if labeltonegative
		w = setname(w,'Inc.spec-%s (relabel inst.)',getname(w_u));
	else
		w = setname(w,'Inc.spec-%s (ignore inst.)',getname(w_u));
	end
elseif mapping_task(argin,'trained execution')

   [a,frac] = deal(argin{1:2});
	% Unpack
	a = genmil(a);
	W = getdata(frac);
	w = milcombine(prmap(a,W.w),W.frac);

end




