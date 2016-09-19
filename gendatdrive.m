%GENDATDRIVE Harddrive dataset
%
%     A = GENDATDRIVE(CLASSNR)
%
% INPUT
%   CLASSNR    Positive class (default = 0)
%
% OUTPUT
%   A          MIL dataset
%
% DESCRIPTION
% Define the multi-instance learning problem Harddrive. POSCLASS indicates
% what harddrives are labelled as positive: 0 for non-failed drives, 1 for
% failed drives.
% 
% There are 369 harddrives, 178 good and 191 with failures.  Each
% harddrive is represented by several frames (up to 300); in each frame
% several performance-monitoring attributes are recorded. 
% 
% Records with a low value for Hours (feature 1) may be not reliable.
%
% For this application, a low false-positive rate is more important (not
% the whole ROC curve is relevant). 
% 
% REFERENCE
% J. F. Murray, G. F. Hughes, K. Kreutz-Delgado
%     "Comparison of machine learning methods for predicting failures in hard
%     drives"
%     Journal of Machine Learning Research, vol 6, 2005.
%    (Available online at http://jmlr.org)
%
% SEE ALSO
% mildatapath
function a = gendatdrive(posclass)

    if nargin<1
        posclass = 0;
    end
    
   prload(fullfile(mildatapath,'harddrive/harddrive_raw.mat'));
   
   
   bagids = x(:,1);     %This is the number of the hard drive?
   instids = x(:,2);    %This is the number of the frame per hard drive
   feats = x(:,3:63);   
   
   %Features 3 and 4 may be meta-data, not sure :(
   
   featlab =  {'Hours';  'HoursBeforeFail'; 'Temp1'; 'Temp2 '; 'Temp3 '; 'Temp4'; 'FlyHeight1'; 'FlyHeight2'; 'FlyHeight3'; 'FlyHeight4';
            ' GList1'; 'PList'; 'Servo1'; 'Servo2'; 'Servo3'; 'CSS'; 'Servo4'; 'Servo5'; 'Servo6'; 'Reads'; 'Writes'; 'ReadError1'; 'ReadError2';
'ReadError3'; 'ReadError4'; 'ReadError5'; 'ReadError6'; 'ReadError7'; 'ReadError8'; 'ReadError9'; 'ReadError10'; 'ReadError11'; 'ReadError12';
'ReadError13'; 'ReadError14'; 'ReadError15'; 'ReadError16'; 'FlyHeight5'; 'FlyHeight6'; 'FlyHeight7'; 'FlyHeight8'; 'FlyHeight9'; 'FlyHeight10';
'FlyHeight11'; 'FlyHeight12'; 'FlyHeight13'; 'FlyHeight14'; 'FlyHeight15'; 'FlyHeight16'; 'Temp5'; 'Temp6'; 'WriteError'; 'ReadError18';
'ReadError19'; 'Servo7'; 'Servo8'; 'ReadError20'; 'GList2'; 'GList3'; 'Servo9'; 'Servo10'};
   
   
   
   labs = x(:,64);      %Failure or no failure
   
   newlabs = cell(length(labs),1);
   
   for i=1:length(labs)
    
       if(labs(i) == posclass)
           newlabs{i} = 'positive';  
       else
           newlabs{i} = 'negative';
       end
   end
    
    
   a = genmil(feats,newlabs,bagids,'presence');
   a = setfeatlab(a, featlab);
   if (posclass==0)
      a = setname(a,'Harddrive (positive=non-failed)');
   else
      a = setname(a,'Harddrive (positive=failed)');
   end

return
