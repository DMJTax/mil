% Investigate Musk:
a = gendatmilg([30 30]);
%a = reallifemil(102);

%settings for classification:
reg = 1e-6;
w = {%apr_mil([],'presence',75,0.999,0.001,1);
	%scalem([],'variance')*maxDD_mil([],'presence',100);
	milvector([],'m')*scalem([],'variance')*ldc([],0.1,0.1)*classc;
	%milvector([],'m')*qdc([],0.1,0.1)*classc;
	milvector([],'e')*scalem([],'variance')*ldc([],0.1,0.1)*classc;
	%milvector([],'e')*qdc([],0.1,0.1)*classc;
	incsvddmil([],1,'p',1);
};
wnames = getwnames(w);

%set other parameters and storage:
nrfolds = 10;
nrw = length(w);
err = repmat(NaN,[nrw 2 nrfolds]);

% start the loops:
I = nrfolds;
for i=1:nrfolds
    
	mil_message(3,'%d/%d ',i,nrfolds);
	[x,z,I] = milcrossval(a,I);

	for j=1:nrw
		mil_message(4,'.');
		w_tr = x*w{j};
		out = z*w_tr;
      err(j,1,i) = out*testd;
		err(j,2,i) = mil_auc(out*milroc);
	end
end
mil_message(3,'\n');

% and store everything nicely:
if isempty(wnames) wnames = getwnames(w); end
R = results(err,wnames,{'cl.error' 'AUC'},(1:nrfolds)');
R = setdimname(R,'classifier','dataset','run');
R = setname(R,getname(a));

% And give some output to the command line:
fprintf('\n%s\n\n',repmat('=',1,50));
a
S = average(100*R,3,'max1','dep');
show(S,'text','%4.1f');

