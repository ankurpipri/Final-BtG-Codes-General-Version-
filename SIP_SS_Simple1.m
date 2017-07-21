% Created by Bing Dong 12/21/2015
% bing.dong@utsa.edu
% @Author(s): Bing Dong, Zhaoxuan Li
% @Date: April 18th, 2016
% @Contact: bing.dong@utsa.edu
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"

function [AcPower, AcPower_NP, Tz,A,Bu, Bw, w_all,ini_cond] = SIP_SS_Simple1(Qinternal,T,IDIRW,IDIRE,IDIRN,IDIRS,IDIR,Tset,rnw,north,rsw,south,rew,east,rww,west,floorer,roof,mHVAC,mf,nBLDG,o)

% global Anw
% global Anorth
% global Asw
% global Asouth
% global Aew
% global Aeast
% global Aww
% global Awest
% global Afloor
% global Aroof

Anorthwindow=rnw*north;
Anorth=north*(1-rnw);
Asouthwindow=rsw*south;
Asouth=south*(1-rsw);
Aeastwindow=rew*east;
Aeast=east*(1-rew);
Awestwindow=rww*west;
Awest=west*(1-rww);
Afloor=floorer;
Aroof=roof;

Qo1=0.01*Awest*(IDIRW);%0.4*0.1
Qo2=0.01*Aeast*(IDIRE);
Qo3=0.01*Anorth*(IDIRN);
Qo4=0.01*Asouth*(IDIRS);
Qo5=0.01*Aroof*(IDIR);
exteriorwindow=Anorthwindow*IDIRN+Asouthwindow*IDIRS+Aeastwindow*IDIRE+Awestwindow*IDIRW;
Qwin=0.01*exteriorwindow;
Qi1=0.025*Qwin;
Qi2=0.025*Qwin;
Qi3=0.025*Qwin;
Qi4=0.025*Qwin;
Qi5=0.2*Qwin;
Qi6=0.7*Qwin;

Q1=Qo1+Qi1;
Q2=Qo2+Qi2;
Q3=Qo3+Qi3;
Q4=Qo4+Qi4;
Q5=Qo5+Qi5;
Q6=Qi6;

%Main simulation
Tz=[];
Tw1=[];
Tzall=[];
Vroom=((6.096+0.0254)*14.6304-3.8576*(7.0104+0.1397))*2.4384+(0.9144+0.05715)*(14.6304*2)*(3.6576+0.2921)/2-(0.9144+0.05715)*3.6575*(7.0104+0.1397)/2;
AcPower_NP = ones(288,36);
Qhvac = zeros(288*7,1);
n = 1; % actual time in the day.
w_all = [];
ini_cond=[];
for k=1:288*2;% K: simualtion start time
    n = k;
    Tamb=T(1,n);
    Tse=71.6;
    %     disp('At step')
    %     k
%     load('initialT.mat');
%     if nBLDG==70;
%         tinit=initialT(1+(o-1)*2:2*o)';
%     elseif nBLDG==100;
%         tinit=initialT(140+1+(o-1)*2:140+2*o)';
%     elseif nBLDG==130;
%        tinit=initialT(340+1+(o-1)*2:340+2*o)';
%     end
    if k==1||k==1+288;
        initial =[24+rand(1) 22+rand(1)];
        if k==288+1;
           ini_cond=initial';
        end
        Qhvac(k) = 0;
    else
        initial=[Tw1(k-1) Tz(k-1)];
    end
    X0 = initial';
    Tg = 10;
    u=[0 -Qhvac(k)]';
    Qsol = Q1(n)+Q2(n)+Q3(n)+Q4(n)+Q5(n)+Q6(n);
    w= [Tamb Qsol Qinternal(n) ]';
    
    [Y,A,Bu, Bw, w] = SSNetwork_3s(X0,u,w,mf);

    %Tz=[Tz Y(2)];
    Tz=[Tz Y(2,end)];
    Tw1=[Tw1 Y(1,end)];
    mHVAC=1/300;
    %----------------------
    %disp(n)
    y=floor(k/288);
    max_l=800000;
    if (n<=85+(y)*288&&n>1+(y)*288)||(n<=288+(y)*288&&n>=240+(y)*288);
        if Tz(n-1)<=Tz(n);
            if Tz(n)>23.5;%23.88+1.72
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
%                 performancecurve=0.2*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                Qhvac(k+1) = (Tr-23.5)*(1/Bw(2,3))*mHVAC+Qhvac(k);
                if  Qhvac(k+1)> max_l*0.8
                    Qhvac(k+1)= max_l*0.8;
                end
                 if Qhvac(k+1) <0
                    Qhvac(k+1)  = 0; 
                end
            else
                Qhvac(k+1) = 0;
            end
        elseif Tz(n-1)>Tz(n)
            if Tz(n)>23.5;%23.88-2.22;
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                Qhvac(k+1) = (Tr-23.5)*(1/Bw(2,3))*mHVAC+Qhvac(k);
                if  Qhvac(k+1)> max_l*0.8
                    Qhvac(k+1)= max_l*0.8;
                    
                end
                 if Qhvac(k+1) <0
                    Qhvac(k+1)  = 0; 
                end
            else
                Qhvac(k+1) = 0;
            end
        else
            Qhvac(k+1) = 0;
        end
        %         else
        %         if Tz(n)>22+0.5
        %             initial=Y(end,1:2);
        %             %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
        %             Tr=Tz(n);
        %             performancecurve=10.5*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
        %                    Qhvac(k+1) = performancecurve*mHVAC;
        %         else
        %             Qhvac(k+1) = 0;
        %         end
        % Day time 
    elseif n>85+(y)*288&&n<240+(y)*288;
        if Tz(n-1)<=Tz(n)
            if Tz(n)>21.5
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                %                 performancecurve=0.6*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
%                 performancecurve=(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                %                  Qhvac(k+1) = performancecurve*mHVAC;
                Qhvac(k+1) = (Tr-21.5)*(1/Bw(2,3))*mHVAC+Qhvac(k);
                if  Qhvac(k+1)> max_l*0.8
                    Qhvac(k+1)= max_l*0.8;
                end
                
                if Qhvac(k+1) <0
                    Qhvac(k+1)  = 0; 
                end
            else
               Qhvac(k+1)  = 0;  
            end
        elseif Tz(n-1)>Tz(n)
            if Tz(n)>21.5
                %Network(tt,[initial Tamb Q1(n) Q2(n) Q3(n) Q4(n) Q5(n) Q6(n) -5*Qhvac(n) Qinternal(n)]);
                Tr=Tz(n);
                %                 performancecurve=0.6*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
%                 performancecurve=(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
                %                 Qhvac(k+1) = performancecurve*mHVAC;
                Qhvac(k+1) = (Tr-21.5)*(1/Bw(2,3))*mHVAC+Qhvac(k);
                if  Qhvac(k+1)> max_l*0.8
                    Qhvac(k+1)= max_l*0.8;
                end
                if Qhvac(k+1) <0
                    Qhvac(k+1)  = 0; 
                end
            else
                    Qhvac(k+1)  = 0; 
            end
        else
            %             Qhvac(k+1) = 0.3*(a+b*Tamb+c*(Tamb^2)+d*Tr+e*(Tr^2)+f*Tamb*Tr);
            Qhvac(k+1) = (Tr-21.5)*(1/Bw(2,3))*mHVAC+Qhvac(k);
            if  Qhvac(k+1)> max_l*0.4
                Qhvac(k+1)= max_l*0.4;
            end
            if Qhvac(k+1) <0
                    Qhvac(k+1)  = 0; 
            end
        end
    else
                Tr=Tz(n);
                Qhvac(k+1) = (Tr-21.5)*(1/Bw(2,3))*mHVAC+Qhvac(k);
                if  Qhvac(k+1)> max_l*0.8
                    Qhvac(k+1)= max_l*0.8;
                end
                if Qhvac(k+1) <0
                    Qhvac(k+1)  = 0; 
                end
    end
w_all  = [w_all, w];
AcPower = Qhvac;

end


