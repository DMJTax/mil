%MILDISP Display MIL dataset
%
%    MILDISP(X)
%
% Display MIL dataset characteristics

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function mildisp(x)

if hasmilbags(x)
	%copymethod should be defined
	%copymethod = getmilinfo(x,'combrule');
	[bags,lab] = getbags(x);
	[n,p] = size(x);
	m = length(bags);
	dname = getname(x);
	if ~isempty(dname)
		dname = [dname,', '];
	end
	if isdatafile(x)
		dtype = 'datafile';
	else
		dtype = 'dataset';
	end
	if isempty(lab)
		fprintf('%s%d by %d UNlabeled MIL %s with %d bags\n',...
			dname,n,p,dtype,m);
	else
		[Ip,In] = find_positive(lab);
		fprintf('%s%d by %d MIL %s with %d bags: [%d pos, %d neg]\n',...
			dname,n,p,dtype,m,length(Ip),length(In));
	end
else
	display(x);
end

