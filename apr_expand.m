function [mn,mx] = apr_expand(x,lbs,ubs,rel,tau,epsilon,step)

dim = sum(rel);
if dim==0
	error('No relevant features defined.');
end

n = size(x,1);
pos = [];
rel = find(rel);
for i=1:n
	pos = [pos; x{i}(:,rel)];
end
for i=1:dim
	sigm = ((lbs(i)-ubs(i))/2)/mynorminv((1-tau)/2);
	I = (pos(:,i)>=lbs(i))&(pos(:,i)<=ubs(i));
	cur_dim = pos(I,i);
	coeff = 1/length(cur_dim);

	tmplb = lbs(i);
	tmpprob = coeff*sum(mynormcdf(tmplb,cur_dim,sigm));
	while (tmpprob>epsilon/2)
		tmplb = tmplb - step;
		tmpprob = coeff*sum(mynormcdf(tmplb,cur_dim,sigm));
	end
	tmpub = ubs(i);
	tmpprob = coeff*sum(mynormcdf(tmpub,cur_dim,sigm));
	while (tmpprob<=(1-epsilon/2))
		tmpub = tmpub + step;
		tmpprob = coeff*sum(mynormcdf(tmpub,cur_dim,sigm));
	end
	mn(i) = tmplb;
	mx(i) = tmpub;
end

return
