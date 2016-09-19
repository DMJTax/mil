%GENDATCOREL Corel data.
%
%     A = GENDATCOREL(CLASSNR)
%
% INPUT
%   CLASSNR    Positive class (default = 0)
%
% OUTPUT
%   A          MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem COREL. There are 20
% possible classes. The class indicated by CLASSNR will be the positive
% class. The features are obtained from Chen et al. Multiple-instance
% learning via embedded instance selection, 2007, PAMI, 28 (12), pg
% 1931-1947. Or http://www.cs.olemiss.edu/~ychen/ddsvm.html.
%
% The available classes are:
%  0 'African'         7 'Horses'          14 'Cars'
%  1 'Beach'           8 'Mountains'       15 'Waterfalls'
%  2 'Historical'      9 'Food'            16 'Antique'
%  3 'Buses'          10 'Dogs'            17 'Battleships'
%  4 'Dinosaurs'      11 'Lizards'         18 'Skiing'
%  5 'Elephants'      12 'Fashion'         19 'Desserts'   
%  6 'Flowers'        13 'Sunset'           
%
% Each of the images is segmented, and each segment is represented by
% the mean of the pixel features (or actually from 4x4 patches). The
% features are (see also Chen "Image categorization by learning and
% reasoning with regions"):
% 1. three average LUV color components
% 2. three (sqrt) energy components in the high frequency bands of the
%    wavelet transform
% 3. three shape components with normalized inertia of order 1,2,3
%
% SEE ALSO
% mildatapath

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function x = gendatcorel(nr)
if nargin<1
	nr = 0;
end

% check:
if isa(nr,'char')
	clnames = {'African' 'Beach' 'Historical' 'Buses' 'Dinosaurs' ...
	'Elephants' 'Flowers' 'Horses' 'Mountains' 'Food' 'Dogs' ...
	'Lizards' 'Fashion' 'Sunset' 'Cars' 'Waterfalls' 'Antique' ...
	'Battleships' 'Skiing' 'Desserts'};
	nr = strmatch(nr,clnames) -1;
end
if (nr<0) | (nr>19)
	error('Please make the class between 0 and 19.');
end
% now we don't want to start at 0, so:
nr = nr+1;
% and all the labels are:
classlabs = {'African' 'Beach' 'Historical' 'Buses' 'Dinosaurs' ...
'Elephants' 'Flowers' 'Horses' 'Mountains' 'Food' 'Dogs' 'Lizards' ...
'Fashion' 'Sunset' 'Cars' 'Waterfalls' 'Antique' 'Battleships' ...
'Skiing' 'Desserts'};

% Get the data and make a dataset with the correct labels inside:
% load the data:
prload([mildatapath,'/corel2000/imagefeatures.mat']);
% convert by transposing and concatenating:
nrbags = length(L);
x = [];
labx = [];
bagnr = [];
for i=1:nrbags
	n = size(D{i},2);
	x = [x; D{i}'];
	labx = [labx; repmat(L(i)+1,n,1)];
	bagnr = [bagnr; repmat(i,n,1)];
end
% define which class is positive:
lab = genmillabels(labx,nr);
% now we have it:
x = genmil(x,lab,bagnr,'presence');
x = setname(x,'Corel %s',classlabs{nr});

return
