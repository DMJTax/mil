%SCATTERMIL Scatterplot of MIL dataset
%
%     SCATTERMIL(A)
%
% Make a scatterplot of a MIL dataset, where each instance in a bag is
% scattered, with a link to the mean vector.

function scattermil(a,clrs)
if nargin<2
   clrs = ['b+';'r*'];
end

% get all data
[bag,baglab] = getbags(a);
y = ispositive(baglab);
B = length(bag);

% make the axis correctly:
scatterd(a,'w.'); hold on;

% go over the bags:
for i=1:B
   meanvec = mean(bag{i});
   if y(i)==0
      scatterd(bag{i},clrs(1,:));
      hold on;
      for j=1:size(bag{i},1)
         plot([bag{i}(j,1), meanvec(1)],[bag{i}(j,2), meanvec(2)],[clrs(1,1),'-']);
         hold on;
      end
   else
      scatterd(bag{i},clrs(2,:));
      hold on;
      for j=1:size(bag{i},1)
         plot([bag{i}(j,1), meanvec(1)],[bag{i}(j,2), meanvec(2)],[clrs(2,1),'-']);
         hold on;
      end
   end
end




