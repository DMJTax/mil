%MIL_VERSION Version information for mil toolbox
%
%        VER = MIL_VERSION
%        VER = MIL_VERSION UPGRADE
%
% Returns the string VER containing the version number of the currently
% loaded MIL toolbox. 
% When the Java virtual machine is running also the most up-to-date
% version of the MIL toolbox is shown.
%
% When the UPGRADE option is set, the newest version is downloaded.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function ver = mil_version(dodownload)
if nargin<1
	dodownload = '';
end

% find the current installed version 
newver = [];
newl = sprintf('\n');
p = which('apr_mil');
milpath = fileparts(p);
% find directory name:
I = findstr(milpath,filesep);
if isempty(I)
	mildir = milpath;
else
	mildir = milpath(I(end)+1:end);
end
% open the Contents file and find the current version:
h = help(mildir);
I = findstr(h,'Version');
h = h(I(1)+8:end);
I = findstr(h,' ');
ver = h(1:I(1)-1);

% now go to the standard webpage and extract the URL
if usejava('jvm')
	milpage = urlread('http://prlab.tudelft.nl/david-tax/mil.html');
	I = strfind(milpage,'MIL_DOWNLOAD');
   if isempty(I)
      fprintf('The MIL webpage cannot be reached (http://prlab.tudelft.nl/david-tax/mil.html).\n');
   else
      milurl = milpage(I(1):I(1)+150);
      I = strfind(milurl,'"');
      milurl = milurl(I(1)+1:I(2)-1);

      % now find the version of this .zip...
      I = strfind(milurl,'_');
      Idot = strfind(milurl,'.');
      newver = sprintf('%s.%s.%s',milurl(I(end-2)+1:I(end-1)-1),...
      milurl(I(end-1)+1:I(end)-1),milurl(I(end)+1:Idot(end)-1));

      % shall we update?
      if strcmp(dodownload,'upgrade')
         I = strfind(milurl,'/');
         milfile = milurl(I(end)+1:end);
         [milname,milplace] = uiputfile('*','Select place to save the mil toolbox',milfile);
         urlwrite(milurl,fullfile(milplace,milfile));
         fprintf('Success!: %s is saved in %s.\n',milfile,milplace);
         fprintf('Unzip the file and add the path to your matlab path.\n');
         return
      end
   end
else
	if strcmp(dodownload,'upgrade')
		error('Java Virtual Machine is not running. Please download the MIL toolbox manually.');
	end
end


if nargout==0
	fprintf('Currently installed version is mil %s.\n',ver);
	if ~isempty(newver)
		if newver>ver
			fprintf('The newest version is %s.\n',newver);
		elseif ver==newver
			fprintf('You are up to date.\n');
		else
			fprintf('You have a MIL toolbox from the future! (current version %s)\n',...
			newver);
		end
	end

	clear ver;
end

