%MILKERNEL MIL kernel definition
%
%         K = MILKERNEL(A,B,KTYPE,KPAR);
%
% INPUT
%     A       MIL dataset
%     B       MIL dataset
%     KTYPE   Kernel type (default = 'h')
%     KPAR    Kernel parameters (default = [])
%
% OUTPUT
%     K       Kernel dataset
%
% DESCRIPTION
% Computation of the kernel function K between bags in a Multi-instance
% Learning dataset A and B. The possible bag kernels are defined in
% MILPROXM. Both datasets A and B have to be MIL-datasets.
%
% SEE ALSO
%   MILPROXM

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function K = milkernel(A,B,ktype,kpar)
if nargin<4
	kpar = [];
end
if nargin<3
	ktype = 'h';
end
if (nargin<2) || isempty(B)
	B = A;
end

K = A*milproxm(B,ktype,kpar);

return
