close all 
clear variables;

% value to be altered:
% 1. in function: SpecifySupply_Stcokholm_Gothenburg, change DiscomfortPeakRail etc. to make sure the discomfort is
% calculated according to the initial demand
% 2. in function: OptimizeSupply, change line 176, MinusWelfare to consider/not consider CS.
% 

% in function: SpecifySupply_Stcokholm_Gothenburg, we have reduced seat capacity from 278 to 278*0.65 
% in function: OptimizeSupply, max capacity 310 to 310*0.65

% addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
% current path: C:/Users/ChengxiL/VTI/IMPACT 1 - Dokument/Modellering/ImpactMatlabModel
DesicionVar={};
%% global input
% rail discomfort value.
DCValue=1.1;
SeatCapacity=[278,278];  % refer to seat capacity in peak and offpeak
MaxSeatCapacity=[310,310];  % refer to seat capacity in peak and offpeak
% specify RailDiscomfort variables
RailDiscomfort={};
RailDiscomfort.Varnames={'DiscomfortPeakRail','DiscomfortOffpeakRail'};
RailDiscomfort.DCValue=DCValue;
CSorPS='PS';
%% run the model
Model=SpecifySupply_Stcokholm_Gothenburg(DCValue,SeatCapacity);

% Supply=SpecifySupply_Regional();
% Population=SpecifyPopulationSegment_Regional();
% an example to update attributes in Supply

% check the validity of the model
CheckModelStructure(Model);
[VarNamesStackUpdated,DemandSegmentStackUpdated,AlternativeStack_Nest1_Updated,AlternativeStack_Nest2_Updated]=ParseModelAttributes(Model);
ModelCopy=CopyModel(Model);
%% Unit test of get and set functions
% get supply variables
GetSupplyInfo={};
GetSupplyInfo.AccessCostPrivateAir=199;
GetSupplyInfo.DiscomfortPeakRail=199;
GetSupplyInfo.ASCPrivatePeakRail=199;
AttributeGet=GetAttribute(Model,GetSupplyInfo);
% set supply variables
UpdateSupplyInfo.DiscomfortPeakRail=0.1;
UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);
% get what is set to check if the set function works properly.
GetSupplyInfo={};
GetSupplyInfo.FirstWaitTimeOffeakBus=1;
AttributeGet_2=GetAttribute(UpdatedModel,GetSupplyInfo);
%% Demand calibrations and Demand function unit test
% calculate Demand
Demand_Initial=CalculateDemandLogit(Model);
% calibrate comfort given mode share
TargetDemand=table();
TargetDemand.('Private_Peak_Rail')=1992; % >0 ASC, this means with 0 ASC value, we get a lower demand than the target (2500) in this case.
TargetDemand.('Private_Peak_Bus')=55;  % <0 ASC, this means with 0 ASC value, we get a higher demand than the target (55) in this case.
TargetDemand.('Private_Peak_Air')=778;  % >0 ASC
TargetDemand.('Private_Peak_Car')=800;  % >0 ASC
TargetDemand.('Private_Offpeak_Rail')=1707; % >0 ASC
TargetDemand.('Private_Offpeak_Bus')=387;  % <0 ASC
TargetDemand.('Private_Offpeak_Air')=722;  % >0 ASC
TargetDemand.('Private_Offpeak_Car')=904;  % >0 ASC
TargetDemand.('Business_Peak_Rail')=991;  % <0 ASC
TargetDemand.('Business_Peak_Bus')=2;  % <0 ASC
TargetDemand.('Business_Peak_Air')=642; % >0 ASC
TargetDemand.('Business_Peak_Car')=182; % >0 ASC



% make a function to calibrate ASC values, right hand side of the function is the initial value, make sure to change it
% if the corresponding demand segment returns value that deviates significantly against what is observed.
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


CalibrationStatistics=CalibrateLogitParameters(Model,CalibrateParameters,TargetDemand);
Model.Supply.Private.Peak.Bus('ASCPrivatePeakBus')
CalibrationStatistics.TargetDemand
CalibrationStatistics.FinalModeShare
% calculate Demand
[ModelDemand,Utility]=CalculateDemandLogit(Model);
% calculate elasticity of all supply variables
[Elasticity,DemandShift]=ElasticityLogit(Model);  % elasticity already *100%
Model.Supply.Private.Peak.Rail('DiscomfortPeakRail')






% GetSupplyInfo={};
% GetSupplyInfo.(RailDiscomfort{1})=1;
% AttributeGet=GetAttribute(Model,GetSupplyInfo);
%% calculate the capacitated demand through optimization
% UpdateSupplyInfo={};
% UpdateSupplyInfo.CostPrivatePeakRail=600;
% UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);
% 
% [CapacitatedDemand,CapacitatedUtility,FinalModel,ComfortBefore,ComfortAfter]=CalculateCapacitatedDemand(UpdatedModel,RailDiscomfort,SeatCapacity);
% ModelDemand_NoCapacity=CalculateDemandLogit(UpdatedModel);
% CapacitatedDemand
% ModelDemand
% ModelDemand_NoCapacity
% ComfortBefore
% ComfortAfter
% 
% clear UpdatedModel
% GetSupplyInfo={};
% GetSupplyInfo.('DiscomfortPeakRail')=1;
% AttributeGet=GetAttribute(FinalModel,GetSupplyInfo);

%% optimization. must make manual change if one changes the model structure (changing parameter/attribute values do not matter)
DecisionVariable={};
DecisionVariable.CostPrivatePeakRail=1;
DecisionVariable.FirstWaitTimePeakRail=1;
DecisionVariable.CostPrivateOffpeakRail=1;
DecisionVariable.FirstWaitTimeOffpeakRail=1;
DecisionVariable.CostBusinessPeakRail=1;

% unit test ConsumerSurplus function
UpdateSupplyInfo={};
UpdateSupplyInfo.CostPrivatePeakRail=350; % 403
UpdateSupplyInfo.CostPrivateOffpeakRail=450;  % 378
NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
%test consumer surplus
[CS,CS2]=ConsumerSurplus(DecisionVariable,Model,NewTrialModel,RailDiscomfort,SeatCapacity);
CS
CS2
clear NewTrialModel
% optimization of the obj function
[ObjectiveFunctionBaseline,ObjectiveFunctionNonInteger,OptimizedDemandNonInteger,FinalDecisionVariablesNonInteger,UpdatedModelNonInteger]=OptimizeSupply(Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity,CSorPS);

[CapacitatedDemand,CapacitatedUtility,FinalModel,ComfortBefore,ComfortAfter]=CalculateCapacitatedDemand(Model,RailDiscomfort,SeatCapacity);
ComfortBefore
ComfortAfter

[CapacitatedDemand,CapacitatedUtility,FinalModel,ComfortBefore,ComfortAfter]=CalculateCapacitatedDemand(UpdatedModelNonInteger,RailDiscomfort,SeatCapacity);
ComfortBefore
ComfortAfter

[FinalDiscomfortDiffUnitest]=DiscomfortDifference(UpdatedModelNonInteger,RailDiscomfort,SeatCapacity);
FinalDiscomfortDiffUnitest
%% do the test for 4 solutions with integer frequency
FrequencyPeakRail_Final=60.*7/FinalDecisionVariablesNonInteger.('FirstWaitTimePeakRail');
FrequencyOffpeakRail_Final=60.*9/FinalDecisionVariablesNonInteger.('FirstWaitTimeOffpeakRail');

FrequencyPeakRail_Lower=floor(FrequencyPeakRail_Final);
FrequencyPeakRail_Upper=floor(FrequencyPeakRail_Final)+1;
FirstWaitTimePeakRail_Lower=60.*7/FrequencyPeakRail_Lower;
FirstWaitTimePeakRail_Upper=60.*7/FrequencyPeakRail_Upper;

FrequencyOffpeakRail_Lower=floor(FrequencyOffpeakRail_Final);
FrequencyOffpeakRail_Upper=floor(FrequencyOffpeakRail_Final)+1;
FirstWaitTimeOffpeakRail_Lower=60.*9/FrequencyOffpeakRail_Lower;
FirstWaitTimeOffpeakRail_Upper=60.*9/FrequencyOffpeakRail_Upper;

% define some structures
ObjectiveFunctionFinalSelection={};
OptimizedDemandSelection={};
FinalDecisionVariablesSelection={};
UpdatedModelSelection={};
FrequencyName={};
% first optimize low and low combination
UpdateSupplyInfo_LowLow={};
UpdateSupplyInfo_LowLow.FirstWaitTimePeakRail=FirstWaitTimePeakRail_Lower;
UpdateSupplyInfo_LowLow.FirstWaitTimeOffpeakRail=FirstWaitTimeOffpeakRail_Lower;
ModelFrequency_LowLow=UppdateModel(Model,UpdateSupplyInfo_LowLow);
DecisionVariable_LowLow={};
DecisionVariable_LowLow.CostPrivatePeakRail=1;
DecisionVariable_LowLow.CostPrivateOffpeakRail=1;
DecisionVariable_LowLow.CostBusinessPeakRail=1;
[~,ObjectiveFunctionFinal_LowLow,OptimizedDemand_LowLow,FinalDecisionVariables_LowLow,UpdatedModel_LowLow]=OptimizeSupply(ModelFrequency_LowLow,DecisionVariable_LowLow,RailDiscomfort,SeatCapacity,MaxSeatCapacity,CSorPS);
ObjectiveFunctionFinalSelection.LowLow=ObjectiveFunctionFinal_LowLow;
OptimizedDemandSelection.LowLow=OptimizedDemand_LowLow;
FinalDecisionVariablesSelection.LowLow=FinalDecisionVariables_LowLow;
UpdatedModelSelection.LowLow=UpdatedModel_LowLow;
FrequencyName.LowLow=UpdateSupplyInfo_LowLow;

% 2nd optimize low and high combination
UpdateSupplyInfo_LowHigh={};
UpdateSupplyInfo_LowHigh.FirstWaitTimePeakRail=FirstWaitTimePeakRail_Lower;
UpdateSupplyInfo_LowHigh.FirstWaitTimeOffpeakRail=FirstWaitTimeOffpeakRail_Upper;
ModelFrequency_LowHigh=UppdateModel(Model,UpdateSupplyInfo_LowHigh);
DecisionVariable_LowHigh={};
DecisionVariable_LowHigh.CostPrivatePeakRail=1;
DecisionVariable_LowHigh.CostPrivateOffpeakRail=1;
DecisionVariable_LowHigh.CostBusinessPeakRail=1;
[~,ObjectiveFunctionFinal_LowHigh,OptimizedDemand_LowHigh,FinalDecisionVariables_LowHigh,UpdatedModel_LowHigh]=OptimizeSupply(ModelFrequency_LowHigh,DecisionVariable_LowHigh,RailDiscomfort,SeatCapacity,MaxSeatCapacity,CSorPS);
ObjectiveFunctionFinalSelection.LowHigh=ObjectiveFunctionFinal_LowHigh;
OptimizedDemandSelection.LowHigh=OptimizedDemand_LowHigh;
FinalDecisionVariablesSelection.LowHigh=FinalDecisionVariables_LowHigh;
UpdatedModelSelection.LowHigh=UpdatedModel_LowHigh;
FrequencyName.LowHigh=UpdateSupplyInfo_LowHigh;

% 3rd optimize high and low combination
UpdateSupplyInfo_HighLow={};
UpdateSupplyInfo_HighLow.FirstWaitTimePeakRail=FirstWaitTimePeakRail_Upper;
UpdateSupplyInfo_HighLow.FirstWaitTimeOffpeakRail=FirstWaitTimeOffpeakRail_Lower;
ModelFrequency_HighLow=UppdateModel(Model,UpdateSupplyInfo_HighLow);
DecisionVariable_HighLow={};
DecisionVariable_HighLow.CostPrivatePeakRail=1;
DecisionVariable_HighLow.CostPrivateOffpeakRail=1;
DecisionVariable_HighLow.CostBusinessPeakRail=1;
[~,ObjectiveFunctionFinal_HighLow,OptimizedDemand_HighLow,FinalDecisionVariables_HighLow,UpdatedModel_HighLow]=OptimizeSupply(ModelFrequency_HighLow,DecisionVariable_HighLow,RailDiscomfort,SeatCapacity,MaxSeatCapacity,CSorPS);
ObjectiveFunctionFinalSelection.HighLow=ObjectiveFunctionFinal_HighLow;
OptimizedDemandSelection.HighLow=OptimizedDemand_HighLow;
FinalDecisionVariablesSelection.HighLow=FinalDecisionVariables_HighLow;
UpdatedModelSelection.HighLow=UpdatedModel_HighLow;
FrequencyName.HighLow=UpdateSupplyInfo_HighLow;

% 4th optimize high and high combination
UpdateSupplyInfo_HighHigh={};
UpdateSupplyInfo_HighHigh.FirstWaitTimePeakRail=FirstWaitTimePeakRail_Upper;
UpdateSupplyInfo_HighHigh.FirstWaitTimeOffpeakRail=FirstWaitTimeOffpeakRail_Upper;
ModelFrequency_HighHigh=UppdateModel(Model,UpdateSupplyInfo_HighHigh);
DecisionVariable_HighHigh={};
DecisionVariable_HighHigh.CostPrivatePeakRail=1;
DecisionVariable_HighHigh.CostPrivateOffpeakRail=1;
DecisionVariable_HighHigh.CostBusinessPeakRail=1;
[~,ObjectiveFunctionFinal_HighHigh,OptimizedDemand_HighHigh,FinalDecisionVariables_HighHigh,UpdatedModel_HighHigh]=OptimizeSupply(ModelFrequency_HighHigh,DecisionVariable_HighHigh,RailDiscomfort,SeatCapacity,MaxSeatCapacity,CSorPS);
ObjectiveFunctionFinalSelection.HighHigh=ObjectiveFunctionFinal_HighHigh;
OptimizedDemandSelection.HighHigh=OptimizedDemand_HighHigh;
FinalDecisionVariablesSelection.HighHigh=FinalDecisionVariables_HighHigh;
UpdatedModelSelection.HighHigh=UpdatedModel_HighHigh;
FrequencyName.HighHigh=UpdateSupplyInfo_HighHigh;
% compare and decide which one is the best
ObjectiveFunctionCompare=[ObjectiveFunctionFinal_LowLow.ObjectiveFunction,ObjectiveFunctionFinal_LowHigh.ObjectiveFunction,ObjectiveFunctionFinal_HighLow.ObjectiveFunction,ObjectiveFunctionFinal_HighHigh.ObjectiveFunction];
[~,BestIndex]=max(ObjectiveFunctionCompare);
StringName={'LowLow','LowHigh','HighLow','HighHigh'};
fprintf('The following combination: %-15s has the highest objective function.',StringName{BestIndex})

ObjectiveFunctionFinal=ObjectiveFunctionFinalSelection.(StringName{BestIndex});
OptimizedDemandFinal=OptimizedDemandSelection.(StringName{BestIndex});
FinalDecisionVariablesFinal=FinalDecisionVariablesSelection.(StringName{BestIndex});
UpdatedModelFinal=UpdatedModelSelection.(StringName{BestIndex});

% if BestIndex==1
%     [~,ObjectiveFunctionFinal,OptimizedDemandFinal,FinalDecisionVariablesFinal,UpdatedModelFinal]=OptimizeSupply(ModelFrequency_LowLow,DecisionVariable_LowLow,RailDiscomfort,SeatCapacity_LowLow);
% elseif BestIndex==2
%     [~,ObjectiveFunctionFinal,OptimizedDemandFinal,FinalDecisionVariablesFinal,UpdatedModelFinal]=OptimizeSupply(ModelFrequency_LowHigh,DecisionVariable_LowHigh,RailDiscomfort,SeatCapacity_LowHigh);
% elseif BestIndex==3
%     [~,ObjectiveFunctionFinal,OptimizedDemandFinal,FinalDecisionVariablesFinal,UpdatedModelFinal]=OptimizeSupply(ModelFrequency_HighLow,DecisionVariable_HighLow,RailDiscomfort,SeatCapacity_HighLow);
% elseif BestIndex==4
%     [~,ObjectiveFunctionFinal,OptimizedDemandFinal,FinalDecisionVariablesFinal,UpdatedModelFinal]=OptimizeSupply(ModelFrequency_HighHigh,DecisionVariable_HighHigh,RailDiscomfort,SeatCapacity_HighHigh);
% end

% print out the final objective function values
fprintf('\n\n----------------- DISPLAY OBJECTIVE FUNCTION ---------------------')
fprintf('\n%-15s : %8s %8s %8s\n'    , ['Parameter'],           ['Initial'],     ['OptimalResult'], ['Difference'] );
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'ObjectiveFunction:',    ObjectiveFunctionBaseline.ObjectiveFunction,  ObjectiveFunctionFinal.ObjectiveFunction, ObjectiveFunctionFinal.ObjectiveFunction-ObjectiveFunctionBaseline.ObjectiveFunction        )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'CS:',                   ObjectiveFunctionBaseline.CS,              ObjectiveFunctionFinal.CS ,                  ObjectiveFunctionFinal.CS-ObjectiveFunctionBaseline.CS  )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'Revenue:',               ObjectiveFunctionBaseline.Revenue,     ObjectiveFunctionFinal.Revenue,                 ObjectiveFunctionFinal.Revenue-ObjectiveFunctionBaseline.Revenue    )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'OperationalCost:',     ObjectiveFunctionBaseline.OperationalCost,   ObjectiveFunctionFinal.OperationalCost,     ObjectiveFunctionFinal.OperationalCost-ObjectiveFunctionBaseline.OperationalCost    )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'BanAvgift:',            ObjectiveFunctionBaseline.BanAvgift,              ObjectiveFunctionFinal.BanAvgift,     ObjectiveFunctionFinal.BanAvgift-ObjectiveFunctionBaseline.BanAvgift    )


% print out the final decision variable value
fprintf('\n\n----------------- DISPLAY DECISION VARIABLES ---------------------')
fprintf('\n%-15s : %8s %8s \n' , ['Parameter'],['InitialValue'],['Estimates']);
Varnames=FinalDecisionVariablesNonInteger.Properties.VariableNames;
DecisionVariableBaseline=GetAttribute(Model,DecisionVariable);
for i=1:length(Varnames) 
    if strcmp(Varnames{i},'FirstWaitTimePeakRail')
         fprintf('%-15s : %+8.3f %+8.3f \n', 'NumberTrainsPeakRail', 60.*7/DecisionVariableBaseline.(Varnames{i}) , 60.*7/FrequencyName.(StringName{BestIndex}).('FirstWaitTimePeakRail'))
    elseif strcmp(Varnames{i},'FirstWaitTimeOffpeakRail')
        fprintf('%-15s : %+8.3f %+8.3f \n', 'NumberTrainsOffpeakRail', 60.*9/DecisionVariableBaseline.(Varnames{i}) , 60.*9/FrequencyName.(StringName{BestIndex}).('FirstWaitTimeOffpeakRail'))
    else
         fprintf('%-15s : %+8.3f %+8.3f \n', Varnames{i}, DecisionVariableBaseline.(Varnames{i}) , FinalDecisionVariablesFinal.(Varnames{i}))
    end
   
end


GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimePeakRail')=1;
GetSupplyInfo.('FirstWaitTimeOffpeakRail')=1;
GetSupplyInfo.('FirstWaitTimePeakBus')=1;
GetSupplyInfo.('FirstWaitTimeOffeakBus')=1;
GetSupplyInfo.('FrequencyWaitTimePeakAir')=1;
GetSupplyInfo.('FrequencyWaitTimeOffpeakAir')=1;
UpdatedWaitingTime=table2array(GetAttribute(UpdatedModelFinal,GetSupplyInfo));

fprintf('\n\n----------------- DISPLAY CAPACITY ---------------------')
fprintf('\n%-15s : %8s %8s %8s \n' , ['CapacitySegment'],['MaxCapacity'],['Demand'],['Occupancy']);
fprintf('%-15s : %+8.2f %+8.2f %+8.2f \n', 'Peak_Rail',     60.*7/UpdatedWaitingTime(1).*MaxSeatCapacity(1) , OptimizedDemandFinal.('Private_Peak_Rail')+OptimizedDemandFinal.('Business_Peak_Rail'), (OptimizedDemandFinal.('Private_Peak_Rail')+OptimizedDemandFinal.('Business_Peak_Rail'))./(60.*7/UpdatedWaitingTime(1).*MaxSeatCapacity(1)))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f \n', 'Offpeak_Rail',  60.*9/UpdatedWaitingTime(2).*MaxSeatCapacity(2) , OptimizedDemandFinal.('Private_Offpeak_Rail'), OptimizedDemandFinal.('Private_Offpeak_Rail')./(60.*9/UpdatedWaitingTime(2).*MaxSeatCapacity(2)))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Bus',      60.*7/UpdatedWaitingTime(3).*100 , OptimizedDemandFinal.('Private_Peak_Bus')+OptimizedDemandFinal.('Business_Peak_Bus'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Offpeak_Bus',   60.*9/UpdatedWaitingTime(4).*100 , OptimizedDemandFinal.('Private_Offpeak_Bus'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Air',      60.*7/UpdatedWaitingTime(5).*120, OptimizedDemandFinal.('Private_Peak_Air')+OptimizedDemandFinal.('Business_Peak_Air'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'OffPeak_Air',   60.*9/UpdatedWaitingTime(6).*120 , OptimizedDemandFinal.('Private_Offpeak_Air'))

% get the final cost
GetSupplyInfo={};
GetSupplyInfo.('CostPrivatePeakRail')=1;
GetSupplyInfo.('CostPrivatePeakBus')=1;
GetSupplyInfo.('CostPrivatePeakAir')=1;
GetSupplyInfo.('CostPrivatePeakCar')=1;
GetSupplyInfo.('CostPrivateOffpeakRail')=1;
GetSupplyInfo.('CostPrivateOffpeakBus')=1;
GetSupplyInfo.('CostPrivateOffpeakAir')=1;
GetSupplyInfo.('CostPrivateOffpeakCar')=1;
GetSupplyInfo.('CostBusinessPeakRail')=1;
GetSupplyInfo.('CostBusinessPeakBus')=1;
GetSupplyInfo.('CostBusinessPeakAir')=1;
GetSupplyInfo.('CostBusinessPeakCar')=1;
UpdatedCost=GetAttribute(UpdatedModelFinal,GetSupplyInfo);
InitialCost=GetAttribute(Model,GetSupplyInfo);
fprintf('\n\n----------------- DISPLAY DEMAND and PS ---------------------')
fprintf('\n%-15s : %8s %8s %8s %8s \n' , ['DemandSegment'],['Demand_Initial'],['Demand_Optimal'],['Revenue_Initial'],['Revenue_Optimal']);
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Peak_Rail',   ModelDemand.('Private_Peak_Rail'),  OptimizedDemandFinal.('Private_Peak_Rail') , ModelDemand.('Private_Peak_Rail').*InitialCost.('CostPrivatePeakRail'), OptimizedDemandFinal.('Private_Peak_Rail').*UpdatedCost.('CostPrivatePeakRail'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Peak_Bus',    ModelDemand.('Private_Peak_Bus'), OptimizedDemandFinal.('Private_Peak_Bus') , ModelDemand.('Private_Peak_Bus').*InitialCost.('CostPrivatePeakBus'), OptimizedDemandFinal.('Private_Peak_Bus').*UpdatedCost.('CostPrivatePeakBus'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Peak_Air',    ModelDemand.('Private_Peak_Air'), OptimizedDemandFinal.('Private_Peak_Air') , ModelDemand.('Private_Peak_Air').*InitialCost.('CostPrivatePeakAir'), OptimizedDemandFinal.('Private_Peak_Air').*UpdatedCost.('CostPrivatePeakAir'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Peak_Car',    ModelDemand.('Private_Peak_Car'), OptimizedDemandFinal.('Private_Peak_Car') , ModelDemand.('Private_Peak_Car').*InitialCost.('CostPrivatePeakCar'), OptimizedDemandFinal.('Private_Peak_Car').*UpdatedCost.('CostPrivatePeakCar'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Offpeak_Rail',  ModelDemand.('Private_Offpeak_Rail'),   OptimizedDemandFinal.('Private_Offpeak_Rail') , ModelDemand.('Private_Offpeak_Rail').*InitialCost.('CostPrivateOffpeakRail'), OptimizedDemandFinal.('Private_Offpeak_Rail').*UpdatedCost.('CostPrivateOffpeakRail'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Offpeak_Bus',   ModelDemand.('Private_Offpeak_Bus'),  OptimizedDemandFinal.('Private_Offpeak_Bus') , ModelDemand.('Private_Offpeak_Bus').*InitialCost.('CostPrivateOffpeakBus'), OptimizedDemandFinal.('Private_Offpeak_Bus').*UpdatedCost.('CostPrivateOffpeakBus'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Offpeak_Air',   ModelDemand.('Private_Offpeak_Air'),  OptimizedDemandFinal.('Private_Offpeak_Air') , ModelDemand.('Private_Offpeak_Air').*InitialCost.('CostPrivateOffpeakAir'), OptimizedDemandFinal.('Private_Offpeak_Air').*UpdatedCost.('CostPrivateOffpeakAir'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Private_Offpeak_Car',   ModelDemand.('Private_Offpeak_Car'),  OptimizedDemandFinal.('Private_Offpeak_Car') , ModelDemand.('Private_Offpeak_Car').*InitialCost.('CostPrivateOffpeakCar'), OptimizedDemandFinal.('Private_Offpeak_Car').*UpdatedCost.('CostPrivateOffpeakCar'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Business_Peak_Rail',    ModelDemand.('Business_Peak_Rail'), OptimizedDemandFinal.('Business_Peak_Rail') , ModelDemand.('Business_Peak_Rail').*InitialCost.('CostBusinessPeakRail'), OptimizedDemandFinal.('Business_Peak_Rail').*UpdatedCost.('CostBusinessPeakRail'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Business_Peak_Bus',     ModelDemand.('Business_Peak_Bus'), OptimizedDemandFinal.('Business_Peak_Bus') , ModelDemand.('Business_Peak_Bus').*InitialCost.('CostBusinessPeakBus'), OptimizedDemandFinal.('Business_Peak_Bus').*UpdatedCost.('CostBusinessPeakBus'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Business_Peak_Air',     ModelDemand.('Business_Peak_Air'),OptimizedDemandFinal.('Business_Peak_Air') , ModelDemand.('Business_Peak_Air').*InitialCost.('CostBusinessPeakAir'), OptimizedDemandFinal.('Business_Peak_Air').*UpdatedCost.('CostBusinessPeakAir'))
fprintf('%-15s : %+8.2f %+8.2f %+8.2f %+8.2f \n', 'Business_Peak_Car',     ModelDemand.('Business_Peak_Car'),OptimizedDemandFinal.('Business_Peak_Car') , ModelDemand.('Business_Peak_Car').*InitialCost.('CostBusinessPeakCar'), OptimizedDemandFinal.('Business_Peak_Car').*UpdatedCost.('CostBusinessPeakCar'))


[CS,CS2]=ConsumerSurplus(DecisionVariable,Model,UpdatedModelFinal,RailDiscomfort,SeatCapacity);
CS
CS2