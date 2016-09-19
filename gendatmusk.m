%GENDATMUSK Musk data.
%
%     A = GENDATMUSK(NR)
%
% INPUT
%   NR    Version of the MUSK dataset (default = 1)
%
% OUTPUT
%   A     MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem MUSK. There are two
% versions, NR=1 (default) and NR=2.
%
% REFERENCE
%@article{DieLatLaz1997,
%    author = {Dietterich, T.G. and Lathrop, R.H. and Lozano-Perez, T.},
%    title = {Solving the Multiple Instance Problem with Axis-Parallel
%		 Rectangles},
%    journal = {Artificial Intelligence},
%    volume = {89},
%    number = {1-2},
%    pages = {31-71},
%    year = {1997}}
%
% SEE ALSO
% mildatapath, genmil

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = musk(nr)
if nargin<1
	nr = 1;
end

% Get the data and make a dataset with the correct labels inside:
% sometimes matlab has great functions:
if nr==1
	d = importdata(fullfile(mildatapath,'musk/clean1.data'));
else
	d = importdata(fullfile(mildatapath,'musk/clean2.data'));
end
dat = d.data(:,1:(end-1));
% define the musk-labels:
lablist1 = strvcat('negative','positive');
lab1 = lablist1(1+d.data(:,end),:);
% and the molecule labels:
lab2 = strvcat(d.textdata(:,1));
a = genmil(dat, lab1,lab2,'presence');
a = setprior(a,[0.5 0.5]);
% finally define the name
a = setname(a,sprintf('Musk %d',nr));

return
