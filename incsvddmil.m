%INCSVDDMIL Incremental SVDD MIL
%
%     W = INCSVDDMIL(A,FRAC,KTYPE,PAR)
%
% Train an incremental SVDD on MIL dataset A, such that at least one
% instance of a positive bag falls inside the hypersphere, but one of
% the instances of negative bags fall inside. This is done using the
% procedures defined for the incsvdd in dd_tools: Wstartup, Wadd and Wstore.
% Therefore dd_tools is needed.
%
% See also: incsvdd, inc_add, inc_setup, inc_store

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = incsvddmil(a,frac,ktype,par)

if nargin<4
	par = 1;
end
if nargin<3
	ktype = 'p';
end
if nargin<2
	frac = 1;
end
if nargin<1 || isempty(a)
	W = prmapping(mfilename,{frac,ktype,par});
	W = setname(W,'Inc.SVDDMIL (%s, %f)',ktype,par(1));
	W = setbatch(W,0);  %NEVER use batches!!
	return
end

%find smallest positive bag
% take one inst. from smallest bag
% add from each bag the closest instance
[bags,baglab,bagid,Ibag] = getbags(a);
bagy = 2*ispositive(baglab)-1;
sz = bagsizes(a);
[s_sz,I] = sort(sz);
% make sure we start with a positive bag...
i=1;
while (i<=length(bags)) && (bagy(I(i))==-1)
	i = i+1;
end
if (i>length(bags))
	error('I cannot find the positive bags!');
end
smallestbag = I(i);
smallest_n = sz(I(i));
w = cell(smallest_n,1);
w_i = cell(smallest_n,1);
for smallest_inst = 1:smallest_n

	% start with this instance:
    W = inc_setup('svdd',ktype,par,1,bags{smallestbag}(smallest_inst,:),1);
    W.C = [inf 0.1];  %OK, how to set the C parameter for the negative class?

	% Now add an instance of the rest of the bags:
	i=1; consistentsvdd = 1; ME = [];
	if (i==smallestbag) i = i+1; end
	% but do not consider the initial bag
	while (i<=length(I)) && (consistentsvdd)
		% compute the closest dist:
		newx = bags{I(i)};
		n = size(newx,1);
		K = dd_kernel(newx,W.x,W.ktype,W.kpar);
		dist = -2*sum(K.*repmat(W.alf',n,1),2);
		for j=1:n
			dist(j) = dist(j) + dd_kernel(newx(j,:),newx(j,:),W.ktype,W.kpar);
		end
		% right, the closest is:...
		[mindist,minI] = min(dist);
		% so, add this one:
        try
			W = inc_add(W,newx(minI,:),bagy(I(i)));
		catch ME
			%ME = lasterr;
			if strcmp(ME.identifier,'inc:InfeasibleSolution')
				mil_message(6,'inst %d is not going to work out: infeasible\n',smallest_inst);
				consistentsvdd = 0;
			end
			if strcmp(ME.identifier,'dd_tools:change_R:DivideByZero')
				mil_message(6,'inst %d is not going to work out: ./0\n',smallest_inst);
				consistentsvdd = 0;
			end
		end
		% Next!
		i = i+1;
		if (i==smallestbag) i = i+1; end
	end

	if consistentsvdd
		mil_message(6,'Instance %d is useful\n',smallest_inst);
%keyboard
        w{smallest_inst} = inc_store(W);
%h = plotc(w{smallest_inst});
%set(h,'linewidth',2);

    else
        w_i{smallest_inst} = inc_store(W);
%h = plotc(w_i{smallest_inst});
%set(h,'linewidth',2,'color',[0.6 0.6 0.6]);
    end
end
% Now find the smallest final sphere:
r=repmat(Inf,smallest_n,1);
for i=1:smallest_n
	if ~isempty(w{i})
		r(i) = w{i}.data.threshold;
	end
end

% What about weird thresholds??
r(r<0) = inf;
[minr,rI] = min(r);
if isfinite(minr)
	v = w{rI};
else
	v = {};
end
if ~isempty(v)
	% oops, fix the labels:
	v = setlabels(v,['positive';'negative']);
	W = v*dd_normc*milcombine([],frac);
	W = setbatch(W,0);  %NEVER use batches!!
end




