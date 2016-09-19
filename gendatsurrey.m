%GENDATSURREY Read parts of the Surrey database
%
%      A = GENDATSURREY(CLNAME)
%
% Read of the Surrey database and use one of the classes as target
% class.  To be honest, per default the cathedral set is used as
% positive and the rest negative. That means that 5 images are labeled
% '+', the rest '-'.
%
% In total, the dataset contains 3481 images, each image divided into
% several regions (around 20-40 regions per image). Several images
% should be combined into one class, but that is not so simple to
% define. You have to go through the 3000+ images yourself and choose...
% When you found the indices of the images, you have to define CLNAME =
% [34; 120; 511; 3400];
% For instance, class 'db1' ('sea'):
% CLNAME = [97; 98; 99; 100; 101; 102; 106; 107].
function a = gendatsurrey(clname)
if nargin<1
	clname = [];
end

prload(fullfile(mildatapath,'surrey_cath'));
a = setmilinfo(a,'combrule','presence');

% When a class name is defined, we want to relabel the dataset:
if ~isempty(clname)
	% we store the original classnames in the default labels:
	a = changelablist(a,'default');
	lab = getlab(a);
	nr = getident(a,'milbag');
	newlab = ones(size(a,1),1);
	for i=1:size(clname,1)
		if isa(clname(i,:),'char')
			I = strmatch(clname(i,:),lab);
		else
			I = find(nr==clname(i));
		end
		if isempty(I)
			error('I cannot find any matches for label %s.',clname);
		end
		newlab(I) = 2;
	end
	newlab = genmillabels(newlab,2);
	a = changelablist(a,'millab');
	a = setlabels(a,newlab);
end

% define feature labels:
fl = strvcat([repmat('DCT',9,1) num2str((1:9)')],...
             [repmat('Gabor',8,1) num2str((1:8)')], ...
             [repmat('energy',3,1) num2str((1:3)')], ...
				 [repmat('entropy',3,1) num2str((1:3)')], ...
				 [repmat('mean',3,1) num2str((1:3)')], ...
             [repmat('variance',3,1) num2str((1:3)')], ...
				 [repmat('wavelet',4,1) num2str((1:4)')] );
a = setfeatlab(a,fl);
% define the name of the dataset
if ~isempty(clname) & isa(clname,'char')
	dname = sprintf('Surrey (%s etc)',clname(1,:));
else
	dname = 'Surrey';
end
a = setname(a,dname);

return

