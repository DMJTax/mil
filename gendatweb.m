%GENDATWEB Web dataset
%
%   [X,Z] = GENDATWEB(NR)
%
% INPUT
%   NR      Target class
%
% OUTPUT
%   X,Z     MIL dataset
%
% DESCRIPTION
% The problem is to classify webpages in two classes; interesting or
% non-interesting. The webpages are characterized by their collection of
% links to other webpages. These other webpages are the instances.  In
% total 9 users are asked to classify pages in interesting or not,
% therefore 1<=NR<=9.
% The web index pages are mainly from 1) http://www.yahoo.com 2)
% http://www.cnn.com 3) http://www.foxnews.com
%
% The data is already split in a training and testing set, X and Z
% respectively.
%
% REFERENCE
% Z.-H. Zhou, K. Jiang, and M. Li. Multi-Instance Learning
% based Web Mining. Applied Intelligence, 2005, 22(2): 135-147.
%
% SEE ALSO
% mildatapath
function [x,z] = gendatweb(nr)

if nargin<1
	nr = 1;
end
if (nr>9) | (nr<1)
	error('Only 9 webpage datasets are defined.');
end

prload(fullfile(mildatapath,'milweb/',sprintf('v%d.mat',nr)));
x = setident(x);
z = setident(z);
x.targets=[];
z.targets=[];
x = setmilinfo(x,'combrule','presence');
z = setmilinfo(z,'combrule','presence');
x = setname(x,'Web recomm. %d',nr);
z = setname(z,'Web recomm. %d',nr);

return

