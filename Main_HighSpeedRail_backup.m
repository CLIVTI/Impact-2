close all 
clear variables;

addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
DesicionVar={};

Supply=SpecifySupply_HighSpeedRail();
Population=SpecifyPopulationSegment_HighSpeedRail();

DemandTestRun=CalculateDemandMNL(Supply,Population);
% calibrate comfort given mode share
TargetModeShare=[0.4,0.2,0.2,0.2]';

% make a function to calibrate comfort parameters
CalibrateInfo.Rail.AttractivenessRail=1;
CalibrateInfo.Bus.ASCBus=1;
CalibrateInfo.Air.ASCAir=1;
[Supply,CalibrationStatistics]=CalibrateMNLParameters(Supply,Population,CalibrateInfo,TargetModeShare);

% calculate Demand
Demand=CalculateDemandMNL(Supply,Population);

% calculate mode share
ModeShare=ApplyMNL(Supply,Population);
% define what variable values to update in which mode

% calculate elasticity of all supply variables
Elasticity=ElasticityMNL(Supply,Population);


% % an example to update attributes in Supply
% UpdateInfo.TimeCar=30;
% UpdateInfo.CostDriver=40;
% UpdatedSupply=UpdateSupply(Supply,UpdateInfo);


% demand supply interaction
% specify the road capacity and free flow car travel time.
FreeFlowCarTime=2;
RoadCapacity=inf;
VDF = @(Volume)FreeFlowCarTime.*(1+(Volume./RoadCapacity).^2);

CarTimeVarName='TimeCar';
BusTimeVarName='InVehBus';
IterDisplay=true;


CarCapacity.VDF=VDF;
CarCapacity.CarTimeVarName=CarTimeVarName;
% CarCapacity.BusTimeVarName=BusTimeVarName;
% [CapacitatedDemandMatrix_ValueIter,SupplyUpdated_ValueIter,TimeTrace_ValueIter]=CalculateCapacitatedDemand(Supply,Population,VDF,CarTimeVarName,IterDisplay);
[CapacitatedDemandMatrix_Optimization,SupplyUpdated_Optimization,TimeDiff_Optimization]=CalculateCapacitatedDemand_Optimization(Supply,Population,CarCapacity);
% optimize ticket price for rail
CostPerDeparture=10000;
DecisionVariable.Rail.CostRail=1;

OptimizationFlag=true;

[Welfare,OptimizedDemand,SupplyFinal]=OptimizeSupply(Supply,Population,CarCapacity,DecisionVariable,OptimizationFlag);
% plot(Welfare.PossibleCosts,Welfare.WelfareCurve)