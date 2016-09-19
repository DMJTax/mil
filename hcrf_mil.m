% w = hcrf_mil(a,frac,useh,reg,maxIter)
%
function w = crf_mil(a,frac,useh,reg,maxIter)
if nargin<5
	maxIter = 50;
end
if nargin<4
	reg = 1.0;;
end
if nargin<3
	useh = 0;
end
if nargin<2
	frac = 'presence';
end
if (nargin<1) || isempty(a)
	w = mapping(mfilename,{frac,useh,reg,maxIter});
	w = setbatch(w,0);  %NEVER use batches!!
	w = setname(w,sprintf('HCRF (reg=%1.1e)',reg));
	return
end

if ~ismapping(frac)
	%if ~ismilset(a) error('I need a MIL dataset.'); end
	% Store the bags as individual sequences:
	[n,dim] = size(a);
	[bag,baglab,bagid,Ibag] = getbags(a);
	nlaba = getnlab(a);
	nrbags = length(bag);
	x = {}; labx = {};
	% now we choose between CRF and HCRF:
	windowSize = 0;
	optimizer = 'bfgs';
	if useh
		% store the bags in a cell-array, and the labels in int32's,
		% furthermore, the labels contain only the bag label and should start at 0.
		bagnl = ispositive(baglab);
		for i=1:nrbags
			x{i} = bag{i}';
			%labx{i} = int32(repmat(bagnl(i),1,size(x{i},2)));
		end
		modelname = 'hcrf';
		nrhidden = 10;
		matHCRF('createToolbox',modelname,optimizer,nrhidden,windowSize);
		matHCRF('setData',x,[],int32(bagnl));
	else
		% store the bags in a cell-array, and the labels in int32's,
		% furthermore, the labels should start at 0.
		for i=1:nrbags
			labx{i} = int32(nlaba(Ibag{i})')-1;
			x{i} = bag{i}';
		end
		modelname = 'crf';
		matHCRF('createToolbox',modelname,optimizer,0,windowSize);
		matHCRF('setData',x,labx);
	end
	% train it:
	matHCRF('set','regularization',reg);
	matHCRF('set','maxIterations',maxIter);
	matHCRF('set','debugLevel',0);
	matHCRF('train');
	[crfmodel,feat] = matHCRF('getModel');

	%store the resulting weights
	W.modelname = modelname;
	W.model = crfmodel;
	W.optimizer = optimizer;
	W.feat = feat;  %needed?
	W.windowSize = windowSize;
	W.frac = frac; % not used here...
	w = mapping(mfilename,'trained',W,getlablist(a),dim,2);
	w = setbatch(w,0);  %NEVER use batches!!
	w = setname(w,sprintf('CRF (reg=%1.1e)',reg));
else  % evaluation
	W = getdata(frac);
	% extract each timeseries
	[bag,baglab,bagid,Ibag] = getbags(a);
	n = size(bag,1);
	x = cell(1,n); labx32 = cell(1,n);
	for i=1:n
		x{i} = bag{i}';
		% fill in empty labels: (never be tempted to use the true
		% labels...)
		labx{i} = int32(zeros(1,size(x{i},2)));
	end
	% setup the crf:
	matHCRF('createToolbox',W.modelname,W.optimizer,0,W.windowSize);
	matHCRF('setData',x,labx);
	matHCRF('setModel',W.model,W.feat);
	matHCRF('set','debugLevel',0);
	matHCRF('test');
	ll = matHCRF('getResults');
	% collect the outputs, depending on the model...:
	out = [];
	if strcmp(W.modelname,'crf')
		for i=1:n
			out = [out; ll{i}'];
		end
	elseif strcmp(W.modelname,'hcrf')
		for i=1:n
			% convert it to a probability:
			p = exp(ll{i})'; 
			%DXD: still, how do we know it corresponds to the positive or
			%negative class? Maybe we have to fix the order?
			out = [out; repmat(p/sum(p),size(x{i},2),1)];
		end
	else
		error('Model %s is unknown.',W.modelname);
	end

	%This is a bit complicated because the CRF still wants to output a
	%label per instance. And it is not guaranteed that the bag/instances
	%are in the correct order after you did a 'getbags' and then
	%concatenate the bags back into one dataset. So we have to do it
	%carefully, using the indices stored in Ibag:
	J = cell2mat(Ibag);
	laba = getlab(a); id = getident(a,'milbag');
	w = genmil(out, laba(J,:), id(J,:));
	w = setfeatlab(w,getlabels(frac));
end

