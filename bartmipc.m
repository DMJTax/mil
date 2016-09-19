%BARTMIPC Dissimilarity-based MIL with clusters as prototypes
%
%    W = BARTMIPC(A,K,BAGDIST,W_U)
%
% INPUT
%    A         MIL-dataset
%    K         Number of clusters (default = 5)
%    BAGDIST   Bag distance 'maxmin', 'meanmin' (default) or 'minmin'
%    W_U       Supervised learner to be used in the dissimilarity space
%
% OUTPUT
%    W         MIL-classifier using distance to a prototype
%
% DESCRIPTION
% Clusters training bags into clusters (using Hausdorff type distance), selects cluster centres as
% prototypes, and uses another Hausdroff type distance to these centres as
% the dissimilarity representation

%Implementation from Multi-instance clustering with application to
%multi-instance prediction by Min-Ling Zhang and Zhi-Hua Zhou (Applied
%Intelligence (2009) 31:47-68)


%function w = bartmipc(a,k,bagdist,w_u)
function W = bartmipc(varargin)

argin= shiftargin(varargin,'char');
argin = setdefaults(argin,[],5,'meanmin',scalem([],'variance')*libsvc);

if mapping_task(argin,'definition')
   [A,k,bagdist,w_u]  = deal(argin{:});
   W = define_mapping(argin,'untrained','bartmip');
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [A,k,bagdist,w_u] = deal(argin{:});
   
   
	if ~hasmilbags(A)
		error('This mapping requires a MIL set with bags.');
    end
	
    [bags labs bagid] = getbags(A);
    
    %Distance matrix between bags
    D = A*milproxm(A,bagdist,{'d',1});
    
    
    [clustlab, centerix] = kcentres(D,k,1);
        
    
    %Train the classifier only on distances to cluster centres
    w_t = D(:, centerix)*w_u;
 
    
    %Reduce the MIL dataset so it only contains the bags which are cluster
    %centres
        
    centerbagid = bagid(centerix',:);
    instix = ismember(A.ident.milbag, centerbagid,'rows');
    B = genmil(A(instix,:), A.labels(instix,:), A.ident.milbag(instix,:));
    

    %Store things
    W.w_t = w_t;
    W.centerbags = B;
        
	W = prmapping(mfilename,'trained',W);
	W = setname(W,'bartmip-%s',getname(w_u));
	W = setbatch(W,0);
    
    
    
elseif mapping_task(argin,'trained execution')
   
   
    
    [A,k,bagdist,w_u] = deal(argin{:});
	% we have to apply the mapping:
	W = getdata(k);
	
    B = W.centerbags;
    w_t = W.w_t;
    
    %Calculate the dissimilarity representation to the prototypes
    D = A*milproxm(B, bagdist,{'d',1});
    
    %And apply the trained classifier on this representation
    W = D*w_t;
   
    
end




