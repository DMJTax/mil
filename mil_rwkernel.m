%MIL_RWKERNEL Random walk kernel
%
%    K = MIL_RWKERNEL(V1, V2, E1, E2, NODEPAR, LAMBDA)
%
% INPUT
%   V1, V2    Nodes of two graphs, each node (row) is a feature vector
%   E1, E2    Adjacency matrices
%   NODEPAR   Parameter for RBF kernel between nodes
%   LAMBDA    Weighting factor
%
% OUTPUT
%   K         Kernel
%
% DESCRIPTION
% Random walk kernel between two graphs. This is a simple version that only
% takes node labels and edges (edge or no edge) into account.
%
% The kernel for two graphs G1 and G2 is the sum of the kernels of the
% crossproduct of their walks (i.e. all walks in G1 and all walks in
% G2). 
%  
% The kernel for two walks is the product of the kernels of the nodes and
% edges encountered along those walks. In other words, two walks are compared
% step-by-step. 
%
% NODEPAR : Parameter for RBF kernel between nodes. This depends on the
%           scaling and the number of features.
% 
% LAMBDA  : LAMBDA<1, for efficient "infinite sum" calculation, defines how
%           much emphasis is given to the higher powers of the kernel
%           matrix. Default=0.25, but other values do not seem to have a
%           huge effect on performance (at least for Musk).
% 
% REFERENCE
%@article{gärtner2003graph,
%  title={On graph kernels: Hardness results and efficient alternatives},
%  author={G{\"a}rtner, T. and Flach, P. and Wrobel, S.},
%  journal={Learning Theory and Kernel Machines},
%  pages={129--143},
%  year={2003},
%  publisher={Springer}
%}
% Implementation in MIL toolbox by Veronika Cheplygina
%
% SEE ALSO
%   MIL_SPKERNEL

function K= mil_rwkernel(V1, V2, E1, E2, nodepar, lambda)

if nargin<6
    lambda = 0.25;
end


Knode = exp(-sqeucldistm(V1,V2)/nodepar);
Knode = Knode(:);
Knode = Knode'*Knode;                       %Kernel on start node * kernel on end node


%It's possible to add an edge component to this as well! But this is even
%more time-consuming and in practice not always effective. 

%Edge difference version 1
%edgehelp1 = kron(E1, ones(size(E2)));
%edgehelp2 = kron(E2,ones(size(E1)));

%Edge difference version 2 (this does the same as KRON but is sometimes
%faster because we don't do checks)
% [p q] = size(E1);
% [m n] = size(E2);
% ii=1:p; ii=ii(ones(1,m),:);
% jj=1:q; jj=jj(ones(1,n),:);
% edgehelp1 = E1(ii,jj);
% ii=1:m; ii=ii(ones(1,p),:);
% jj=1:n; jj=jj(ones(1,q),:);
% edgehelp2 = repmat(E2,size(E1));   

% edgeDif = abs(edgehelp1-edgehelp2);
%Kedge = exp(-edgeDif.*(1-alpha)^beta);   %RBF

kr = kron(E1,E2);                  %Where can we walk
A = Knode.*kr;                     %Only keep the node kernels of the walks where we can walk... 

lim = inv(eye(size(A))-lambda*A);  %Infinite sum such as A+lambda^2*A^2+lambda^3*A^3 + .... is equal to (1-lambda*A)^-1
K = sum(sum(lim));


