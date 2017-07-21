# Final-BtG-Codes-General-Version-

This repository contains the required MATLAB codes for the following research papers:

1. A.F.Taha, N.Gatsis, B. Dong, A.Pipri, Z.Li, "Buildings-to-Grid Integration Framework" submitted to IEEE Trans. on Smart Grids, submitted March 2017.

2. Z.Li, A.Pipri, B.Dong, N.Gatsis, A.F.Taha, N.Yu, "Modelling, Simulation and Control of Smart and Connected Communities" submitted to International Building Performance Simulation Association , Building Simulation Conference 2017.

If you are using any part of this material in your research, please cite the above references.

The scripts in this folder requires MATPOWER data and functions to be executed and it uses  CPLEX to solve optimiztion problems. Therefore, the user is requested to add MATPOWER folder into the MATLAB's current path and to download and install CPLEX optimization toolbox before using these codes.
There are three different scenarios that can be executed using these codes.  For more details please refer to the research paper [1] mentioned above.

These codes can be executed as given in the following steps. In addition to this, the grid network and building parameters can be changed as given in the section 'Changing the Simulation Parameters' below.

## For Execuing Scenario I:

Step 1- Open the file 'main_code_gonly_scenario1.m', select the desired IEEE case file from available options.

Step 2- Execute the above mentioned file to get the results for Scenario 1.


## For Executing Scenario II:

Step 1- Open file 'main_code_bonly.m', select the case file.

Step 2- Execute the code to get the optimal building inputs ready to be fed to the grid only MPC.

Step 3- Open file 'gonly_scenario2' and select the same case file as selected for step 1.

Step 4- Execute the above mentioned code to get the results for Scenario 2.


## For Execuing Scenario III (BtG-GMPC):

Step 1- Open the file 'main_code.m', select the IEEE case file to be simulated.

Step 2- Execute to get the results for Scenario III.


## Changing the Simulation Parameters:

### Building Parameters

There are two main input files which includes the external weather data (buildinginput1) and the reference building parameters (buildinginput2). These files can be changed as per the user's requirement. The format of these files is given below:

#### File name: buildinginput1.mat

1st column: 	internal heat gain in w/m2

2nd column: 	outdoor air temperature in degree C

3rd to 7th column: 	solar radiance for each building outside surface in w/m2

8th column: 	thermostat set point

9th column: 	test  


#### File name: buildinginput2.mat

1st column: 	Thermal resistances for north, south, east and west walls of the reference building (in J/m2)

2nd column: 	Base area for north, south, east and west walls; roof and; floor  of reference building (in m2)


### Grid Parameters

1. The generators, loads and connections can be added or removed from the standard case files given in the main folder (casexx.m). 

2. User can create their own case files with the format as given in the comments in standard case files.

3. Number of buildings in the simulation depends on the nodal power demand and the load sharing percentage of buildings. Power demand can be adjusted in the case files as mentioned above and building load sharing percentage can be changed in the functions 'start.m' and 'start_for_gonly_scenario2.m'.

4. The costs and limits to the BtG-MPC problem as mentioned in [1] can be changed in the function named 'costs_and_limits.m'.
