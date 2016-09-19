%MCMILC Multi-class MIL classifier
%
%      W = MCMILC(A,U)
%      W = A*MCMILC([],U)
%      W = A*MCMILC(U)
%
% INPUT
%   A      Multi-class MIL dataset
%   U      Untrained MIL classifier (default = simple_mil)
%
% OUTPUT
%   W      Multi-class MIL classifier
%
% DESCRIPTION
% Train untrained MIL mapping U on the multiclass dataset A. The
% classifier is created by using 1-vs-rest classification.
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function w = mcmilc(a,w_u)
function w = mcmilc(varargin)

argin= shiftargin(varargin,'prmapping');
argin = setdefaults(argin,[],simple_mil);

if mapping_task(argin,'definition')
   [a,w_u] = deal(argin{:});
   W = define_mapping(argin,'untrained','Multiclass %f',getname(w_u));
	w = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,w_u] = deal(argin{:});
   % check
   hasbags = 0;
   if ~isempty(getmilinfo(a,'useFileAsBag'))
       hasbags = 1;
   else
       hasbags = ~isempty(getident(a,'milbag'));
   end
   if ~hasbags
       error('I need bags defined in the ident field milbag.');
   end
   ll = getlablist(a);
   c = size(ll,1);
   v = cell(c,1);
   for i=1:c
       % relabel the data:
       ai = positive_class(a,ll(i,:));
       % train:
       v{i} = ai*w_u;
   end
   % store:
   W.v = v;
   W.ll = ll;
   w = prmapping(mfilename,'trained',W,ll,size(a,2),c);
	w = setbatch(w,0);  %NEVER use batches!!
elseif mapping_task(argin,'trained execution')
   [a,w_u] = deal(argin{:});
   [bags,lab] = getbags(a);
   W = getdata(w_u);
   c = length(W.v);
   out = [];
   aa = setlabels(a,[]);
   % apply each of the classifiers:
   for i=1:c
       tmp = aa*W.v{i}*classc; % DXD classc??
       out = [out tmp(:,'positive')];
   end
   % output...
   w = prdataset(out,lab);
   w = setfeatlab(w,W.ll);
else
   error('Illegal call to mcmilc.');
end
