%GENMIL Generate MIL dataset
%
%     X = GENMIL(X,CLASSLAB,BAGID,COMBRULE)
%     X = GENMIL(X,POSCLASSLAB)
%     X = GENMIL(X,NEWBAGLAB)
%
% INPUT
%   X            data matrix  or  datafile
%   CLASSLAB     instance label
%   BAGID        bag identifiers
%   COMBRULE     instance label combination rule (default = 'presence')
%   POSCLASSLAB  label of target class
%   NEWBAGLAB    bag labels
%
% DESCRIPTION
% Generate a MIL dataset from data matrix X, instance labels CLASSLAB
% and instance bag identifiers BAGID. The instance class labels should
% be either 'positive' or 'negative'. The bag identifiers can be
% anything (but they are typically numbers between 1 and B=nr_of_bags).
% The COMBRULE defines how the bag labels can be derived from the
% instance labels.
%
% When no BAGID is supplied, each instance is a single bag. When
% CLASSLAB contains a single label, all objects with that label will be
% made 'positive', all others are labeled 'negative'.
%
% When X is a datafile, and BAGLAB is empty, then each file is used as a
% bag. Operations can then be performed per bag (=file) reducing the
% memory load significantly. It is possible to supply a single label
% POSCLASSLAB, labeling all instances of this class 'positive' and all
% others 'negative'. When NEWBAGLAB has B labels (B=number of bags in
% X), then the instances in the bags are labeled according to the
% NEWBAGLAB entry.
%
% When needed, the 'millab' labels will be set to the current labels.
%
% SEE ALSO
%   GETBAGS, MILCOMBINE, MILMAP

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function x = genmil(x,classlab,baglab,combrule)
if nargin<4
	combrule = 'presence';
end
if nargin<3
	baglab = '';
end
if nargin<2
	classlab = '';
end

if isdataset(x)
	% check if we really need to do something

	% first take care for the bag labels:
	if isempty(baglab)
		if ~hasmilbags(x)
			if isdatafile(x)
				warning('mil:genmil:useFileAsBag',...
					'No bag identifiers given: each FILE is a bag.');
				x = setmilinfo(x,'useFileAsBag',1);
			else
				warning('mil:genmil:useObjAsBag',...
					'No bag identifiers present: each obj is a bag.');
				x = setident(x,(1:size(x,1))','milbag');
			end
		end %(it already had mil bags defined...)

	else % baglab is defined
		if size(baglab,1)~=size(x,1)
			error('Number of bag labels does not match size of X.');
		end
		x = setident(x,baglab,'milbag');
	end
	% next take care for the class labels:
	if isempty(classlab)
		% do we already have mil-labels defined?
		if ~ismillabeled(x)
			% if not, set the current labels to the 'millab' labels
			lablist = getlablist(x);
			if isempty(lablist) || all(all(~isfinite(lablist)))
				% no labels, no nothing! Just return now?
				x = setmilinfo(x,'combinerule',combrule);
				return;
			end
			I = zeros(size(lablist,1),1);
			% flag all labels that are 'positive'
			I(strcmp('positive',lablist)) = 1;
			% flag all labels that are 'negative'
			I(strcmp('negative',lablist)) = 1;
			% sooo, and who is not flagged?
			if any(I==0)
				warning('Lablist contains other labels than positive and negative.');
			end
         if ~hasmilbags(x)
            x = addlabels(x,getlabels(x),'millab');
         end
		else % we have already a genuine mil set?
			% make millab the active labels?
			x = changelablist(x,'millab');
		end
	else
		% Class labels defined
		if isa(classlab,'cell')
			classlab=cell2mat(classlab);
		end
		%DXD I make a complicated exception here: 
		%    When I do  gendat(df, baglab), where df is a datafile(!!)
		%    I will first make all files in df a bag, and label the bags
		%    according to classlab:
		if (size(classlab,1)>1) && isdatafile(x) && isempty(baglab)
			% (I now know that each file is a bag, so I have to look at the
			% file_index)
			I = getident(x,'file_index'); I = I(:,1);
			bagname = unique(I); %Expensive??
			newinstlab = zeros(size(x,1),8);
			for i=1:length(bagname)
				J = find(I==bagname(i,:));
				newinstlab(J,:) = repmat(classlab(i,:),length(J),1);
			end
         if ~hasmilbags(x)
            x = addlabels(x,char(newinstlab),'millab');
         end
			x = changelablist(x,'millab');
		else
			% with large datasets we have to act carefully: don't give a
			% full set of string labels, but supply the nlab's and later fix
			% the lablist:
			[dummy,nl,ll] = genmillabels(getlabels(x),classlab);
         if ~hasmilbags(x)
            x = addlabels(x,nl,'millab');
         end
			x = changelablist(x,'millab');
			x = setlablist(x,ll);
		end
	end
   % pfff, we are done

else
	% Create a MIL set from 'scratch':
	if isa(x,'cell')
		if ~isempty(classlab)
			if length(x)~=size(classlab)
				error('Number of labels should fit the number of cells');
			end
			for i=1:length(x)
				newlab{i,1} = repmat(classlab(i,:),size(x{i},1),1);
			end
			classlab = cell2mat(newlab);
		end
		for i=1:length(x)
			baglab{i,1} = repmat(i,size(x{i},1),1);
		end
		x = cell2mat(x);
		baglab = cell2mat(baglab);
	end
	% x should be a double here
	if ~isa(x,'double')
		error('Data X should be a (double) data matrix.');
	end
	if isempty(classlab)
		x = prdataset(x);
	else
		x = prdataset(x,classlab);
	end
	x = setlablistnames(x,'millab','default');
	x = setprior(x,getprior(x,0)); %use empirical class priors
	if isempty(baglab)
		warning('mil:genmil:useFileAsBag',...
			'No bag identifiers present: each obj is a bag.');
		x = setident(x,(1:size(x,1))','milbag');
	else
		x = setident(x,baglab,'milbag');
	end
end
% last but not least: define the combining rule:
x = setmilinfo(x,'combinerule',combrule);

return
