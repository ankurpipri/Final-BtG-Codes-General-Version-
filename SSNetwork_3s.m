% @Author(s): Zhaoxuan Li
% @Date: April 18th, 2016
% @Contact: bing.dong@utsa.edu
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"
function [y, A,Bu, Bw, w] = SSNetwork_3s(x,u,w,mfA)

y=zeros(2,1);%two states of building

mf = mfA(1);%random amplifer for building size
cSIP=mfA(2);cgypsum=mfA(3);croof=mfA(4);cwall=mfA(5);cfloor=mfA(6);csoil=mfA(7);Rwin=mfA(8);
Rdoor=mfA(9);RSIP=mfA(10);Rgypsum=mfA(11);rfloor=mfA(12);rsoil=mfA(13);Rsurf=mfA(14);

Anorthwindow=1.2192*(0.9144+0.047625)*2+0.9144*0.6096*3+0.9144*1.2192*2;Anorthdoor=(1.8288+0.254)*(0.9144+0.0508);
Anorth=2.4384*(7.3152+0.1651)+(7.0104+0.1397)*(3.3528+0.05715)-Anorthwindow-Anorthdoor;
Asouthwindow=1.2192*0.9144+3*1.2192*0.6096+0.6096*(0.6096+0.1524);Asouthdoor=(1.8288+0.254)*(0.6096+0.1524);
Asouth=(2.4384+0.2413)*14.6304-Asouthwindow-Asouthdoor;
Aeastwindow=1.2192*0.9144;Aeastdoor=(1.8288+0.254)*(0.9144+0.0508);
Aeast=(3.6576+0.1397)*(2.4384+0.2413)-((1.2192+0.1397)*(4.572+0.2286))/2-((0.9144+0.2032)*(3.9624+0.0762))/2-Aeastwindow-Aeastdoor;
Awestwindow=0.6096*(0.3048+0.1524)+1.2192*(0.3048+0.1524);
Awest=(3.6576+0.1397)*(2.4384+0.2413)-((1.2192+0.1397)*(4.572+0.2286))/2-((0.9144+0.2032)*(3.9624+0.0762))/2-Awestwindow;
Afloor=(6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397);
Aroof=(6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397);

Anorthwindow=mf*Anorthwindow;Anorthdoor=mf*Anorthdoor;Anorth=Anorth*mf;
Asouthwindow=Asouthwindow*mf;Asouthdoor=Asouthdoor*mf;Asouth=Asouth*mf;
Aeastwindow=Aeastwindow*mf;Aeastdoor=Aeastdoor*mf;Aeast=Aeast*mf;
Awestwindow=Awestwindow*mf;Awest=Awest*mf;
Afloor=Afloor*mf;
Aroof=Aroof*mf;

%Each wall capacity
c1=Aeast*cwall;c2=Awest*cwall;c3=Asouth*cwall;c4=Anorth*cwall;
c5=Aroof*croof*(17)^0.5/4;%Caculate roof capacity with an angel
c6=Afloor*(cfloor+csoil);
csurface=(c1+c2+c3+c4+c5+c6);

%Caculatin of resistance
Rwall=RSIP+Rgypsum;
Rwall1=1/(1/(Rwall/Aeast)+1/(Rwin/Aeastwindow)+1/(Rdoor/Aeastdoor));%Resistance for east wall
Rwall2=1/(1/(Rwall/Awest)+1/(Rwin/Awestwindow));%R for west wall
Rwall3=1/(1/(Rwall/Anorth)+1/(Rwin/Anorthwindow)+1/(Rdoor/Anorthdoor));%R for north wall
Rwall4=1/(1/(Rwall/Asouth)+1/(Rwin/Asouthwindow)+1/(Rdoor/Asouthwindow));%R for south wall
Rroof=rfloor/(Aroof*(17)^0.5/4);%R for roof
Rfloor=(rfloor+rsoil)/Afloor;%R for floor
Rsurface=1/(1/Rwall1+1/Rwall2+1/Rwall3+1/Rwall4+1/Rroof);
Rhouse11=Rsurf/(Aeast+Awest+Anorth+Asouth+Aroof)+Rsurface/2;
Rhouse12=Rsurf/(Aeast+Awest+Anorth+Asouth+Aroof)+Rsurface/2;

Vroom=mf/8*100*((6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397))*2.4384+(0.9144+0.05715)*(14.6304*2)*(3.6576+0.2921)/2-(0.9144+0.05715)*3.6575*(7.0104+0.1397)/2;
densityofair=1.225;Cair=1005;
mroom=Vroom*densityofair;
c7=5*mroom*Cair;%need to esitimate internal C. Here give a factor 10

R1 = Rhouse11;
R2 = Rhouse12;
C = csurface;
CZone  = c7; 

A=[ -1/C*(1/R1 + 1/R2) 1/(C*R1);
    1/(R1*CZone) -1/CZone*(1/R1 + 1/Rwin)];
Bu=[0;1/CZone];
Bw=[1/(R2*C)  1/C 0;
   1/(Rwin*CZone) 0 1/CZone];
% For discete-time system
% u = u(2);
% for i=1:300;
% y=A*x + Bu*u+Bw*w;
% x=y;
% end
% Solve using ODE 15
tspan = 0:1:300;
y0 = x;
u = u(2);
% %load('sysbuild.mat');
%load('sys.mat');
[Ag,Bug,Bwg] = Buildings_Gear_Matricesforbuildingonly( 300,1,1,A,Bu,Bw );
y=y0;
y=Ag*y + Bug*u+Bwg*w;
%[t, y] = ode15s(@(t,y)bldgss(t,y,A,Bu,Bw,u,w), tspan, y0); 
%y=y';
end
