%GENDATMIL Randomly sample a training MIL set
%
%  [Y,Z,IY,IZ] = GENDATMIL(X,N)
%
% INPUT
%    X             MIL dataset
%    N             number of training bags
%
% OUTPUT
%    Y,Z           MIL datasets
%    IY,IZ         original indices from dataset X
%
% DESCRIPTION
% Subsample N bags from MIL dataset X and return it in the MIL dataset
% Y. All left out bags will be returned in Z. If required, IY and IZ
% return the indices of the selected instances in Y and Z respectively.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function [y,z,Iy,Iz] = gendatmil(x,n)

if nargin<2
	n = [];  % we will perform a bootstrap?
end
% if it is not MIl, fall back to the standard prtools subsampling:
if ~hasmilbags(x) 
	warning('Labels millab is not present, using standard gendat');
	[y,z,Iy,Iz] = gendat(x,n);
	return
end
% find the bags
[bag,lab,bagid,Ibag] = getbags(x);
m = length(bag);
% now see how many bags we need:
if length(n)>1     % we have a number/fraction per class
	% how many positive and negatives do we have?
	[Ip,In] = find_positive(lab);
	Ipr = randperm(length(Ip));
	if n(1)<1
		n(1) = ceil(n(1)*length(Ip));
	end
   if (n(1)>length(Ipr))
      warning('mil:gendatmil:InsufficientData',...
      'Requesting %d pos.bags, only %d available. Extra bags drawn with replacement.\n',n(1),length(Ipr));
      Ipr = ceil(rand(n(1),1)*length(Ip));
   end
	Iy = Ip(Ipr(1:n(1)));
	Iz = Ip(Ipr(n(1)+1:end));
	Inr = randperm(length(In));
	if n(2)<1
		n(2) = ceil(n(2)*length(In));
	end
   if (n(2)>length(In))
      warning('mil:gendatmil:InsufficientData',...
      'Requesting %d neg.bags, only %d available. Extra bags drawn with replacement.\n',n(2),length(In));
      In = ceil(rand(n(2),1)*length(In));
   end
	Iy = [Iy; In(Inr(1:n(2)))];
	Iz = [Iz; In(Inr(n(2)+1:end))];
else
	% only the total number/fraction is given
	I = randperm(m);
	if n<1
		n = ceil(n*m);
	end
   if n>m
      warning('mil:gendatmil:InsufficientData',...
      'Requesting %d bags, only %d available. Extra bags drawn with replacement.\n',n,m);
      Iz = [];
      while isempty(Iz)
         Iy = ceil(rand(n,1)*m);
         Iz = setdiff((1:m)',unique(Iy));
      end
   else
      Iy = I(1:n);
      Iz = I(n+1:end);
   end
end
% Iy and Iz should contain the bag identifiers that are in the train
% and test set respectively. Return back to the indices per object/
% instance:
Iy = cell2mat(Ibag(Iy));
Iz = cell2mat(Ibag(Iz));
% finally, we can return the train and test set:
y = x(Iy,:);
z = x(Iz,:);

return


