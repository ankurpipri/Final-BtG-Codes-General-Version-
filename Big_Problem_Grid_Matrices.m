function [E,Ag,A_ub,B_ug,B_bl,B_wg,PTDF,Gamma,Pi]=Big_Problem_Grid_Matrices(N,Ng)
% Author(s): Ankur Pipri, Nikolaos Gatsis, Ahmad F. Taha
% Date: 17th June 2017
% If you wish to use full or any part of this material in your research,
% you are requested to cite the following papers:
% 1. A.F. Taha, N. Gatsis, B. Dong, A. Pipri, Z. Li,"Buildings-to-Grid
% Integration Framework", IEEE Transanctions on Smart Grid March 2017, submitted
% 2. Z.Li; A.Pipri; B.Dong; N.Gatsis; A.F.Taha; N.Yu,"Modelling, Simulation and Control of Smart and Connected Communities"

% This function constructs the state-space matrices for the power network
% dynamics (LTI), Section III of our paper.
% Initializing and Getting network data 

% Obtaining parameters
M_D=[8.9304   3.0920  
  8.8462  3.6539      %These values are taken from 
 8.5269   3.4160      
 0 0  
  0 0  
 0 0  
  0 0 
  0 0  
 0 0];
M_D=M_D/100;
MM=M_D(:,1);
DD=M_D(:,2);

M=zeros(N,N);
D=zeros(N,N);

for i=1:1:N
M(i,i)=MM(i);
D(i,i)=DD(i);
end

L=[17.3611         0         0  -17.3611         0         0         0         0         0
         0   16.0000         0         0         0         0         0  -16.0000         0
         0         0   17.0648         0         0  -17.0648         0         0         0
  -17.3611         0         0   39.9954  -10.8696         0         0         0  -11.7647
         0         0         0  -10.8696   16.7519   -5.8824         0         0         0
         0         0  -17.0648         0   -5.8824   32.8678   -9.9206         0         0
         0         0         0         0         0   -9.9206   23.8095  -13.8889         0
         0  -16.0000         0         0         0         0  -13.8889   36.1001   -6.2112
         0         0         0  -11.7647         0         0         0   -6.2112   17.9759];
     
% E is 2N*2N matrix
E=[eye(N) zeros(N,N)       
   zeros(N,N) M];

% A is 2N*2N matrix
Ag=[zeros(N,N) eye(N);
    -L -D];

% Gamma is N*Ng incidence matrix (if generator is connected to bus)
Gamma=[eye(Ng)
       zeros(N-Ng,Ng)];
   
% B_mp is 2N*Ng matrix
B_ug=[zeros(N,Ng)
       Gamma];
   
% A_ug is 2N*Nb matrix
A_ub=[zeros(N,Nb)
       -Pi];
   
% B_bl is 2N*N matrix   
B_bl=[zeros(N,N);
       -eye(N)];

% B_misc is 2N*Nb matrix
B_misc=[zeros(N,Nb)
         -Pi];

B_wg=[B_bl,B_misc];
     
% PTDF matrix formation
PTDF=makePTDF(case9);
end