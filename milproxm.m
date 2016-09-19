%MILPROXM MIL proximity mapping
%
%    W = MILPROXM(A,KTYPE,KPAR, INSTPROXM);
%
% INPUT
%   A        MIL dataset
%   KTYPE    Kernel/proximity type (default = 'h')
%   KPAR     Kernel parameter (default = [])
%   INSTPROXM
%
% OUTPUT
%   W        MIL proximity mapping
%
% DESCRIPTION
% Definition of a proximity mapping between bags in a Multi-instance
% Learning problem using proximity KTYPE with parameter KPAR. The
% dataset A has to be MIL-dataset.
%
% The proximity is defined by the type KTYPE (and potentially its
% parameter KPAR):
%   'minmin'       | 'min':Minimum of minimum distances between inst. 
%   'summin'       | 'sm': Sum of minimum distances between inst. 
%   'meanmin'      | 'mm': Mean of minimum distances between inst. 
%   'meanmean'     | 'mean': Mean of mean distances between inst. 
%   'mahalanobis'  | 'm':  Mahalanobis distance between bags
%   'hausdorff'    | 'h':  (maximum) Hausdorff distance between bags
%   'emd'          | 'e':  Earth mover's distance (requires emd_mex !)
%   'linass'       | 'l':  Linear Assignment distance
%   'miRBF'        | 'r':  MI-kernel by Gartner,Flach,Kowalczyk,Smola,
%              basically just summing the pairwise instance kernels
%              (here we use the RBF by default)
%   'mmdiscr'      | 'mmd': Maximum mean discrepancy, from Gretton,
%              Borgwardt, Rasch, Schoelkopf and Smola
%   'miGraph'      | 'g':  miGraph kernel. This requires two additional
%              parameters in KPAR: KPAR[1] indicates the threshold on
%              the maximim distance between instances (in order to
%              allow an edge between the two instances), KPAR[2]
%              indicates the gamma=1/sigma^2 in the RBF kernel between
%              instances.
%   'rwk'         | 'rw':  Random Walk graph kernel. KPAR[1] is defined as
%              in miGraph. KPAR[2] indicates gamma in the RBF kernel
%              between nodes. KPAR[3] indicates lambda in infinite sum over
%              walks (0<lambda<1). 
% 
%   'spk'         | 'sp':  Shortest Path graph kernel. KPAR[1] is defined
%               as in miGraph. KPAR[2] and KPAR[3] indicate gamma parameters in the RBF
%               kernels between nodes and between edges. KPAR[4] indicates the
%               trade-off between nodes and edges.
%
% SEE ALSO
% milkernel

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%function W = milproxm(A,ktype,kpar)
function W = milproxm(varargin)

argin= shiftargin(varargin,'char');
argin = setdefaults(argin,[],'h',[]);

if mapping_task(argin,'definition')
   [A,ktype,kpar] = deal(argin{:});
   W = define_mapping(argin,'untrained',proximity_name(ktype));
	W = setbatch(W,0);  %NEVER use batches!!
   
elseif mapping_task(argin,'training')
   [A,ktype,kpar] = deal(argin{:});
	if ~hasmilbags(A)
		error('This mapping requires a MIL set with bags.');
	end
	[m,k] = size(A);
	[W.bags,W.labs,bagid] = getbags(A);
	if isempty(W.labs)
		W.labs = bagid;
	end
	switch ktype
	case {'miGraph' 'g'}
		bags = getbags(A);
		nra = length(bags);
		w = cell(nra,1);
		for i=1:nra
			w{i} = (sqeucldistm(bags{i},bags{i})<kpar{1}*kpar{1});
		end
		% then compute the kernel of bags to themselves:
		for i=1:nra
			Z(i) = sqrt(mil_graphkernel(bags{i},bags{i},w{i},w{i},kpar{2}));
		end
		W.w = w;
		W.Z = Z;
	case {'miRBF' 'r'}
		bags = getbags(A);
		nra = length(bags);
		Z = zeros(nra,1);
      if isempty(kpar) %DXD hidden feature...
         kpar = sqrt(size(A,2));
      end
		% the normalization per bag:
		for i=1:nra
			e = exp(-sqeucldistm(bags{i},bags{i})/(kpar{1}*kpar{1}));
			Z(i) = sum(e(:));
		end
		W.Z = Z;
            
	 case {'rwk' 'rw'}
			bags = getbags(A);
			nra = length(bags);
			w = cell(nra,1);
			
            edgeThreshold = kpar{1}*kpar{1};
			%Build graph just like in miGraph
			for i=1:nra
				 w{i} = (sqeucldistm(bags{i},bags{i})<edgeThreshold);
			end
			% Compute the kernel of bags to themselves:
			for i=1:nra
				 Z(i) = mil_rwkernel(bags{i},bags{i},w{i},w{i},kpar{2},kpar{3});
			end
			W.w = w;
			W.Z = Z;

    case {'spk' 'sp'}
			bags = getbags(A);
			nra = length(bags);
			w = cell(nra,1);
			
            edgeThreshold = kpar{1}*kpar{1};
			%Build graph just like in miGraph
			for i=1:nra
				 w{i} = (sqeucldistm(bags{i},bags{i})<edgeThreshold);

                 %Transform to shortest path representation
                 w{i} = floydtransform(w{i});
                
			end
			% Compute the kernel of bags to themselves:
			for i=1:nra
				 Z(i) = mil_spkernel(bags{i},bags{i},w{i},w{i},kpar{2}, kpar{3}, kpar{4});
			end
			W.w = w;
			W.Z = Z;      
	case {'mmdiscr' 'mmd'}
		bags = getbags(A);
		nra = length(bags);
		for i=1:nra
			mil_message(5,'%d/%d ',i,nra);
			e = exp(-sqeucldistm(bags{i},bags{i})/(kpar{1}*kpar{1}));
			Eyy(i) = mean(e(:));
		end
		W.Eyy = Eyy;
%   otherwise
%      disp(sprintf('training of %s is not defined.\n',ktype));
	end
	W.ktype = ktype;
	W.kpar = kpar;
	W = prmapping(mfilename,'trained',W,W.labs,...
			getfeatsize(A),size(W.labs,1));
	W = setname(W,proximity_name(ktype));
	W = setbatch(W,0);
elseif mapping_task(argin,'trained execution')
   [A,ktype,kpar] = deal(argin{:});
	% we have to apply the mapping:
	W = getdata(ktype);
	kpar = W.kpar;
	kname = getname(ktype);
	% check:
	if ~hasmilbags(A)
		A = genmil(A);
		%error('This mapping is defined for MIL datasets.');
	end
	% setup parameters and storage:
	[Abags,Alab,bagid] = getbags(A);
	if isempty(Alab)
		Alab = bagid;
	end
	nra = length(Abags);
	nrb = length(W.bags);

	switch W.ktype
        
    case {'minmin' 'min'}

		K = zeros(nra,nrb);
		for i=1:nra
			for j=1:nrb
				d = sqeucldistm(Abags{i},W.bags{j});
				K(i,j) = min(d(:));
			end
		end    
        
    case {'summin' 'sm'}

		K = zeros(nra,nrb);
		for i=1:nra
			for j=1:nrb
				if isempty(W.kpar)
					d = sqeucldistm(Abags{i},W.bags{j});
				else
					d = +(Abags{i}*milproxm([],W.bags{j},W.kpar{1},W.kpar{2}));
				end
				d1 = min(d,[],1); d2 = min(d,[],2);
				K(i,j) = 0.5*(sum(d1)+sum(d2));
			end
		end    
        
    case {'meanmin' 'mm'}

		K = zeros(nra,nrb);
		for i=1:nra
			mil_message(6,'(row %d/%d)',i,nra);
			for j=1:nrb
				if isempty(W.kpar)
					d = sqeucldistm(Abags{i},W.bags{j});
				else
					d = +(Abags{i}*dd_proxm(W.bags{j},W.kpar{1},W.kpar{2}));
				end
				d1 = min(d,[],1); d2 = min(d,[],2);
				K(i,j) = 0.5*(mean(d1)+mean(d2));
                %K(j,i) = K(i,j);
			end
        end    
        
        
    case {'meanmean' 'mean'}

		K = zeros(nra,nrb);
		for i=1:nra
			mil_message(6,'(row %d/%d)',i,nra);
			for j=1:nrb
				d = sqeucldistm(Abags{i},W.bags{j});
				K(i,j) = mean(d(:));
			end
		end    
        
        
        
	case {'hausdorff' 'h'}

		K = zeros(nra,nrb);
		for i=1:nra
			for j=1:nrb
				if isempty(W.kpar)
					% keep is simle and fast:
					d = sqeucldistm(Abags{i},W.bags{j});
				else
					d = +(Abags{i}*dd_proxm([],W.bags{j},W.kpar{1},W.kpar{2}));
				end
				d1 = min(d,[],1); d2 = min(d,[],2);
				K(i,j) = max(max(d1),max(d2));
			end
		end
	case {'mahalanobis' 'm'}

		K = zeros(nra,nrb);
		for i=1:nra
			mil_message(6,'(row %d/%d)',i,nra);
			Ca = cov(Abags{i});
			Ma = mean(Abags{i});
			for j=1:nrb
				Cb = cov(W.bags{j});
				Mb = mean(W.bags{j});
				K(i,j) = (Ma-Mb)*pinv(Ca+Cb)*(Ma-Mb)'/2;
			end
		end
		mil_message(6,'.\n');
	case {'emd' 'e'}
		if ~exist('emd_mex')
			error('I need emd_mex (from http://www.mathworks.com/matlabcentral/fileexchange/12936-emd-earth-movers-distance-mex-interface)');
		end

		K = zeros(nra,nrb);
		for i=1:nra
			mil_message(6,'(row %d/%d) ',i,nra);
			ni = size(Abags{i},1);
			for j=1:nrb
				nj = size(W.bags{j},1);
				d = distm(W.bags{j},Abags{i});
				K(i,j) = emd_mex(ones(1,nj)/nj,ones(1,ni)/ni,+d);
			end
		end
		mil_message(6,'\n');

	case {'miGraph' 'g'}
		% first make graph from each bag by thresholding the Eucl. dist.
		% between the instances
		d_thr = kpar{1}*kpar{1};
		w = cell(nra,1);
		for i=1:nra
			%w{i} = exp(-sqeucldistm(Abags{i},Abags{i})*kpar(1));
			w{i} = (sqeucldistm(Abags{i},Abags{i})<d_thr);
			% then compute the kernel of bags to themselves:
			Z(i) = sqrt(mil_graphkernel(Abags{i},Abags{i},w{i},w{i},kpar{2}));
		end
		% now compute the (normalized) pairwise values:
		for i=1:nra
			for j=1:nrb
				K(i,j) = mil_graphkernel(Abags{i},W.bags{j},w{i},W.w{j},kpar{2})/...
				Z(i)/W.Z(j);
			end
        end
        
       
   case {'rwk' 'rw'}
		d_thr = kpar{1}*kpar{1};
		w = cell(nra,1);
		for i=1:nra
			w{i} = (sqeucldistm(Abags{i},Abags{i})<d_thr);
		end

		for i=1:nra
			for j=1:nrb
				K(i,j) = mil_rwkernel(Abags{i},W.bags{j},w{i},W.w{j},kpar{2}, kpar{3});
            end
        end     
  case {'spk' 'sp'}
		d_thr = kpar{1}*kpar{1};
		w = cell(nra,1);
		for i=1:nra
			w{i} = (sqeucldistm(Abags{i},Abags{i})<d_thr);
		end

		for i=1:nra
			for j=1:nrb
				K(i,j) = mil_spkernel(Abags{i},W.bags{j},w{i},W.w{j},kpar{2}, kpar{3},kpar{4});
            end
        end  
        
	case {'mmdiscr' 'mmd'}
		Exx = zeros(nra,1);
		K = zeros(nra,nrb);
		for i=1:nra
			e = exp(-sqeucldistm(Abags{i},Abags{i})/(W.kpar{1}*W.kpar{1}));
			Exx(i) = mean(e(:));
			for j=1:nrb
				mil_message(5,'(%d,%d) ',i,j);
				e = exp(-sqeucldistm(Abags{i},W.bags{j})/(W.kpar{1}*W.kpar{1}));
				K(i,j) = Exx(i) - 2*mean(e(:)) + W.Eyy(j);
			end
		end    
        
	case {'linass' 'l'}

		K = zeros(nra,nrb);
		%DXD: is it actually symmetric??
		for i=1:nra
			mil_message(6,'(row %d of %d)',i,nra);
			for j=i:nrb
				mil_message(7,' %d ',j);
				% distance matrix between instances:
				D = distm(W.bags{j},Abags{i});
				if size(D,1)<size(D,2)
					[I,K(i,j)] = munkres(D);
				else
					[I,K(i,j)] = munkres(D');
				end
			end
		end
		mil_message(6,'\n');

	case {'miRBF' 'r'}

      if isempty(kpar) %DXD hidden feature... 
         kpar = {sqrt(size(Abags{1},2))};
      end
		K = zeros(nra,nrb);
		Z = zeros(nra,1);
		for i=1:nra
			e = exp(-sqeucldistm(Abags{i},Abags{i})/(kpar{1}*kpar{1}));
			Z(i) = sum(e(:));
			for j=1:nrb
				e = exp(-sqeucldistm(W.bags{j},Abags{i})/(kpar{1}*kpar{1}));
				K(i,j) = sum(e(:))/sqrt(Z(i)*W.Z(j));   %VC: bug fix by Marc Law, this used to say sum(e(:))/sqrt(Z(i)*W.Z(i)); which didn't work for ccases when nrb>nra
			end
		end

	otherwise
		error('I do not know proximity type %s.',W.ktype);
	end
	% finally:
	W = prdataset(K,Alab,'featlab',W.labs);
	W = setident(W,bagid,'milbag');
	W = setname(W,getname(A));
	W = setprior(W,getprior(A,0));
end

return

function kname = proximity_name(ktype)

switch ktype
     case {'minmin' 'min'}         
         kname = 'minmin.K';
     case {'summin' 'sm'}         
         kname = 'summin.K';
     case {'meanmin' 'mm'}         
         kname = 'meanmin.K';
     case {'meanmean' 'mean'}         
         kname = 'meanmean.K';
     case {'mahalanobis' 'm'}
         kname = 'mahal.K';
     case {'hausdorff' 'h'}
         kname = 'haussd.K';
     case {'emd' 'e'}
         kname = 'emd.K';
     case {'miGraph' 'g'}
         kname = 'graphK';
     case {'linass' 'l'}
         kname = 'linass.K';
     case {'rwk' 'rw'}
         kname = 'randomwalk.k';
     case {'spk' 'sp'}
         kname = 'shortestpath.k';
     case {'mmdiscr' 'mmd'}
         kname = 'MMD';
     case {'miRBF' 'r'}
         kname = 'MIkernel';
     otherwise
         error(['Proximity type ' ktype ' unknown']);
end

return
