function [Ag,Bug,Bwg] = Buildings_Gear_Matricesforbuildingonly( h,gk,Nb,A_b,B_ub,B_wb )
% Author: Ankur Pipri
% Date: 25th April 2017
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"

% This function creates matrices to represent the discretised system of Building Dynamics via Gear's method 
beta0=0;                         % Gear's variable
alphaisum=0;                     % Gear's variable
alphai=[];                       % This wil be a matrix for higher gear orders: matrix order will be (gk,Tp)
for i=1:1:gk
    beta0=beta0 + (1/i);
end
beta0=1/beta0;
for i=1:1:gk
    for j=i:1:gk
        alphaisum=alphaisum+(1/j)*(nchoosek(j,i));
    end
    alphai=((-1)^(i+1))*beta0*alphaisum;
    alphaisum=0;
end
Ahat=(eye(2*Nb)-(h*beta0*A_b))\eye(2*Nb);   % State Space Matrix for discretised system
Ag=alphai*Ahat;
Bug=h*beta0*Ahat*B_ub;
Bwg=h*beta0*Ahat*B_wb;

end