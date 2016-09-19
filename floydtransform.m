% FLOYDTRANSFORM   Transforms adjacency matrix into shortest path matrix
%
%       SP = FLOYDTRANSFORM(A) 
%
% INPUT
%   A     Adjaciency matrix
%
% OUTPUT
%   SP    Matrix containing the shortest path distance
%
% DESCRIPTION
% If there is a path between nodes i and j, SP_ij will contain the
% length of the shortest path.
%
% REFERENCE
% @article{floyd1962algorithm,
%  title={{Algorithm 97: shortest path}},
%  author={Floyd, R.W.},
%  journal={Communications of the ACM},
%  volume={5},
%  number={6},
%  pages={345},
%  issn={0001-0782},
%  year={1962},
%  publisher={ACM}
% }
%
% SEE ALSO
% milproxm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function SP = floydtransform(A)

N = size(A,1);       %number of nodes

SP = zeros(N,N);

for i=1:N
    for j=1:N
        if(i~=j && A(i,j) == 1)
            SP(i,j)=1;        %Simple version, can also use weights w(i,j)
        else
            if(i == j)
                SP(i,j)=0;
            else
                SP(i,j)=Inf;
            end
        end
    end
end

for k=1:N
    for i=1:N
        for j=1:N
                cost = SP(i,k)+SP(k,j);
                if(cost < SP(i,j))
                    SP(i,j)=cost;
                end
        end
    end
end

            



