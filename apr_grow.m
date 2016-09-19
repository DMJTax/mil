function [mn,mx]=apr_grow(bags,rel)

dim = sum(rel);
if (dim==0)
	error('All features become non-relevant.');
end

rel = find(rel);
nrbags = size(bags,1);

minimax = [repmat(inf,1,dim);
           repmat(-inf,1,dim)];
for j=1:nrbags
	bags{j} = bags{j}(:,rel);
	mx = max(bags{j},[],1);
	J = find(mx<minimax(1,:));
	minimax(1,J) = mx(J);

	mn = min(bags{j},[],1);
	J = find(mn>minimax(2,:));
	minimax(2,J) = mn(J);
end
center = mean(minimax);

% initial positive instance:
min_d = inf;
for j=1:nrbags
	d = sqeucldistm(bags{j},center);
	[md,mI] = min(d);
	if (md<min_d)
		min_d = md;
		start_bag = j;
		start_inst = mI;
	end
end

chosen = zeros(nrbags,dim);
chosen(1,:) = bags{start_bag}(start_inst,:);

usage = zeros(1,nrbags);
usage(start_bag) = 1;

pointer_bags = zeros(1,nrbags);
pointer_bags(1) = start_bag;
pointer_inst = zeros(1,nrbags);
pointer_inst(1) = start_inst;

for i=2:nrbags
	% greedy improve
	curAPR = minmax(chosen(1:(i-1),:));
	curSize = sum(diff(curAPR));
	newSize = inf;
	for j=1:nrbags
		if ~usage(j)
			tmpx= bags{j};
			for k=1:size(bags{j},1)
				tmpAPR = minmax([curAPR;tmpx(k,:)]);
				tmpSize = sum(diff(tmpAPR));
				if (tmpSize<newSize)
					newSize = tmpSize;
					pointer_bags(i) = j;
					pointer_inst(i) = k;
					chosen(i,:) = tmpx(k,:);
				end
			end
		end
	end
	usage(pointer_bags(i))=1;

	% backfitting
	changed = 1;
	while changed
		changed = 0;
		% leave instance 'm' out:
		for m=1:i
			tmpAPR = minmax([chosen(1:(m-1),:); chosen((m+1):i,:)]);
			tmpSize = sum(diff(tmpAPR));
			newSize = inf;
			curr_inst = pointer_inst(m);
			curr_bag = pointer_bags(m);
			size_curr_bag = size(bags{curr_bag},1);
			tmpx = bags{curr_bag};
			for n = 1:size_curr_bag
				tmpAPR1 = minmax([tmpAPR; tmpx(n,:)]);
				tmpSize1 = sum(diff(tmpAPR1));
				if (tmpSize1<newSize)
					newSize = tmpSize1;
					pointer_inst(m) = n;
					chosen(m,:) = tmpx(n,:);
				end
			end
			if (pointer_inst(m)~=curr_inst)
				changed = 1;
			end
		end
	end
end

apr = minmax(chosen);
mn = apr(1,:);
mx = apr(2,:);

return


function out = minmax(dat)

out = [min(dat,[],1);
       max(dat,[],1)];

return
