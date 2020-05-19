close all 
clear variables;

addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
DesicionVar={};

Supply=SpecifySupply_Metro();
Population=SpecifyPopulationSegment_Metro();
% Supply=SpecifySupply_Regional();
% Population=SpecifyPopulationSegment_Regional();
% an example to update attributes in Supply



UpdateSupplyInfo.InVehMetro=40;
AttributeGet=GetSupply(Supply,UpdateSupplyInfo);

PopulationUpdateInfo.TotalPopulation.Women=1;
PopulationUpdateInfo.TotalPopulation.InVehBus=1;
AttributeGetPopulation=GetPopulation(Population,PopulationUpdateInfo);

UppdatePopulationInfo.TotalPopulation.Women=0.5;
[UpdatedSupply,UppdatedPopulation]=UpdateSupplyPopulation(Supply,Population,UpdateSupplyInfo,UppdatePopulationInfo);

% calculate Demand
Demand_Initial=CalculateDemandLogit(Supply,Population);
% calibrate comfort given mode share
TargetModeShare=[0.3,0.2,0.03,0.4,0.07]';

% make a function to calibrate comfort parameters
CalibrateParameters.PT.Metro.ASCMetro=1;
CalibrateParameters.PT.Bus.ASCBus=1;
CalibrateParameters.CarDriver.ASCCarDriver=1;
CalibrateParameters.CarPassenger.ASCCarPassenger=1;
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
FreeFlowCarTime=30;  % make sure this number is realistic
RoadCapacity=1e5;
VDF = @(Volume)FreeFlowCarTime.*(1+(Volume./RoadCapacity).^2);

CarTimeVarName='CarTime';
BusTimeVarName='InVehBus';
IterDisplay=true;


CarCapacity.VDF=VDF;
CarCapacity.CarTimeVarName=CarTimeVarName;
CarCapacity.BusTimeVarName=BusTimeVarName;
% [CapacitatedDemandMatrix_ValueIter,SupplyUpdated_ValueIter,TimeTrace_ValueIter]=CalculateCapacitatedDemand(Supply,Population,VDF,CarTimeVarName,IterDisplay);
[CapacitatedDemandMatrix_Optimization,SupplyUpdated_Optimization,TimeDiff_Optimization]=CalculateCapacitatedDemand(Supply,Population,CarCapacity);
% optimize ticket price for rail
CostPerDeparture=10;
DecisionVariable.CostMetro=1;

OptimizationFlag=true;

[Welfare,OptimizedDemand,SupplyFinal]=OptimizeSupply(Supply,Population,CarCapacity,DecisionVariable,OptimizationFlag);
PriceFinal=GetSupply(SupplyFinal,DecisionVariable);
% plot(Welfare.PossibleCosts,Welfare.WelfareCurve)
PrintSupply(SupplyFinal)