%GENDATSIVAL SIVAL dataset
%
%     A = GENDATSIVAL(CLASSNAME)
%
% INPUT
%   CLASSNAME     Positive class
%
% OUTPUT
%   A             MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem SIVAL. One of the 25 image
% classes can be used as positive class:
% CLASSNAME = {'AjaxOrange' 'Apple' 'Banana' 'BlueScrunge' ...
% 'CandleWithHolder' 'CardboardBox' 'CheckeredScarf' 'CokeCan' ...
% 'DataMiningBook' 'DirtyRunningShoe' 'DirtyWorkGloves' ...
% 'FabricSoftenerBox' 'FeltFlowerRug' 'GlazedWoodPot' 'GoldMedal' ...
% 'GreenTeaBox' 'JuliesPot' 'LargeSpoon' 'RapBook' 'SmileyFaceDoll' ...
% 'SpriteCan' 'StripedNotebook' 'TranslucentBowl' 'WD40Can' ...
% 'WoodRollingPin'};
%
% The SIVAL (Spatially Independent, Variable Area, and Lighting) benchmark
% SIVAL includes 25 different image categories with 60 images per
% category. This benchmark emphasizes the task of Localized CBIR. The
% categories consist of images of single objects photographed against
% highly diverse backgrounds. The objects may occur anywhere spatially
% in the image and also may be photographed at a wide-angle or close up.
% We have created this benchmark since most of the Corel object images
% contain close-ups of an object that is centered in the image and
% typically occupies a majority of the image
%
% This dataset originates from http://www.cs.wustl.edu/~sg/multi-inst-data/
% 
% SEE ALSO
% mildatapath

function a = gendatsival(classname)
if nargin<1
	classname = 'Apple';
end

if exist(fullfile(mildatapath,'prsival.mat'))==2
	prload(fullfile(mildatapath,'prsival.mat'));
	% we already have a saved version:
	a = positive_class(x,classname,'default');
else

	allnames = {'AjaxOrange' 'Apple' 'Banana' 'BlueScrunge' ...
	'CandleWithHolder' 'CardboardBox' 'CheckeredScarf' 'CokeCan' ...
	'DataMiningBook' 'DirtyRunningShoe' 'DirtyWorkGloves' ...
	'FabricSoftenerBox' 'FeltFlowerRug' 'GlazedWoodPot' 'GoldMedal' ...
	'GreenTeaBox' 'JuliesPot' 'LargeSpoon' 'RapBook' 'SmileyFaceDoll' ...
	'SpriteCan' 'StripedNotebook' 'TranslucentBowl' 'WD40Can' ...
	'WoodRollingPin'};
	if isempty(strmatch(classname,allnames))
		error('Class %s is not present in the SIVAL dataset.',classname);
	end

	a = datafile(fullfile(mildatapath,'sival/prsival'),'half-baked');
	warning off mil:genmil:useFileAsBag;
		a = genmil(a,classname,[],'presence');
	warning on mil:genmil:useFileAsBag;
	a = dataset(a);
end
a = setmilinfo(a,'combinerule','presence');
a = setname(a,'Sival %s',classname);
a = setprior(a,getprior(a,0));

return
