% MILDATAPATH Path to MIL datasets
%
%     DPATH = MILDATAPATH(NEWPATH)
%
% INPUT
%   NEWPATH     Path to MIL datasets
%
% OUTPUT
%   DPATH       Path to MIL datasets
%
% DESCRIPTION
% Define the directory name where all MIL dataset are stored.
% When you supply it a path, a global variable is created that stores
% the location of the MIL datasets. In the functions GENDATMIL* this
% path is retrieved by a call to MILDATAPATH.
%
% SEE ALSO
% gendatmilmusk, gendatbirds, gendatdrive, ...

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function dpath = mildatapath(newpath)

persistent MILDATAPATH;
if nargin<1
	if isempty(MILDATAPATH)
		% the path has to be derived for the machine
		if strncmp(computer,'MAC',3)
			dpath = '/data/mil/';
		else
			if strcmp(computer,'GLNXA64')
				dpath = '/tudelft.net/staff-groups/ewi/insy/PRLab/data/mil/';
			else
				dpath = '/data/pr/home/davidt/data/mil/';
			end
		end
		MILDATAPATH = dpath;
	else
		% here it should already be given in the global var:
		dpath = MILDATAPATH;
	end

else
	% the path was already given by the user
	MILDATAPATH = newpath;
	dpath = newpath;
end

return
