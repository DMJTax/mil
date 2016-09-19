%GENDATPROTEIN Thioredoxin-fold protein identification.
%
%     A = GENDATPROTEIN
%
% OUPUT
%   A      MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem Trx Protein. The data is obtained from here:
% http://cse.unl.edu/~qtao/datasets/mil_dataset__Trx_protein.html
%
% Veronika's (who is not an expert in proteins) summary of the problem:
%  Thioredoxin-fold (Trx) is a protein superfamily that is important for
%  understanding redox processes in cells. The similarity between
%  sequences of different families in this superfamily is low, so it is
%  difficult to identify new families by just modelling the primary
%  sequence. However, it is possible to identify new families by
%  examining secondary structure, such as the presence of certain
%  patterns (called motifs) in the sequence.
% 
% A bag is a protein sequence, split up into sliding window profiles
% (instances). Each profile is represented by 8 features: 7 chemical/molecular
% properties, and 1 feature with alignment information. 
% 
% A positive bag is a bag in the Trx family.
%
% REFERENCE
% The data is first used in a MIL setting here:
% @inproceedings{tao2004svm,
%  title={SVM-based generalized multiple-instance learning via approximate box counting},
%  author={Tao, Q. and Scott, S. and Vinodchandran, NV and Osugi, T.T.},
%  booktitle={Proceedings of the twenty-first international conference on Machine learning},
%  pages={101},
%  year={2004},
%  organization={ACM}
% }
%
% Some results on this dataset can be found in 
% @inproceedings{ray2005supervised,
%   title={Supervised versus multiple instance learning: An empirical comparison},
%   author={Ray, S. and Craven, M.},
%   booktitle={Proceedings of the 22nd international conference on Machine learning},
%   pages={697--704},
%   year={2005},
%   organization={ACM}
% }
%
% SEE ALSO
% mildatapath, genmil
 
function x = gendatprotein

fid = fopen(fullfile(mildatapath,'protein/trx.db'));

numfeat = 8;    %8 attributes, this is defined in specification file

featlab = {
'GES hydropathy index'
'Kyte-Doolittle index'
'Solubility'
'PI'
'Polarity'
'Molecular weight'
'Alpha helix index'
'Position'};

tline = fgetl(fid);

mildata = [];
millab = [];
milbagid = [];

i=1;
while ischar(tline) 
    data = str2num(tline);
            
    %Get bag label 
    baglab = data(1);
     
    %Number of instances in this bag    
    numinst = data(2);
    
    %Instance features
    data = data(3:end);
    data1 = reshape(data', numfeat, numinst);
    data = data1';
    
    %Add to dataset / labels
    mildata = [mildata; data];
    millab = [millab; repmat(baglab, numinst, 1)]; %Instances inherit labels of bag (to use with 'presence' combining rule in MIL toolbox) 
    milbagid = [milbagid; repmat(i, numinst,1)]; %Record from which bag the instance is
  
    tline = fgetl(fid);
    i=i+1;
end
fclose(fid);

strlab = cell(size(millab,1),1);
for j=1:size(millab,1)
    if(millab(j) == 1)
        strlab{j} = 'positive';
    else
        strlab{j} = 'negative';
    end
end


x = genmil(mildata, strlab, milbagid, 'presence');
x = setfeatlab(x, featlab);
x = setname(x,'Protein');

