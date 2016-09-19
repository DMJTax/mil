%GENDATBIOCREATIVE Biocreative text data MIL problem
%
%  [X Z] = GENDATBIOCREATIVE(NR)
%
%
% INPUT
%   NR     Dataset type (1=component, 2=function, 3=process)
%
% OUTPUT
%   X, Z      MIL datasets (train and test).
%
% DESCRIPTION
% Define the MIL problem of biological text categorization. An interesting property is perhaps is that the training sets are
% balanced, and rather small, but the test sets are larger and very
% imbalanced.
% 
% From the README file:
% The task is to decide whether a given <protein, document> pair should be annotated
% with some Gene Ontology (GO) code. As input, we have paragraphs of documents, 
% each paragraph described by a feature vector. Features used are word occurrence
% frequencies and some statistics about the nature of the protein-GO code interaction
% for each paragraph. Each document corresponds to a bag and each paragraph 
% to an instance in a bag. The hypothesis is that a bag should be annotated
% with a GO code iff there exists a paragraph in it that supports this annotation. 
% Conversely, if %no paragraph supports such an annotation, the document should not be
% annotated. 
%
%
%  Source: http://engr.case.edu/ray_soumya/MIPage.html
% Converted from C4.5 to Matlab format with https://github.com/garydoranjr/c45_parser
%
%
% S. Ray & M. Craven (2005). Supervised versus Multiple-Instance Learning: An Empirical Comparison.  Appears in the Proceedings of the
% 22nd International Conference on Machine Learning, Bonn, Germany.

% S. Ray & M. Craven (2005).  Learning Statistical Models for Annotating
% Proteins with Function Information using Biomedical Text.  Appears in
% BMC Bioinformatics, Vol 6 (Suppl 1).
%
%
%


function [x, z] = gendatbirds(targetstring)


allnames = {'component', 'function', 'process'};
if isempty(strmatch(targetstring,allnames))
    error('Class %s is not present in the Biocreative dataset.',targetstring);
end

if nargin<1
    targetstring = 'component';
end

mildata = [];
millab = [];
twoclasslab = [];
milbagid = [];
milinstid = [];


%Get features and instance labels for TRAIN SET
xdata = struct2cell(load(fullfile(mildatapath,['biocreative/' targetstring '_train.mat'])));
xdata = xdata{1};
    
mildata = xdata(:,3:end-1);
millab = xdata(:,end);
milbagid = xdata(:,1); %Record from which bag the instance is
milinstid = xdata(:,2);
        

strlab = cell(size(millab,1),1);
for j=1:size(millab,1)
    if(millab(j) == 1)
        strlab{j} = 'positive';
    else
        strlab{j} = 'negative';
    end
end

x = genmil(mildata, strlab, milbagid, 'presence');
x = addlabels(x,milinstid,'inst_ids');
x = changelablist(x);
x = setname(x,sprintf(['Biocreative ' targetstring]));

clear xdata;

%TEST SET
zdata = struct2cell(load(fullfile(mildatapath,['biocreative/' targetstring '_test.mat'])));
zdata = zdata{1};
    
mildata = zdata(:,3:end-1);
millab = zdata(:,end);
milbagid = zdata(:,1); %Record from which bag the instance is
milinstid = zdata(:,2);
        
strlab = cell(size(millab,1),1);
for j=1:size(millab,1)
    if(millab(j) == 1)
        strlab{j} = 'positive';
    else
        strlab{j} = 'negative';
    end
end
z = genmil(mildata, strlab, milbagid, 'presence');
z = addlabels(z,milinstid,'inst_ids');
z = changelablist(z);
z = setname(z,sprintf(['Biocreative ' targetstring]));

%If only one output argument is required, append train and test data
%together
if nargout == 1
    x = [x;z];
end