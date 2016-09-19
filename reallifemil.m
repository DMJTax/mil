%REALLIFEMIL Load MIL dataset
%
%     [X,Z] = REALLIFEMIL(DSET)
%
% The datasets should be available in raw format, in the directory that
% is defined in the script mildatapath.m
%
%  nr   description               tr.bags  te.bags  inst    dim
%--------------------------------------------------------------
% 101. Musk 1                     47/45      -/-     476    166
% 102. Musk 2                     39/63      -/-    6598    166
% 103. Artificial Gaussian        10/10      -/-   +-150      2
% 104. Artificial Maron           10/10      -/-   -1000      2
% 105. Surrey Cathedral            5/3476    -/-   96869     33
% 106. Artificial Concept         10/10      -/-   +-150      2
% 107. Artificial Difficult       10/40      -/-     350      2
% 108. Artificial Rotated         30/30      -/-    1355      2
% 109. Artificial Widened         30/30      -/-    1320      2
% 110. Corel African             100/1900    -/-    7947      9
% 111. Corel Beach               100/1900    -/-    7947      9
% 112. Corel Historical          100/1900    -/-    7947      9
% 113. Corel Buses               100/1900    -/-    7947      9
% 114. Corel Dinosaurs           100/1900    -/-    7947      9
% 115. Corel Elephants           100/1900    -/-    7947      9
% 116. Corel Flowers             100/1900    -/-    7947      9
% 117. Corel Horses              100/1900    -/-    7947      9
% 118. Corel Mountains           100/1900    -/-    7947      9
% 119. Corel Food                100/1900    -/-    7947      9
% 120. Corel Dogs                100/1900    -/-    7947      9
% 121. Corel Lizards             100/1900    -/-    7947      9
% 122. Corel Fashion             100/1900    -/-    7947      9
% 123. Corel Sunset              100/1900    -/-    7947      9
% 124. Corel Cars                100/1900    -/-    7947      9
% 125. Corel Waterfalls          100/1900    -/-    7947      9
% 126. Corel Antique             100/1900    -/-    7947      9
% 127. Corel Battleships         100/1900    -/-    7947      9
% 128. Corel Skiing              100/1900    -/-    7947      9
% 129. Corel Desserts            100/1900    -/-    7947      9
% 130. SIVAL AjaxOrange           60/1440    -/-   47414     30
% 131. SIVAL Apple                60/1440    -/-   47414     30
% 132. SIVAL Banana               60/1440    -/-   47414     30
% 133. SIVAL BlueScrunge          60/1440    -/-   47414     30
% 134. SIVAL CandleWithHolder     60/1440    -/-   47414     30
% 135. SIVAL CardboardBox         60/1440    -/-   47414     30
% 136. SIVAL CheckeredScarf       60/1440    -/-   47414     30
% 137. SIVAL CokeCan              60/1440    -/-   47414     30
% 138. SIVAL DataMiningBook       60/1440    -/-   47414     30
% 139. SIVAL DirtyRunningShoe     60/1440    -/-   47414     30
% 140. SIVAL DirtyWorkGloves      60/1440    -/-   47414     30
% 141. SIVAL FabricSoftenerBox    60/1440    -/-   47414     30
% 142. SIVAL FeltFlowerRug        60/1440    -/-   47414     30
% 143. SIVAL GlazedWoodPot        60/1440    -/-   47414     30
% 144. SIVAL GoldMedal            60/1440    -/-   47414     30
% 145. SIVAL GreenTeaBox          60/1440    -/-   47414     30
% 146. SIVAL JuliesPot            60/1440    -/-   47414     30
% 147. SIVAL LargeSpoon           60/1440    -/-   47414     30
% 148. SIVAL RapBook              60/1440    -/-   47414     30
% 149. SIVAL SmileyFaceDoll       60/1440    -/-   47414     30
% 150. SIVAL SpriteCan            60/1440    -/-   47414     30
% 151. SIVAL StripedNotebook      60/1440    -/-   47414     30
% 152. SIVAL TranslucentBowl      60/1440    -/-   47414     30
% 153. SIVAL WD40Can              60/1440    -/-   47414     30
% 154. SIVAL WoodRollingPin       60/1440    -/-   47414     30
% 155. Web recommendation user 1  17/58     4/34   2212    5863
% 156. Web recommendation user 2  18/57     3/35   2212    6519
% 157. Web recommendation user 3  14/61     7/31   2212    6306
% 158. Web recommendation user 4  55/20    33/5    2291    6059
% 159. Web recommendation user 5  61/14    26/12   2546    6407
% 160. Web recommendation user 6  59/16    29/9    2462    6417
% 161. Web recommendation user 7  39/36    15/23   2400    6450
% 162. Web recommendation user 8  35/40    20/18   2183    5999
% 163. Web recommendation user 9    /        /                 
% 164. Newsgroup alt.atheism      50/50     -/-    5443     200
% 165. Newsgroup comp.graphics    49/51     -/-    3094     200
% 166. comp.os.ms-windows.misc    50/50     -/-    5175     200
% 167. comp.sys.ibm.pc.hardware   49/51     -/-    4827     200
% 168. comp.sys.mac.hardware      50/50     -/-    4473     200
% 169. comp.windows.x             49/51     -/-    3110     200
% 170. misc.forsale               50/50     -/-    5306     200
% 171. rec.autos                  50/50     -/-    3458     200
% 172. rec.motorcycles            50/50     -/-    4730     200
% 173. rec.sport.baseball         50/50     -/-    3358     200
% 174. rec.sport.hockey           50/50     -/-    1982     200
% 175. sci.crypt                  50/50     -/-    4284     200
% 176. sci.electronics            47/53     -/-    3192     200
% 177. sci.med                    50/50     -/-    3045     200
% 178. sci.space                  50/50     -/-    3655     200
% 179. soc.religion.christian     50/50     -/-    4677     200
% 180. talk.politics.guns         50/50     -/-    3558     200
% 181. talk.politics.mideast      50/50     -/-    3376     200
% 182. talk.politics.misc         50/50     -/-    4788     200
% 183. talk.religion.misc         49/51     -/-    4606     200
% 201-300. COIL100       between 108-1301   -/-   48004      32
% 301. Fox                        100/100   -/-    1302     230 
% 302. Tiger                      100/100   -/-    1220     230 
% 303. Elephant                   100/100   -/-    1391     230 
% 304. TREC9 (pretest) 1          200/200   -/-    3224   66552 (31 non-zero)
% 305. TREC9 (pretest) 2          200/200   -/-    3344   66153 (31)
% 306. TREC9 (pretest) 3          200/200   -/-    3246   66144 (31)
% 307. TREC9 (pretest) 4          200/200   -/-    3391   67085 (32)
% 308. TREC9 (pretest) 7          200/200   -/-    3365   66823 (31)
% 309. TREC9 (pretest) 9          200/200   -/-    3300   66627 (33)
% 310. TREC9 (pretest) 10         200/200   -/-    3453   66082 (32)
% 311. Harddrive, pos = normal    178/191   -/-    68411     61 (or 59, 2 features might be meta-data)
% 312. Harddrive, pos = failure   191/178   -/-    68411     61 (or 59, 2 features might be meta-data)
% 313. Trx protein family         25/168    -/-    26611      8  
% 314. Mutagenesis easy           125/63    -/-    10486      7 
% 315. Mutagenesis hard           13/29     -/-     2132      7
% 316. Brown Creeper              197/351   -/-    10232     38 
% 317. Winter Wren                109/439   -/-    10232     38 
% 318. Pacific slope Flycatcher   165/383   -/-    10232     38 
% 319. Red-breasted Nuthatch      82/466    -/-    10232     38 
% 320. Dark-eyed Junco            20/528    -/-    10232     38 
% 321. Olive-sided Flycatcher     90/458    -/-    10232     38 
% 322. Hermit Thrush              15/533    -/-    10232     38 
% 323. Chestnut-backed Chickadee  117/431   -/-    10232     38 
% 324. Varied Thrush              89/459    -/-    10232     38 
% 325. Hermit Warbler             63/485    -/-    10232     38 
% 326. Swainsons Thrush           79/469    -/-    10232     38 
% 327. Hammonds Flycatcher        103/445   -/-    10232     38 
% 328. Western Tanager            46/502    -/-    10232     38 
% 329. Biocreative Component      359/359  64/2348     13129/23765      200
% 330. Biocreative Function       385/385   58/4414    13498/42038     200
% 331. Biocreative Process         620/620   137/10341   21306/97111    200
% 332. UCSB breast cancer          26/32      -/-    2002          708 
% 333. Messidor retinopathy          654/546         -/-     12352    687


function [x,z] = reallifemil(dset,par)

if nargin<2
    par=0;
end


z = [];
switch dset
case 101
	x = gendatmusk(1);
case 102
	x = gendatmusk(2);
case 103
	x = gendatmilg([50 50]);
case 104
	x = gendatmilm([50 50], 1, [10 10; 10 10]);
case 105
	x = gendatsurrey;
case 106
   x = gendatmilc([10 10]);
case 107
   x = gendatmild([10 40]);
case 108
   x = gendatmilr;
case 109
   x = gendatmilw;
case {110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129}
	x = gendatcorel(dset-110);
case 130
	x = gendatsival('AjaxOrange');
case 131
	x = gendatsival('Apple');
case 132
	x = gendatsival('Banana');
case 133
	x = gendatsival('BlueScrunge');
case 134
	x = gendatsival('CandleWithHolder');
case 135
	x = gendatsival('CardboardBox');
case 136
	x = gendatsival('CheckeredScarf');
case 137
	x = gendatsival('CokeCan');
case 138
	x = gendatsival('DataMiningBook');
case 139
	x = gendatsival('DirtyRunningShoe');
case 140
	x = gendatsival('DirtyWorkGloves');
case 141
	x = gendatsival('FabricSoftenerBox');
case 142
	x = gendatsival('FeltFlowerRug');
case 143
	x = gendatsival('GlazedWoodPot');
case 144
	x = gendatsival('GoldMedal');
case 145
	x = gendatsival('GreenTeaBox');
case 146
	x = gendatsival('JuliesPot');
case 147
	x = gendatsival('LargeSpoon');
case 148
	x = gendatsival('RapBook');
case 149
	x = gendatsival('SmileyFaceDoll');
case 150
	x = gendatsival('SpriteCan');
case 151
	x = gendatsival('StripedNotebook');
case 152
	x = gendatsival('TranslucentBowl');
case 153
	x = gendatsival('WD40Can');
case 154
	x = gendatsival('WoodRollingPin');
case num2cell(155:163)
	[x,z] = gendatweb(dset-154);
case num2cell(164:183)
	x = gendatZhoutext(dset-163,par);
case num2cell(201:300)
	prload(fullfile(mildatapath,'coil100mil'));
	clname = sprintf('obj%d',dset-200);
	x = positive_class(a,clname);
	x = setname(x,[getname(x),clname]);
	x = setprior(x,getprior(x,0));
case 301
    x = gendatandrews('Fox');
case 302
    x = gendatandrews('Tiger');
case 303
    x = gendatandrews('Elephant');
case {304, 305, 306, 307, 308, 309, 310}
    trecnums = [1 2 3 4 7 9 10];
    x = gendattrec(trecnums(dset - 303));
    
case {311, 312}
    x = gendatdrive(dset-311);
case 313
    x = gendatprotein();
case 314
    x = gendatmutagen('easy');
case 315
    x = gendatmutagen('hard');
case num2cell(316:328)
    x = gendatbirds(dset-315);
    case 329
        [x,z]=gendatbiocreative('component');
    case 330
        [x,z]=gendatbiocreative('function');
    case 331
        [x,z]=gendatbiocreative('process');
        
    case 332
        x = gendatbreastucsb;
    case 333
        x = gendatmessidor;
        
    
otherwise
	error('Dataset %d is not defined.',dset);
end

% fix the class priors??
x = setprior(x,getprior(x,0));
if ~isempty(z)
	z = setprior(z,getprior(z,0));
end


