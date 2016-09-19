%MILCOMBINE Combine instance outputs to bag output
%
%    P = MILCOMBINE(Q,COMBRULE,PFEAT)
%
% INPUT
%    Q          Outputs (Posterior prob.?) for all instances
%    COMBRULE   Combining rule
%    PFEAT      Output for 'positive' class
%
% OUTPUT
%    P          Output (posterior prob?) for a bag
%
% DESCRIPTION
% Combine the classifier outputs Q of all individual instances to an
% output per bag P. It is assumed that the classifier outputs are
% 'positive' and 'negative'.  (That means that the feature labels should
% be 'positive' and 'negative') As an alternative PFEAT can be defined
% that indicates the feature/column that should be used as 'positive'
% output. When that is also not defined, the first column is assumed to
% be 'positive'.
%
% The combination rule COMBRULE can be:
%  'first'    just copy the first label
%  'majority' take the majority class
%  'vote'     identical to 'majority'
%  'presence' indicate the presence of the positive class [DEFAULT]
%  'noisyor'  noisy OR
%  'sumlog'   take the sum of the log(p)'s (similar to the product comb.)
%  'average'  average the outcomes of the bag
%  'mean'     identical to 'average'
%   F=0.1     take the F-th quantile fraction of the positives
%
% The difference with LABELSET is that here classifier outputs are combined, and
% in LABELSET labels are combined.
%
% SEE ALSO
%   LABELSET, MILMAP, GETBAGS

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function p = milcombine(q,combrule,pfeat)

if nargin<3
	pfeat = [];
end
if nargin<2
	combrule = 'presence';
end

% Without input arguments, we return an empty mapping:
if nargin==0 || isempty(q)
	p = prmapping(mfilename,'fixed',{combrule,pfeat});
	if isa(combrule,'double')
		if (combrule<1)
			combrule = sprintf('%4.1f\\%%-comb.',100*combrule);
		else
			combrule = sprintf('%2d-top-comb.',combrule);
		end
	end
	p = setname(p,combrule);
	p = setbatch(p,0);  %NEVER use batches!!
	return
end

if isa(q,'double')
	% Here we do the actual work:
	% We are supplied a data matrix of a single bag. This has to be
	% combined into one output. It is assumed that the first column is
	% positive (except if pfeat is not defined:)
	if isempty(pfeat)
		pfeat = 1;
	end
	if pfeat<1, pfeat=1; end

	% The exception, when you supply a number, this number represents a
	% fraction or object number. We have to delegate it to
	% combrule=fraction :
	if isa(combrule,'double')
		nr = combrule;
		if (nr<1), nr = ceil(nr*size(q,1)); end
		combrule = 'fraction';
   end
    
	% Depending on the method, different probabilities per class are
	% extracted:
	switch combrule
	case 'first'
		% now: copy the label of the first element
		p = q(1,:);
	case {'majority','vote'}
  		% find the max output for each instance:
		[mx,I] = max(q,[],2);
		% take care for the situation that you have a single instance in
		% your bag:
		if length(I)==1
			p = zeros(1,size(q,2));
			p(I) = 1;
		else
			% indicate the winner in a sign matrix s
			n = length(I);
			s = full(sparse(1:n,I,ones(n,1)));
			% normalize the count for the p:
			p = mean(s,1);
		end
	case 'fraction'
		% take the nr-th quantile fraction of the positives:
		[sq,I] = sort(q(:,pfeat),1,'descend');
		if nr>length(I)
			%mil_message(2,'Instance %d is requested, only %d are available.',nr,length(I));
			p = q(I(end),:);
		else
			p = q(I(nr),:);
		end
	case 'presence'
		% first find the objects that are classified positive:
		[mx,I] = max(q,[],2);
		I = find(I==pfeat);  % the pfeat column should have been the positive output
		if isempty(I)  % none was classified as positive :-(
			% take the most positive output:
			[p,I] = max(q(:,pfeat));
			p = q(I,:);
		else
			% take the most positive output of the classified positive:
			[p,maxI] = max(q(I,pfeat));
			p = q(I(maxI),:);
        end
        
    case {'noisyor', 'noisy-or'}
        %We want the negative outputs for noisy or... positive are in pfeat
        if isempty(pfeat)
            pfeat = 1;
        end
        nfeat = 3 - pfeat;  %What if one day number of classes > 2? 
        
        %For noisy or, want to do this
        %p = [prod(q(:, nfeat)) 1-prod(q(:, nfeat))];
        
        %Avoid problems with multiplication
        
        %pneg = exp(sum(log(1-q(:,pfeat))));    %positive
        %ppos = 1-exp(sum(log(q(:, nfeat))));   %negative
        
        pneg = exp(sum(log(q(:,nfeat))));
        ppos = 1 - exp(sum(log(1-q(:,pfeat) ) ));
        
        p = nan(2,1);
        p(pfeat) = ppos;
        p(nfeat) = pneg;
        
	case 'sumlog'       %VC: Is it also appropriate to name this product rule?
		p = sum(log(q),1);
	case {'mean' 'average'}
		p = mean(q,1);
        
        
    %warning for negative qs!    

	otherwise
		error(['This combrule ',combrule,' is not defined.']);
	end

else
	% We are given a dataset, hopefully MIL:
	if ~isdataset(q)
		error('I can only handle Datasets or Matrices.');
	end
	% We may be given the output of a standard classifier that was just
	% processing unlabeled data. So we have to make sure that we create
	% then something like MIL bags:
	q = genmil(q);

	% When the input is a dataset, we have to decompose it into the
	% individual bags:
	% find out what the positive output was:
	if isempty(pfeat)
		pfeat = findfeatlab(q,'positive');
		if size(q,2)>2
			warning('mil:milcombine:otherOutput',...
			'Classifier outputs more than ''positive'' and ''negative''.');
		end
	end
	% Careful when we cannot find the positive feature:
	addednegfeat = 0;
	if isempty(pfeat)
		featn = findfeatlab(q,'negative');
		if isempty(featn)
			warning('mil:milcombine:noPosOutput',...
			'No ''positive'' classifier output found, use first output.');
		else
			warning('mil:milcombine:onlyNegOutput',...
			'Only ''negative'' outputs present. Use the negated output of that.');
			q = [-q(:,featn) q];
			addednegfeat = 1;
		end
		pfeat = 1;
	end
	%DXD We may also have to check if the classifier output is normalized.
	% That is for instance important for the 'fraction'-rule
	dff = abs(sum(+q,2)-1);
	if any(dff>1e-6)
		warning('mil:milcombine:UnnormalizedInput',...
		'The input for milcombine is not normalized, shouldn''t it?');
	end
	
	% now run over the bags:
	[bags,baglab,bagid] = getbags(q);
	p = zeros(length(bags),size(q,2));
	for i=1:length(bags)
		% Combine the probabilities of the bag into one:
		p(i,:) = milcombine(double(bags{i}),combrule,pfeat);
	end
	% Careful to remove the artificially added first feature:
	if addednegfeat
		p = p(:,2:end);
	end
	% and store it in a dataset:
	p = prdataset(p,baglab,'featlab',getfeatlab(q));
	p = setident(p,bagid,'milbag');
	p = setprior(p,getprior(p,0));
	p = setname(p,getname(q));

end



return

