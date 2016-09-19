%MIL_DFPMIN  Simulate the routine "dfpmin" in [1], which takes,
%     xold  - The starting point of dfpmin
%     n     - Dimension of the instance
%     tolx  - Convergence tolerance on delta x
%     gtol  - Convergence tolerance on gradient
%     itmax - Maximum allowed number of iterations
%     and returns,
%     xnew  - The ending point of dfpmin
%     fret  - The value of function at xnew
%     iter  - Number of iterations that were performed
%
%    For more details, see [1]
%    [1] Press W H, Teukolsky S A, Vetterling W T, Flannery B P. Numerical Recipes in C: the art of scientific computing. Cambrige University Press,  
%        New York, 2nd Edition, 1992

function [xnew,fret,iter]=dfpmin(xold,n,tolx,gtol,itmax,bags,baglabs)

      xnew=xold;
      %fp=neg_log_DD(xold(1:n),xold((n+1):2*n));   %Caculate staring function value
      %g=D_neg_log_DD(xold(1:n),xold((n+1):2*n));  %Caculate initial gradient
		[fp,g] = log_DD(xold,bags,baglabs);
      hessin=eye(2*n);   %Initialize the inverse Hessian to the unit matrix
      xi=-g;
      sum=xold*xold';
      stpmax=100*max(sqrt(sum),2*n);
      for its=1:itmax
          iter=its;
          [pnew,fret,check]=mil_lnsrch(xnew,n,fp,g,xi,tolx,stpmax,bags,baglabs);
          fp=fret;
          xi=pnew-xnew;   %Update the line direction
          xnew=pnew;      %Update the current pint
          test=max(abs(xi)./max(abs(xnew),1));         %Test for convergence on delta x
          if(test<tolx)
              return;
          end
          dg=g;    %Save the old gradient
          %g=D_neg_log_DD(xnew(1:n),xnew((n+1):2*n));  %Get the new gradient
			 [dummy,g] = log_DD(xnew,bags,baglabs);
          den=max(fret,1);  %Test for convergence on zero gradient
          test=max(abs(g).*max(abs(xnew),1))/den;
          if(test<gtol)
              return;
          end
          dg=g-dg;   %Compute difference of gradients
          hdg=hessin*dg';  %Compute difference times current matrix
          fac=dg*xi';       %Calculate dot products for the denominators
          fae=dg*hdg;
          sumdg=dg*dg';
          sumxi=xi*xi';
          if(fac>sqrt(3e-8*sumdg*sumxi))   %Skip update if fac not sufficiently positive
              fac=1/fac;
              fad=1/fae;
              dg=fac*xi-fad*hdg';   %The vector that makes BFGS different from DFP
              hessin=hessin+fac*(xi'*xi)-fad*(hdg*hdg')+fae*(g'*g);
          end
          xi=(-hessin*g')';
          
%          if(mod(its,50)==0)
%              disp(strcat('Dfpmin epochs:',num2str(its),'......'));
%          end
      end
      
          
          
          
