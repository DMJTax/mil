%APR_DISCRIM
%    [result,converged] = apr_discrim(x,mn,mx,rel,thres)
function [result,converged] = apr_discrim(x,mn,mx,rel,thres)

x = cell2mat(x);
[n,p] = size(x);
lbs = zeros(1,p);
ubs = zeros(1,p);
lbs(find(rel)) = mn;
ubs(find(rel)) = mx;

count = 0;
discrimed = zeros(n,1);
under_consider = rel;
result = zeros(1,p);

while ~((count==n) | (sum(under_consider)==0))
	discrimlist = cell(p,1);
	for i=1:n
		if ~discrimed(i)
			outdistance = zeros(1,p);
			for j=1:p
				if under_consider(j)
					if (x(i,j)<lbs(j))
						outdistance(j) = abs(x(i,j)-lbs(j));
						if outdistance(j)>=thres
							discrimlist{j} = [discrimlist{j} i];
						end
					elseif x(i,j)>ubs(j)
						outdistance(j) = abs(x(i,j)-ubs(j));
						if outdistance(j)>=thres
							discrimlist{j} = [discrimlist{j} i];
						end
					end
				end
			end
			[maxim,ind] = max(outdistance);
			if (maxim==0)
				discrimed(i) = 1;
				count = count+1;
			elseif (maxim<thres)
				discrimlist{ind} = [discrimlist{ind} i];
			end
		end
	end
	discrim_num = zeros(1,p);
	for k=1:p
		discrim_num(k) = size(discrimlist{k},2);
	end
	[maxim,ind] = max(discrim_num);
	for m=1:maxim
		discrimed(discrimlist{ind}(m))=1;
		count = count+1;
	end
	under_consider(ind) = 0;
	result(ind) = 1;
end

converged = (sum(result~=rel)==0);

return
