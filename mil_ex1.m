% MIL_EX1
%
% Example of the training and evaluation of MIL classifier: MILES. This
% classifier is compared to a combination of a bag-dissimilarity and a
% sparse logistic classifier

% generate an artificial MIL dataset:
a = gendatmilg([20 20]);
% split in train and test (note: bags are NOT split)
[x,z] = gendatmil(a,0.8);

% train miles:
w1 = miles(x,10,'r',1);
% test:
out = z*w1;
miles_auc = dd_auc(out*milroc)

% compare to a MIL proximity and sparse classifier:
u = milesproxm([],2)*sparseloglc([],0.1);
% train:
w2 = x*u;
% test:
miles_auc = dd_auc(z*w2*milroc)

