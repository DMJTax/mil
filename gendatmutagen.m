%GENDATMUTAGEN Mutagenesis datasets
%
%     A = GENDATMUTAGEN(DIFF)
%
% INPUT
%   DIFF      Difficulty of dataset (default = 'easy')
%
% OUTPUT
%   A         MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem Mutagenesis, a drug
% activity prediction problem.  DIFF indicates the difficulty of the
% dataset: "easy" or "hard". "Easy" seems to be the original version of
% the dataset, which might be not challenging enough, hence the "hard"
% version.
% 
% REFERENCE
% @inproceedings{srinivasan1995comparing,
%  title={Comparing the use of background knowledge by inductive logic programming systems},
%  author={Srinivasan, A. and Muggleton, S. and King, RD}
% }
% This dataset has been converted to a MIL problem in ARFF format by Dr. Frank
% Eibe of http://www.cs.waikato.ac.nz/~ml/
%
% SEE ALSO
% mildatapath

function a = gendatmutagen(diff)

    if nargin<1
        diff = 'easy';
    end
    
    if ~strmatch(diff, {'easy', 'hard'})
        error('Please choose either "easy" or "hard" (without quotes) as the dataset type');
    end
    
   prload(fullfile(mildatapath,['mutagenesis/mutagenesis_' diff '_raw.mat']));
   
   
   bagids = x(:,1);     %This is the number of the bag
   feats = x(:,2:8);   
   
   
   
   featlab =  {'element1',               %categorical                        {br,c,cl,f,h,i,n,o,s}
                'quanta1',               %categorical?                       {1,3,8,10,14,16,19,21,22,25,26,27,28,29,31,32,34,35,36,38,40,41,42,45,49,50,51,52,72,92,93,94,95,194,195,230,232}
                'charge1',               %numeric
                'bondtype',              %categorical?                       {1,2,3,4,5,7}   
                'element2',              %categorical                        Same as element1 
                'quanta2',               %categorical?                       Same als quanta1 
                'charge2'               %numeric
                };
   
   labs = x(:,9);      %Label of the bag
   
 

   
   newlabs = genmillabels(labs,1);
      
    
   a = genmil(feats,newlabs,bagids,'presence');
   a = setfeatlab(a, featlab);
   a = setname(a,['Mutagenesis ' diff]);

return
