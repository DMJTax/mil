%CREATEMILDATAFILE
%
%      CREATEMILDATAFILE(INDIR,OUTDIR)
%
% INPUT
%     INDIR   Directory containing class directories with files
%     OUTDIR  Directory containing files suitable for 'prdatafile'
%
% DESCRIPTION
% Create a directory full of data that can be read by Prtools as a
% 'half-baked' datafile. The INDIR directory should contain
% subdirectories with files. Each of the directories is considered a
% class, and each of the files is considered one object from that class.
% The data is read, a lablist is created and all the objects are stored
% in OUTDIR. This OUTDIR does not have subdirectories.
%
% A MIL datafile can now be created using:
% >> X = datafile(OUTDIR, 'half-baked');
% >> A = genmil(X,'apple');
% assuming that one of the directories in the directory OUTDIR is called
% 'apple'.
%
% SEE ALSO
% genmil

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function createmildatafile(indir,outdir)

if nargin<2
	% Define the output directory:
	outdir = 'prsival';
end
if nargin<1
	% Define where the original bag features are stored:
	indir = 'SIVAL_IHS32_4DiffNbr_distribution/bags';
end

% First find all the classes that are available:
dnames = dir(indir);
classname = [];
for i=1:length(dnames)
	if (dnames(i).name(1)~='.') & (dnames(i).isdir==1)
		%we found a directory to add
		classname = strvcat(classname,dnames(i).name);
	end
end

% Now read each of the files, make a dataset, fix the label to match the
% classlabels (made before) and store it in a .mat file.
mkdir(outdir);
for i=1:size(classname,1)
	% find the files:
	disp(classname(i,:)) % show what we are doing
	fnames = dir(fullfile(indir,deblank(classname(i,:)),'*.imbag'));
	for j=1:length(fnames)
		x = readimbag(fullfile(indir,deblank(classname(i,:)),fnames(j).name));
		[tmp,thisfname] = fileparts(fnames(j).name);
		% make sure all datasets have the same lablist (sigh)
		x = dataset(x,'','lablist',classname);
		x = setnlab(x,i);
		save(fullfile(outdir,thisfname),'x');
	end
end

return
