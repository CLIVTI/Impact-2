close all 
clear variables;

% value to be altered:
% 1. in function: SpecifySupply_Stcokholm_Gothenburg, change DiscomfortPeakRail etc. to make sure the discomfort is
% calculated according to the initial demand
% 2. in function: OptimizeSupply_ConstraintReformulation, change line 176, MinusWelfare to consider/not consider CS.
% 

% in function: SpecifySupply_Stcokholm_Gothenburg, we have reduced seat capacity from 278 to 278*0.65 
% in function: OptimizeSupply_ConstraintReformulation, max capacity 310 to 310*0.65

% addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
% current path: C:/Users/ChengxiL/VTI/IMPACT 1 - Dokument/Modellering/ImpactMatlabModel
DesicionVar={};
%% global input
% rail discomfort value.
CostScaleParameter=[0.01, 0.005639344];  % CostScaleParameter for different demand segments
% CostScaleParameter=[0.01, 0.01];  % CostScaleParameter for different demand segments
DCValue=[1.8, 1.8, 1.8,1.8];  % discomfort for DiscomfortPrivatePeakRail; DiscomfortPrivateOffpeakRail; DiscomfortBusinessPeakRail; DiscomfortBusinessOffpeakRail
SeatCapacity=[278,278];  % refer to seat capacity in peak and offpeak for comfort
MaxSeatCapacity=[278,278];  % refer to seat capacity in peak and offpeak
% specify RailDiscomfort variables
RailDiscomfort={};
RailDiscomfort.Varnames={'DiscomfortPrivatePeakRail','DiscomfortPrivateOffpeakRail','DiscomfortBusinessPeakRail','DiscomfortBusinessOffpeakRail'};
RailDiscomfort.DCValue=DCValue;
CSorPS='CS';
BanAvgift=[6957,6091]; % BanAvgift for every departure in peak and offpeak
%% run the model
% Model=SpecifySupply_Stcokholm_Gothenburg(CostScaleParameter,DCValue,SeatCapacity);
Model=SpecifySupply_unitest_1();
[DemandOutput,UtilityOutput,ConsumerSurplus]=CalculateDemandLogit(Model)

 