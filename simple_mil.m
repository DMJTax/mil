%SIMPLE_MIL Apply standard classifiers for MIL
%
%   W = SIMPLE_MIL(A,FRAC,W_U)
%
% INPUT
%    A      MIL dataset
%    FRAC   Fraction of instances taken into account in evaluation
%           (default = 'presence')
%    W_U    Untrained, standard prtools mapping (default = loglc)
%
% OUTPUT
%    W      Trained simple mapping
%
% DESCRIPTION
% Use a standard untrained mapping W_U on MIL-dataset A. The classifier
% will be trained on all the data in A, without considering the fact
% that they are organized in bags.
% In the evaluation, the data from a bag is classified, and the outputs
% of all instances is combined using rule FRAC, as defined in LABELBAGP.
%
% Note that this function performs essentially the same as milcombine,
% except that for milcombine you have to use milmap.m to evaluate a test
% set:G
% >> w = simple_mil(x,0.1,ldc*classc);
% >> out = z*w;
% now becomes:
% >> w = ldc*classc*milcombine([],0.1);
% >> out = milmap(z,w);
% NOOOOOOOOO: ***this does not work anymore***
%
% SEE ALSO
%   LABELBAGP, MILCOMBINE

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = simple_mil(a,frac,w_u)
function [W,W2] = simple_mil(varargin)

argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],'presence',loglc);

if mapping_task(argin,'definition')
   [a,frac,w_u] = deal(argin{:});
   W = define_mapping(argin,'untrained','SimpleMIL with %s',getname(w_u));
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,w_u] = deal(argin{:});

	if ~ismapping(w_u) || istrained(w_u)
		error('I expect an untrained mapping w_u.');
	end

	% train it directly on all data:
	W.w = a*w_u*classc;

	%and save all useful data in a structure:
	W.frac = frac;  % a fraction should *always* be defined
	W = prmapping(mfilename,'trained',W,getlabels(W.w),size(a,2),2);
	W = setbatch(W,0);  %NEVER use batches!!
   W = setname(W,'Simple MIL with %s, q=%s',getname(w_u),num2str(frac));

elseif mapping_task(argin,'trained execution')  %testing

   [a,frac] = deal(argin{1:2});
	a = genmil(a); % make sure we have a MIL dataset
	% Unpack the mapping and dataset:
	W = getdata(frac);
   % Evaluate the classifier on all data, can combine the results to get
	% an outcome per bag:
   W2 = prmap(a,W.w);
	W = milcombine(prmap(a,W.w),W.frac);
end

return

