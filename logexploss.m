% [L,dL] = logexploss(w,x,y,A)
%
% The asymmetric Logistic-Exponential loss, used to optimize the
% precision for a linear classifier. W encodes the weights of the linear
% classifier, X,Y and the data and labels (+1 or -1), and A is the
% trade-off value between the exponential loss and the logistic loss.

function [L,dL] = logexploss(w,x,y,A)

N = size(x,1);

Ip = find(y==+1);
fp = x(Ip,:)*w;
lp = 1./(1+exp(fp));
dlp = bsxfun(@times,-lp./(1+exp(-fp)),x(Ip,:));

In = find(y==-1);
fn = x(In,:)*w;
ln = exp(A*fn)/2;
dln = bsxfun(@times,A*ln,x(In,:));

L = (sum(lp)+sum(ln))/N;
dL = (sum(dlp)+sum(dln))'/N;
