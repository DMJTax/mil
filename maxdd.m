%MAXDD The optimization of Diverse Density
%
%  [MAXcONCEPT,CONCEPTS] = MAXDD(SPOINTS,SCALES,BAGS,BAGI,EPOCHS,TOL)
%
% The core optimization function of maxDD_mil. See maxDD_mil.

function [maxConcept,concepts] = maxdd(spoints,scales,bags,bagI,epochs,tol)

% initialize some parameters and storage
num_start_points = size(spoints,1);
dim = size(spoints,2);
concepts = cell(num_start_points,2);
maxConcept{1} = [zeros(1,dim) ones(1,dim)];
maxConcept{2} = 0;

% make several runs, starting with another startingpoint spoint.
for i=1:num_start_points
	if num_start_points>1,
		mil_message(6,'%d/%d ',i,num_start_points);
	end
	xold = [spoints(i,:),scales];
	% compute the data likelihood and its derivative
	[fold g] = log_DD(xold,bags,bagI);
	p = -g;
	sumx = xold*xold';
	stpmax = 100*max(sqrt(sumx),2*dim); %upper bound on step size
	% now do an iterative line-search to find the global minimum
	for iter = 1:epochs(1)
		[xnew,fnew,check] = mil_lnsrch(xold,dim,fold,g,p,tol(3),stpmax,bags,bagI);
		% check if the step in space is still large enough:
		xi = xnew-xold;
		tst = max(abs(xi)./max(abs(xnew),1));
		if tst<tol(1)
			break
		end
		% check if the likelihood is changing sufficiently
		[dummy,g] = log_DD(xnew,bags,bagI);
		den = max(fnew,1);
		tst = max(abs(g).*max(abs(xnew),1))/den;
		if tst<tol(2)
			break;
		end
		% OK, store for the next step
		p = -g;
		xold = xnew;
		fold = fnew;
		sumx = xold*xold';
		stpmax = 100*max(sqrt(sumx),2*dim);
	end
	%iterations(i,1) = iter;
	[xnew,fret,iterations(i,2)] = mil_dfpmin(xnew,dim,tol(3),tol(4),epochs(2),bags,bagI);
	concepts{i,1} = xnew;
	concepts{i,2} = exp(-fret);

	if concepts{i,2}>maxConcept{2}
		maxConcept{1} = concepts{i,1};
		maxConcept{2} = concepts{i,2};
	end
end
