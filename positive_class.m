%POSITIVE_CLASS Define the positive class
%
%     B = POSITIVE_CLASS(A,CLASSLAB)
%     B = POSITIVE_CLASS(A,CLASSLAB,LABLISTNAME)
%
% INPUT
%   A             MIL dataset
%   CLASSLAB      Class label
%   LABLISTNAME   New class list
%
% OUTPUT
%   B             Relabeled MIL dataset
%
% DESCRIPTION
% Rename the classes mentioned in CLASSLAB to 'positive' and all the
% other classes 'negative'.
%
% Alternatively, first change to the label list LABLISTNAME, and then
% rename the classes mentioned in CLASSLAB to 'positive'. The label list
% will be renamed to 'millab'.
%
% SEE ALSO
% genmil, find_positive, ispositive

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = positive_class(a,classname,lablistname)
if nargin<3
   lablistname = '';
end

if ~isempty(lablistname)
   a = changelablist(a,lablistname);
end
if isa(classname,'char')
   % then we match the class name:
   id = strmatch(classname,getlablist(a),'exact');
else
   % we use just the class number:
   id = classname;
end

% generate the new labels:
nlab = getnlab(a);
I = (nlab==id)+1;
thisll = ['negative';'positive'];

% make this the millab:
% check if millab already exists...
lln = getlablistnames(a);
llid = strmatch('millab',lln,'exact');
if isempty(llid)
   b = addlabels(a,thisll(I,:),'millab');
else
   % hmm... millab already exist, be careful that we do not destroy the
   % original labels
   if llid==curlablist(a)
      % store the original labels in something else:
      a = addlabels(a,getlab(a),'original');
   end
   a = changelablist(a,'millab');
   a = setnlab(a,I);
   b = setlablist(a,thisll);
end

% what is wisdom?
b = setprior(b,[]);


