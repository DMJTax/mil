%Multi-instance Learning Toolbox
%Version 1.2.2  26-Apr-2017
%
%Dataset operations
%------------------
%genmil           Generate MIL dataset from data and labels
%gendatmil        Subsample bags from a MIL dataset
%mil2ocset        Convert MIL to OCC dataset
%oc2milset        Convert OCC labels to MIL labels
%ismilset         True if dataset has MIL bags and labels
%hasmilbags       True if MIL bags are defined
%ismillabeled     True if dataset has MIL labels
%mildisp          Display MIL dataset
%scattermil       Scatterplot of a MIL dataset
%splitseq2mil     Generate MIL dataset from sequence data
%createmildatafile Create a datafile suitable for genmil
%positive_class   Define classes the positive class
%milrandomize     Randomize the order of the bags in a MIL set
%milmerge         Merge two MIL datasets into one
%subsample_bags   Randomly subsample instances from bags
%
%unmil            Remove the MIL bags
%milfile2set      Convert MIL datafile to dataset
%setmilinfo       Define combining rule etc for MIL datasets
%getmilinfo       Get combining rule etc for MIL datasets
%rmmilinfo        Remove extra MIL information from datasets
%
%MIL Classifiers
%---------------
%apr_mil          Iterative discrim. APR MIL
%maxDD_mil        Maximum Diverse Density MIL
%emdd_mil         EM Diverse Density MIL
%density_mil      Density-based MIL
%citation_mil     Citation kNN MIL
%misvm            Multiple-Instance Support Vector Machine
%miles            Multi-instance Learning via Embedded Instance Selection
%milboostc        MILBoost
%sv_mil           Support vector MIL (requiring a bag-similarity measure)
%incsvddmil       Incremental SVDD MIL
%inc_spec_mil     Incrementally specializing MIL
%simple_mil       Generate MIL mapping from standard mapping
%spec_mil         Specializing MIL
%clust_mil        Clustering MIL
%dir_mil          Directional MIL
%pposterior_mil   p-Posterior mixture kernel for MIL
%
%Bag combinations and representations
%------------------------------------
%milcombine       Combine instance prob. to get the bag prob.
%bowm             Bag of Words representation
%milvector        Transform MIL bags into feature vector
%milproxm         MIL proximity mapping
%milkernel        Define distances between bags (uses milproxm.m)
%milesproxm       Compute MIL bags to instance similarities
%
%Evaluation
%----------
%milmap           Official function to map MIL datasets
%milcrossval      MIL crossvalidation (using bags etc)
%milfnfp          False negative and false positive
%milroc           MIL ROC curve (using positive-negative)
%
%Standard datasets
%-----------------
%reallifemil      Load one of the standard MIL datasets
%gendatmilc       Generate artificial concept MIL problem
%gendatmild       Generate artificial difficult MIL problem
%gendatmilg       Generate artificial Gaussian MIL problem
%gendatmilm       Generate artificial Maron MIL problem
%gendatmilr       Generate artificial rotated distribution MIL problem
%gendatmilw       Generate artificial width distribution MIL problem
%gendatandrews    Generate Fox, Tiger, Elephant data used by S. Andrews
%gendatdrive      Generate harddrive failure dataset
%gendatmusk       Generate MUSK dataset
%gendatmutagen    Generate Mutagenesis datasets
%gendattrec       Generate TREC (text retrieval) datasets
%gendatprotein    Generate TrX protein dataset
%gendatsurrey     Generate Surrey image database retrieval

%gendatweb        Generate Webpage dataset
%gendatcorel      Generate Corel dataset
%gendatsival      Generate SIVAL dataset
%gendatZhoutext   Generate Zhou mailinggroups text dataset
%
%Support functions
%-----------------
%mil_version      Current version of MIL toolbox, with upgrade
%                 possibility
%mil_message      Give a message
%getbags          Extract the bags from a MIL set
%getpositivebags  Extract positive (and neg.) bags from a MIL set
%getbagid         Extract bag identifiers from MIL dataset
%bagsizes         Extract size of each bag
%labelset         Combine labels to get the label from one bag
%bag2instlab      Copy the bag labels to the instance labels
%ispositive       True if label/object is 'positive'
%find_positive    Indicator vector for positive label
%genmillabels     Simplify generation of MIL labels
%consistentmillab Relabel all instances according to their bag label
%bags2mil         Combine bags to a MIL dataset
%milmissingvalues Treat the dataset with inf/nans
%apr_allpos       APR MIL, using only positive instances
%log_DD           Compute log probabilities for Diverse Density
%bagprob          Compute bag probabilities for Diverse Density
%getwnames        Get classifier names from a cell-array of mappings
%boosting_err     Error function in boosting MIL
%loglc_weighted   Weighted Logistic classifier
%munkres          Munkres (Hungarian) Algorithm for Linear Assignment
%
%
%Examples
%--------
%mil_ex1          MIL example
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
