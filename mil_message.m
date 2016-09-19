% MIL_MESSAGE Print formatted message
%
%    MIL_MESSAGE(INFO,MSG,PARAMS)
%    MIL_MESSAGE(INFO)
%
% INPUT
%   INFO     Importance-level of the message
%   MSG      The message to print
%   PARAMS   Additional parameters for the message
%
% DESCRIPTION
% Plot out a message MSG, formated like the string in fprintf and
% parameters PARAMS.
% It compares the value of INFO with the persistent parameter DD_INFO,
% if DD_INFO>=info the message is printed. So the value info indicates
% the urgency of the message: 1 is very urgent, while 5 is not really
% urgent.
%   1. pink     ALARM
%   2. red      error
%   3. yellow   warning
%   4. green    message
%   5. blue     message
%  >5  black
%
% If the persistent parameter DD_INFO does not exist, or is empty, it will be
% set to the default value 5. You can set the DD_INFO parameter by just
% calling MIL_MESSAGE with an INFO-level, like  mil_message(3)

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function mil_message(info, msg, varargin)

persistent DD_INFO;
if isempty(DD_INFO)
	DD_INFO = 5;
	if usejava('desktop')
		fprintf('DD_MESSAGE: Java desktop is running: Colors will not work!\n');
		DD_INFO = -DD_INFO;
	end
end
if (nargin==1) & (isa(info,'double'))
	if usejava('desktop') & (DD_INFO>0)
		fprintf('DD_MESSAGE: Java desktop is running: Colors will not work!\n');
		info = -info;
	end
	DD_INFO = sign(DD_INFO)*info;
	mil_message(info,'DD_MESSAGE: The current message level is set to %d.\n',info);
	return
end
if nargin<1
	if usejava('desktop') && (DD_INFO>0)
		fprintf('DD_MESSAGE: Java desktop is running: Colors will not work!\n');
		DD_INFO = -DD_INFO;
	end
	mil_message(DD_INFO,'DD_MESSAGE: The current message level is %d.\n',abs(DD_INFO));
	return
end

if ~isa(info,'double')
	% when we forget the number, we use the default info = 3
	varargin = [{msg} varargin];
	msg = info;
	info = 3;
end
if abs(DD_INFO)>=info
  % Put some spaces in front for automatic indention:
  %str = repmat(' ',1,info);
  if (info<6) & (DD_INFO>0)
	  clrs = ['31';'35';'32';'36';'34'];
	  if info<0,
		  fprintf(msg,varargin{:});
	  else
		  intro = [char(27) '[1;',clrs(info,:),'m'];
		  outro = [char(27) '[0;0m'];
		  fprintf([intro,msg,outro],varargin{:});
	  end;
  else
	  %fprintf([str,msg],varargin{:});
	  fprintf(msg,varargin{:});
  end
end
return
