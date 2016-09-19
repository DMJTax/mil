%MISVM Multi-instance Support Vector machine
% 
% 	W = MISVM(A,FRAC,C,KERNELTYPE,KERNELPAR)
%
% INPUT
%   A	          Dataset
%   FRAC        Fraction of instance that has to be positive for a
%               positive bag (default = 'presence')
%   C           Regularization parameter (optional; default = 1)
%   KERNELTYPE  Name of the kernel type (see milproxm, default = 'p')
%   KERNELPAR   Kernel parameter (see milproxm, default = 1)
%
% OUTPUT
%   W           Mapping
%
% DESCRIPTION
% Optimizes a MI-support vector classifier on MIL dataset A. It is
% assumed that the KERNELTYPE, defined in function myproxm (with
% parameter KERNELPAR) computes kernel values between *instances*. In
% the optimization of miSVM a (sub)set of instances is selected from the
% positive bags such that the separability between bags is improved.
%
% REFERENCE
% "Support Vector Machines for Multiple-Instance Learning", S.Andrews,
% I.Tsochantaridis, T.Hofmann, NIPS 2003
%
% It is implemented as a one-liner in the mil toolbox:
% w = a*(spec_mil([],frac,libsvc([],myproxm([],ktype,kpar),C)*classc))
%
% SEE ALSO
%  milproxm, spec_mil

% Copyright: D.M.J. Tax
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
  
%function W = misvm(a,frac,C,ktype,kpar)
function W = misvm(varargin)
	
argin= shiftargin(varargin,'scalar');
argin = setdefaults(argin,[],'presence',1,'p',1);

if mapping_task(argin,'definition')
   [a,frac,C,ktype,kpar] = deal(argin{:});
   W = define_mapping(argin,'untrained','MI-SVM %s=%f',ktype,kpar);
	w = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [a,frac,C,ktype,kpar] = deal(argin{:});
	% this function can be rewritten in standard calls:
	% define the untrained support vector classifier:
	% (DXD:maybe I should test if the libsvc is available..)
	u_svc = libsvc([],dd_proxm([],ktype,kpar),C);
	% apply the specializing MIL:
	u = spec_mil([],frac,u_svc*classc);
	% and train!:
	w = a*u;

	% and give it a nice name:
	W = setname(w,'MI-SVM %s=%f',ktype,kpar);
end
		

