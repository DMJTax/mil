a = gendatmilg([5 5]);
b = a;
b(3:10,:)=[];
c = addlabels(a,ones(size(a,1),1),'nothing');
c = changelablist(c,'nothing');

ismilset(a);
hasmilbags(a);
ismillabeled(a);
ispositive(a);
ispositive(getlab(a));
[x,lab,bagid,xI] = getbags(a);
a7 = a(xI{7},:);
nlab = [1; 1; 0; 0; 0; 0];
labelset(nlab,'first');
labelset(nlab,'majority');
labelset(nlab,'presence');
labelset(nlab,1);
labelset(nlab,3);
labelset(nlab,0.5);

[bp,bn,Ip,In]=getpositivebags(b);

ismilset(c);
ispositive(c);
[x,lab,bagid,xI] = getbags(c);

figure(1);clf;scatterd(a);
ww = ldc(a);plotc(ww,'r');
w = apr_mil(a,'presence',0.1,0.99,0.0001,0.1);
a*w*testc
plotc(w);

w = maxDD_mil(a,'presence');
a*w*testc
plotc(w,'g');

w = clust_mil(a,1,4);
a*w*testc
plotc(w,'g');

w = citation_mil(a,1,1,3);
a*w*testc
plotc(w,'g');

w1 = simple_mil(a,'presence',ldc);
a*w1*testc
w2 = a*(ldc*milcombine([],'presence'));
a*w2*testc
a*w1*testc
