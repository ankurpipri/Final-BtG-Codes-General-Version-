function [obj_bldg] = calculating_cost_bonly(N,Ng,Nb,hg,hb)
% Author: Ankur Pipri
% Date: 19th April 2017
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"

% This function calculates the objective functions separately for building
% part after solving the mpc for the whole simulation

global cost_n Result
for i=1:1:(size(Result.B_HVAC,2))-1
    c4(1,i)=(Result.B_HVAC(:,i))' * cost_n.lincost_ub(i,1)*ones(Nb,1);
end
obj_bldg=sum(c4);

end