function logL = boosting_err(lambda,h,y_ij,Ibag,t)

logL = 0;
B = length(Ibag);
y_ij = y_ij + lambda*h;
p_ij = 1./(1+exp(-y_ij));
for i=1:B
	p_i(i) = 1-prod(1-p_ij(Ibag{i}));
	if t(i)==1
		logL = logL + log(p_i(i));
	else
		logL = logL + log(1-p_i(i));
	end
end

logL = -logL; % it should MINIMIZE!!
