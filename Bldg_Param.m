% Test grouopBLDGS
function [Ag,Bug,Bwg,wg,ug,ub,umisc,g0,Tz,initials] = Bldg_Param(Nb,peak)
% Author: Zhaoxuan Li
% Date: 12th February 2017
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"

% peakMax = 4*1000/5; % (in MW)
% % number of building estimated based on: 
% % peakMax(kW)/(0.005kW/ft^2)*(5000+200000)/2(ft^2)
% nBLDG = 2;
% Approximately, 400kW peak = one building

nBLDG = Nb;
% Temporally programmed to incorporate into peak demand 
peakMax = nBLDG*peak/2; % (in kW)
[BLDGs,Pmisc, Phvac, Pbldg,ACenergy,Tzone,initials] = groupBLDG (peakMax,nBLDG); 
Ag=BLDGs.A;
Ag=cell2mat(Ag);
AA=[];
for k=1:2:2*Nb
    AA(k:k+1,k:k+1)=Ag(:,k:k+1);
end
Ag=AA;
% Tz=[];
% for k=1:Nb;
% Tz=[Tz Tzone'];
% end
Tz=[];
Tz=Tzone;
Tz=cell2mat(Tz');

Bug=BLDGs.Bu;
Bug=cell2mat(Bug);
BBug=[];
for i=1:2:2*Nb-1
    BBug(i:i+1,0.5*(i+1))=Bug(:,0.5*(i+1));
end
Bug=BBug;

Bwg=BLDGs.Bw;
Bwg=cell2mat(Bwg);
BBwg=[];
for i=1:2:2*Nb-1
    BBwg(i:i+1,1.5*i-0.5:1.5*i-0.5+2)=Bwg(:,1.5*i-0.5:1.5*i-0.5+2);
end
Bwg=BBwg;

wg=[];
wg=BLDGs.w;
wg=cell2mat(wg');

ug=[];
ug=cell2mat(Phvac);
ug=ug';

ub=[];
ub=Pbldg;
ub=cell2mat(ub');
% ub=ub';

umisc=[];
umisc=Pmisc;
umisc=cell2mat(umisc);
umisc=umisc';

g0=22*ones(2*Nb,1)+randn(2*Nb,1);
end