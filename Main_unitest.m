close all 
clear variables;

addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
DesicionVar={};

Model=SpecifySupply_unitest();
% Supply=SpecifySupply_Regional();
% Population=SpecifyPopulationSegment_Regional();
% an example to update attributes in Supply
Demand_Initial=CalculateDemandLogit(Model);
Elasticity=ElasticityLogit(Model);  % elasticity already *100%
% check the validity of the model
CheckModelStructure(Model);
[VarNamesStackUpdated,DemandSegmentStackUpdated,AlternativeStack_Nest1_Updated,AlternativeStack_Nest2_Updated]=ParseModelAttributes(Model);
ModelCopy=CopyModel(Model);

GetSupplyInfo.AccessCostPrivateAir=199;
AttributeGet=GetAttribute(Model,GetSupplyInfo);

UpdateSupplyInfo.FirstWaitTimeOffeakBus=0.1;
UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);

GetSupplyInfo={};
GetSupplyInfo.FirstWaitTimeOffeakBus=1;
AttributeGet_2=GetAttribute(UpdatedModel,GetSupplyInfo);

% calculate Demand
Demand_Initial=CalculateDemandLogit(Model);
% calibrate comfort given mode share
TargetDemand=table();
TargetDemand.('Private_Peak_Rail')=2500; % >0 ASC, this means with 0 ASC value, we get a lower demand than the target (2500) in this case.
TargetDemand.('Private_Peak_Bus')=55;  % <0 ASC, this means with 0 ASC value, we get a higher demand than the target (55) in this case.
TargetDemand.('Private_Peak_Air')=778;  % >0 ASC
TargetDemand.('Private_Peak_Car')=704;  % >0 ASC
TargetDemand.('Private_Offpeak_Rail')=2656; % >0 ASC
TargetDemand.('Private_Offpeak_Bus')=387;  % <0 ASC
TargetDemand.('Private_Offpeak_Air')=722;  % >0 ASC
TargetDemand.('Private_Offpeak_Car')=1000;  % >0 ASC
TargetDemand.('Business_Peak_Rail')=1382;  % <0 ASC
TargetDemand.('Business_Peak_Bus')=2;  % <0 ASC
TargetDemand.('Business_Peak_Air')=642; % >0 ASC
TargetDemand.('Business_Peak_Car')=150; % >0 ASC
TargetDemand.('Business_Offpeak_Car')=32; % <0 ASC


% make a function to calibrate ASC values, 
CalibrateParameters.Private.Peak.Bus.ASCPrivatePeakBus=5;
CalibrateParameters.Private.Peak.Air.ASCPrivatePeakAir=10;
CalibrateParameters.Private.Peak.Car.ASCPrivatePeakCar=5;
CalibrateParameters.Private.Offpeak.Rail.ASCPrivateOffpeakRail=5;
CalibrateParameters.Private.Offpeak.Bus.ASCPrivateOffpeakBus=-1;
CalibrateParameters.Private.Offpeak.Air.ASCPrivateOffpeakAir=1;
CalibrateParameters.Private.Offpeak.Car.ASCPrivateOffpeakCar=1;
CalibrateParameters.Business.Peak.Rail.ASCBusinessPeakRail=-1;
CalibrateParameters.Business.Peak.Bus.ASCBusinessPeakBus=6.3;
CalibrateParameters.Business.Peak.Air.ASCBusinessPeakAir=6;
CalibrateParameters.Business.Peak.Car.ASCBusinessPeakCar=2;
CalibrateParameters.Business.Offpeak.Car.ASCBusinessOffpeakCar=-6;


CalibrationStatistics=CalibrateLogitParameters(Model,CalibrateParameters,TargetDemand);
Model.Supply.Private.Peak.Bus('ASCPrivatePeakBus')
CalibrationStatistics.TargetDemand
CalibrationStatistics.FinalModeShare
% calculate Demand
ModelDemand=CalculateDemandLogit(Model);
% calculate elasticity of all supply variables
Elasticity=ElasticityLogit(Model);  % elasticity already *100%





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