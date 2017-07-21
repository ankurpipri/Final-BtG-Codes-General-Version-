% A function to generation group of buildings according to PeakMw and Total
% expected number of buildings
% @Author(s): Bing Dong, Zhaoxuan Li
% @Date: April 18th, 2016
% @Contact: bing.dong@utsa.edu
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"


function [BLDGs,Pmisc, Phvac, Pbldg,tolACEnergy,Tzone,initials] = groupBLDG (peakMax,nBLDG)

% Input Building Parameters 
load('buildinginput1.mat');%;csvread('2.Predictionfile.csv');
input=buildinginput1;
input=input'; 
load('buildinginput2.mat');%csvread('3.Buildinginformation.csv');
building=buildinginput2;
Qinternal=input(1,:);
T=input(2,:);
IDIRW=input(3,:);
IDIRE=input(4,:);
IDIRN=input(5,:);
IDIRS=input(6,:);
IDIR=input(7,:);
Tset=input(8,:);

Pmisc = [];
Phvac = [];

% peakMax = 4*1000/5; % (in MW)
% % number of building estimated based on: 
% % peakMax(kW)/(0.005kW/ft^2)*(5000+200000)/2(ft^2)
% nBLDG = 2;

% generate random number of peakW
peakW = (2+(3-2).*rand(nBLDG,1))/1000;

luX = 15000*ones(nBLDG,1);
upX  = 200000*ones(nBLDG,1);
% f = ones(nBLDG,1);
C = eye(nBLDG);
Aeq = peakW';
beq = peakMax;
% d = zeros(nBLDG,1);
% ranft = randi([5000 200000], nBLDG, 1); 
ranft = randi([15000 200000], nBLDG, 1); 
% d = 100250*ones(nBLDG,1);
d = ranft;
% as close as possible to the randomly generated building ft, but
% constrained by total = peakMax
options=optimoptions('lsqlin','Algorithm','active-set','Display','off');
%options=mosek_options(options);
%[BLDGft,RESNORM,RESIDUAL,EXITFLAG] = lsqlin(C,d,[],[],Aeq,beq,luX,upX,[],options);
[BLDGft,RESNORM,RESIDUAL,EXITFLAG] = lsqlin(C,d,[],[],Aeq,beq,luX,upX,[],options);
%%%% If the solutioin is not feasible.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample for total square area of buildings between [50,000 ft^2 and 200,000 ft^2]
initials=[];
for n = 1: nBLDG
    
if EXITFLAG~=1
    
    ranAA = (3.5-1).*rand(1,1) + 4; % generate a ramdon number to different differnt building areas
    mfA = sqrt(BLDGft(n)/1000)*ranAA; 
else
    mfA = sqrt(BLDGft(n)/1000); 
end

mfA=2*mfA;
%disp(mfA)
rnw=building(1,1)*mfA;
north=building(1,2)*mfA;
rsw=building(2,1)*mfA;
south=building(2,2)*mfA;
rew=building(3,1)*mfA;
east=building(3,2)*mfA;
rww=building(4,1)*mfA;
west=building(4,2)*mfA;
floor=building(5,2)*mfA*mfA;
roof=building(6,2)*mfA*mfA;

% Radomly generat thermal capacitance and resistance: 

%ranC = 1/((10-5).*rand(1,1) + 5);
ranC=5*rand(1);
cSIP=1500*25*0.1651*ranC;%
cgypsum=1090*9.8*0.0127*ranC;
croof=1500*25*0.2667+cgypsum;
cwall=cSIP+cgypsum;
cfloor=0.15*2240*900*ranC;%900
csoil=cfloor;%100*1500*800*ranC;

%ranR = (2-1).*rand(1,1) + 1;
ranR=0.5+1*rand(1);
Rwin=1/5.9*ranR;
Rdoor=1/1.53*ranR;
RSIP=26*ranR;
Rgypsum=0.079*ranR;
rfloor=0.077*ranR;
rsoil=1/(1.3/1)*ranR;%100
Rsurf=1/8.29*ranR;

mf = [mfA,cSIP,cgypsum,croof,cwall,cfloor,csoil,Rwin,Rdoor,RSIP,Rgypsum,rfloor,rsoil,Rsurf];

% amplifier for HVAC (only 40% goes to HVAC)
mHVAC = peakW(n)*0.75*BLDGft(n); %(ratio between kW and 1 kW)

% Generate lighting and plugloads schedule (60% goes to lighting and plug)
% Schedule follows the pattern below: (6:00pm to 7:00am, 10% is on, The
% rest time 100% is on, according to DOE building referenc model) 
startt=7*12+randi(30)-randi(40);
midt=11*12+randi(30)-randi(40);
endt=288-startt-midt;
mLighting = BLDGft(n)*peakW(n)*0.2*[0.2*(0.5+1*rand(1))*ones(startt,1)', (0.5+1*rand(1))*ones(midt,1)', 0.2*(0.5+1*rand(1))*ones(endt,1)']; %(in kW)
mLighting=[mLighting mLighting mLighting mLighting mLighting mLighting mLighting mLighting];
Qinternal = mLighting*1*1000; 
%% Run Building Simulation With MPC
% tic;
% n
[AcPower, AcPower_NP, Tz,A,Bu, Bw, w,ini_cond]= SIP_SS_Simple1(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floor,roof,mHVAC,mf,nBLDG,n);
initials=[initials;ini_cond];
Tz=Tz(288+1:288*2);
% toc;
%Hourly load
tolEnergy=[];
tolACEnergy = [];
tolLgtEnergy = [];

% for i=1:24;
%     tolEnergy=[tolEnergy mean(AcPower(1+(i-1)*12:i*12))/1000+ mean(mLighting(1+(i-1)*12:i*12))];
%     tolACEnergy =[tolACEnergy mean(AcPower(1+(i-1)*12:i*12))];
%     tolLgtEnergy = [tolLgtEnergy mean(mLighting(1+(i-1)*12:i*12))];
% end
for i=24*12+1:24*12*2;
    tolACEnergy =[tolACEnergy AcPower(i)];
end


% figure;
% plot(AcPower/1000,'-.ob','LineWidth',2);
% title('AC Load (kW)','FontSize',16,'color','black');
% xlabel('Time (5min)','FontSize',16,'color','black');
% ylabel('kW','FontSize',16,'color','black');
% legend('AC load');
% 
% figure; 
% hold on
% plot(tolEnergy,'-.ob','LineWidth',2);
% plot(tolACEnergy,'LineWidth',2);
% plot(tolLgtEnergy, 'LineWidth',2);
% title('Total Building Energy Consumption (kWh)','FontSize',16,'color','black');
% xlabel('Time (Hourly)','FontSize',16,'color','black');
% ylabel('kWh','FontSize',16,'color','black');
% legend('TotalBLDG','totAC','tolLgt');

% figure;
% hold on
% plot(Tzone,'-.ob','LineWidth',2);
% plot((Tset-32)*(5/9),'LineWidth',2);
% hold off
% title('Zone Temperature Prediction','FontSize',16,'color','black');
% xlabel('Time (Hourly)','FontSize',16,'color','black');
% ylabel('C','FontSize',16,'color','black');
% legend('Zone Temp');
% toc

% Store matrix
BLDGs.A{n} = A;
BLDGs.Bu{n} = Bu;
BLDGs.Bw{n} = Bw;
BLDGs.w{n} = w(:,288+1:288*2);

Pmisc{n} = [5*mLighting(288+1:288*2)']; 
Phvac{n} = [AcPower(288+1:288*2)]/1000;
Pbldg{n} = AcPower(288+1:288*2)'/1000+5*mLighting(288+1:288*2);
Tzone{n} = Tz;
end

end