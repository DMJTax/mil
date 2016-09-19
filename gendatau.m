%GENDATAU Action Unit data
%
%     A = GENDATAU(AUNR,DATABASE)
%
% Define the Action Unit classification problem. There are two datasets
% defined: 
%  'ck':  Cohn-Kanade database
%  'im':  Imperial database (from Michel)
% These databases contain several trackings of facial feature points.
% 
function a = musk(aunr,dbase)
if nargin<2
	dbase = 'ck';
end
if nargin<1
	aunr = 1;
end

switch dbase
case 'ck'
	prload(fullfile(mildatapath,'mil_Dck.mat'));
case 'im'
	prload(fullfile(mildatapath,'mil_sessions_new'));
end

posclass = sprintf('au%02d',aunr);
a = changelablist(a,posclass);
a = genmil(a,strvcat('apex','offset','onset'));

a = setprior(a,[0.5 0.5]);
% finally define the name
a = setname(a,sprintf('AU%02d_%s',aunr,dbase));

return
