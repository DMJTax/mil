%MIL_SPKERNEL Shortest path kernel
%
%    K = MIL_SPKERNEL(V1, V2, E1, E2, NODEPAR, EDGEPAR, ALPHA)
%
% Shortest path kernel between two graphs. The graphs need to be
% transformed to shortest path graphs prior to computation. The kernel then
% basically computes the random walk kernel for walks of length 1.  
%
% V1, V2 :  Nodes of two graphs, each node (row) is a feature vector
% E1, E2 :  Adjacency matrices. These already need to be transformed to
%           shortest path matrices using FLOYDTRANSFORM.m
%
% NODEPAR : Parameter for RBF kernel for nodes. This depends on the scaling
%           and the number of features. 
%
% EDGEPAR:  Parameter for RBG kernel for edges (in fact, for path lengths).
%           This depends on the number of instance per bag / connectivity of the
%           produced graphs.
%
% ALPHA  :  Parameter for weighting node and edge kernels (At ALPHA = 1, only nodes are considered, at ALPHA=0, only edges are considered) 
%
% Example classifier, with settings for Musk1:
% w=scalem([],'variance')*milproxm([], 'sp', [10, 250, 3, 0.5])*scalem([],'variance')*knnc([],1);
%
% Original kernel:
%
% @article{borgwardt2005shortest,
%  title={{Shortest-path kernels on graphs}},
%  author={Borgwardt, K.M. and Kriegel, H.P.},
%  issn={1550-4786},
%  year={2005},
%  publisher={IEEE Computer Society}
%}
%
% Implementation in MIL toolbox by Veronika Cheplygina
%
% SEE ALSO
%   FLOYDTRANSFORM, MIL_RWKERNEL

function K= mil_spkernel(V1, V2, E1, E2, nodepar, edgepar, alpha)


if nargin<7
    alpha=0.5;
end



Knode=sqeucldistm(V1,V2);                %Get the node distances
Knode = exp(-Knode/nodepar);          %Convert to kernel values



K=0;  %Instead of computing a matrix and summing over the elements, in this case it's faster to compute the sum directly

nv1=size(V1,1);
nv2=size(V2,1);
beta=1-alpha;


%This looks horrible, but it practice n1, n2 or e will often be equal to 0,
%thus reducing the number of calculations.

for i=1:nv1
    for j=1:nv2
        n1 = Knode(i,j);
        if n1>0
           for k=i:nv1
               
               eik = E1(i,k);
               
               for l=j:nv2
                   n2 = Knode(k,l);
                   
                   if n2>0
                       edgeDif = abs(eik-E2(j,l));      %Edge distance
                       %e =  max(0, edgethr-edgeDif);    %Edge kernel
                       
                       e = exp(-edgeDif/edgepar);
                       

                       if e>0
                           if(i==k && j==l)
                               K=K+(((n1*n2)^alpha)*(e^beta));  %Add shortest path kernel for this path to total sum (over all paths)
                               
                           else
                               K=K+2*(((n1*n2)^alpha)*(e^beta));
                           end
                       end
                   end
               end
           end
            
        end
    end
end












