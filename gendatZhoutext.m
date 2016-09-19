%GENDATZHOUTEXT MIL text data
%
%     A = GENDATZHOUTEXT(NR,TRUE_INST_LAB)
%
% INPUT
%   NR              Class number
%   TRUE_INST_LAB   Use the true instance label (default = 0)
%
% OUTPUT
%   A               MIL dataset
%
% DESCRIPTION
% Get the MIL text data by Zhou Zhihua, originally used in
% Z.-H. Zhou, Y.-Y. Sun, and Y.-F. Li. Multi-instance learning by treating 
% instances as non-i.i.d. samples. In: Proceedings of the 26th International 
% Conference on Machine Learning (ICML'09), Montreal, Canada, 2009, pp.1249-1256
% http://cs.nju.edu.cn/zhouzh/zhouzh.files/publication/annex/mil-text-data.htm
%
% There are 20 versions, NR=1 (default), in which each time another
% newsgroup is the positive class:
% 1.alt.atheism.mat               8.rec.autos.mat          15.sci.space.mat
% 2.comp.graphics.mat             9.rec.motorcycles.mat    16.soc.religion.christian.mat
% 3.comp.os.ms-windows.misc.mat  10.rec.sport.baseball.mat 17.talk.politics.guns.mat
% 4.comp.sys.ibm.pc.hardware.mat 11.rec.sport.hockey.mat   18.talk.politics.mideast.mat
% 5.comp.sys.mac.hardware.mat    12.sci.crypt.mat          19.talk.politics.misc.mat
% 6.comp.windows.x.mat           13.sci.electronics.mat    20.talk.religion.misc.mat
% 7.misc.forsale.mat             14.sci.med.mat
%
% If TRUEINSTLABEL = 1 then the instances are assigned their true
% labels; if = 0 then the instance labels are inherited from the bag label
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = gendatZhoutext(nr, trueinstancelabel)

if nargin<2
	trueinstancelabel = 0;
end
if nargin<1
	nr = 1;
end

Names = {'alt.atheism';
    'comp.graphics';
    'comp.os.ms-windows.misc';
    'comp.sys.ibm.pc.hardware';
    'comp.sys.mac.hardware';
    'comp.windows.x';
    'misc.forsale';
    'rec.autos';
    'rec.motorcycles';
    'rec.sport.baseball';
    'rec.sport.hockey';
    'sci.crypt';
    'sci.electronics';
    'sci.med';
    'sci.space';
    'soc.religion.christian';
    'talk.politics.guns';
    'talk.politics.mideast';
    'talk.politics.misc';
    'talk.religion.misc'};

% Get the data and make a dataset with the correct labels inside:
% sometimes matlab has great functions:
d = importdata(fullfile(mildatapath,'mil-text-data/data/',[Names{nr},'.mat']));

% data
dat = cell2mat(d(:,1));
lablist1 = strvcat('negative','positive');

% labels and identifiers
lab2 = d(:,3);
lab1 = d(:,3);
for j = 1:size(lab2,1),
    lab2{j} = j*ones(size(lab2{j}));  % itentifier for the bags, defining which instances are belong to a bag
    lab1{j} = d{j,2}*ones(size(lab2{j})); % Instance label (inherited from the bag label)
end
lab2 = cell2mat(lab2);
lab1 = lablist1(cell2mat(lab1)+1,:);

if trueinstancelabel == 1,
    lab1 = lablist1(cell2mat(d(:,3))+1,:); % Instance label (true instance label: concept and non-concept)
end

% generate the mil data
% CLASSLAB: label for each instance, usully it is inherited from the the bag label
% BAGLAB: Bag identifier specifying which instances belong to each bag
% X = GENMIL(X,CLASSLAB,BAGLAB,COMBRULE)
a = genmil(dat, lab1,lab2,'presence');
% a = setprior(a,[0.5 0.5]);
% finally define the name
% classlabs = {'Elephant' 'Tiger'  'Fox'};
a = setname(a,'Text(Zhou) %s',Names{nr});

return
