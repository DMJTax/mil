%MIL2OCSET Convert a MIL to a OC set
%
%       A = MIL2OCSET(B)
%
% INPUT
%   B      MIL dataset
%
% OUTPUT
%   A      One-class dataset
%
% DESCRIPTION
% Convert multi-instance-learning set A to one-class dataset B. This
% actually means that all occurances of 'positive'/'negative' will be
% replaced by 'target'/'outlier'. This is used in MILROC for instance,
% such that the ROC-curve of dd_tools can be used.
% The bags in the MIL dataset are not changed/touched.
%
% SEE ALSO
% milroc, oc2milset
function a = mil2ocset(b)

ismillabeled(b);
% find the positives in the milset:
Ipos = ispositive(b);
% generate occ labels:
ll = ['outlier';'target '];
lab = ll(Ipos+1,:);
% add a new labelset
a = addlabels(b,lab,'oclab');

% shall we also change the feature labels??
fl = getfeatlab(b);
if ~isempty(fl)
   ind = zeros(size(fl,1),1);
   Ip = strmatch('positive',fl);
   In = strmatch('negative',fl);
   ind(Ip) = 1;
   ind(In) = 1;
   if all(ind)
      %warning('mil:mil2ocset:PosNeg',...
      %   'The feature labels contained positive and negative.\n         This is changed to target and outlier.',1);
      if ~isempty(Ip)
         newlab(Ip,:) = 'target ';
      end
      if ~isempty(In)
         newlab(In,:) = 'outlier';
      end
      a = setfeatlab(a,newlab);
   end
end
