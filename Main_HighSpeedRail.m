close all 
clear variables;

addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
DesicionVar={};


Supply=SpecifySupply_HighSpeedRail();
Population=SpecifyPopulationSegment_HighSpeedRail();
% an example to update attributes in Supply



% UpdateSupplyInfo.InVehBus=40;
% UpdateSupplyInfo.TimeCar=30;
% UpdateSupplyInfo.Women=30;
% AttributeGet=GetSupply(Supply,UpdateSupplyInfo);

% PopulationUpdateInfo.TotalPopulation.Women=1;
% PopulationUpdateInfo.TotalPopulation.InVehBus=1;
% AttributeGetPopulation=GetPopulation(Population,PopulationUpdateInfo);

% UppdatePopulationInfo.TotalPopulation.Women=0.5;
% [UpdatedSupply,UppdatedPopulation]=UpdateSupplyPopulation(Supply,Population,UpdateSupplyInfo,UppdatePopulationInfo);
% [UpdatedSupply,UppdatedPopulation]=UpdateSupplyPopulation(Supply,Population,UpdateSupplyInfo);
% calibrate comfort given mode share
TargetModeShare=[0.4,0.2,0.2,0.2]';

% make a function to calibrate comfort parameters
CalibrateParameters={};
CalibrateParameters.Rail.AttractivenessRail=1;
CalibrateParameters.Bus.ASCBus=1;
CalibrateParameters.Air.ASCAir=1;
[Supply,CalibrationStatistics]=CalibrateLogitParameters(Supply,Population,CalibrateParameters,TargetModeShare);

% calculate Demand
Demand=CalculateDemandLogit(Supply,Population);

% calculate mode share
ModeShare=ApplyLogit(Supply,Population);
% define what variable values to update in which mode

% calculate elasticity of all supply variables
Elasticity=ElasticityLogit(Supply,Population);





% demand supply interaction
% specify the road capacity and free flow car travel time.
FreeFlowCarTime=2;  % make sure this number is realistic
RoadCapacity=3.0e+5;
VDF = @(Volume)FreeFlowCarTime.*(1+(Volume./RoadCapacity).^2);

CarTimeVarName='TimeCar';
BusTimeVarName='InVehBus';
IterDisplay=true;


CarCapacity.VDF=VDF;
CarCapacity.CarTimeVarName=CarTimeVarName;
CarCapacity.BusTimeVarName=BusTimeVarName;
% [CapacitatedDemandMatrix_ValueIter,SupplyUpdated_ValueIter,TimeTrace_ValueIter]=CalculateCapacitatedDemand(Supply,Population,VDF,CarTimeVarName,IterDisplay);
[CapacitatedDemandMatrix_Optimization,SupplyUpdated_Optimization,TimeDiff_Optimization]=CalculateCapacitatedDemand(Supply,Population,CarCapacity);
% optimize ticket price for rail
DecisionVariable.CostRail=1;

OptimizationFlag=true;

[Welfare,OptimizedDemand,SupplyFinal]=OptimizeSupply(Supply,Population,CarCapacity,DecisionVariable,OptimizationFlag);
PriceFinal=GetSupply(SupplyFinal,DecisionVariable);
% plot(Welfare.PossibleCosts,Welfare.WelfareCurve)