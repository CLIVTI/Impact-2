close all 
clear variables;

% value to be altered:
% 1. in function: SpecifySupply_Stcokholm_Gothenburg, change DiscomfortPeakRail etc. to make sure the discomfort is
% calculated according to the initial demand
% 2. in function: OptimizeSupply_ConstraintReformulation_SPD_1, change line 176, MinusWelfare to consider/not consider CS.
% 

% in function: SpecifySupply_Stcokholm_Gothenburg, we have reduced seat capacity from 278 to 278*0.65 
% in function: OptimizeSupply_ConstraintReformulation_SPD_1, max capacity 310 to 310*0.65

% addpath(genpath('C:/Users/ChengxiL/OneDrive – VTI, Statens väg-och transportforskningsinstitut/Impact 2 matlab optimization/ImpactMatlabModel'))
% current path: C:/Users/ChengxiL/VTI/IMPACT 1 - Dokument/Modellering/ImpactMatlabModel
DesicionVar={};
%% global input
% rail discomfort value.
CostScaleParameter=[0.01];  % CostScaleParameter for different demand segments
% CostScaleParameter=[0.01, 0.01];  % CostScaleParameter for different demand segments
DCValue=[1.4];  % discomfort for DiscomfortPrivatePeakRail; DiscomfortPrivateOffpeakRail; DiscomfortBusinessPeakRail; DiscomfortBusinessOffpeakRail
SeatCapacity=[510*1.9];  % refer to seat capacity in peak and offpeak for comfort
MaxSeatCapacity=[510*1.9];  % refer to seat capacity in peak and offpeak
% specify RailDiscomfort variables
RailDiscomfort={};
RailDiscomfort.Varnames={'DiscomfortRail'};
RailDiscomfort.DCValue=DCValue;
CSorPS='PS';
OperationalCost=[139456]; % OperationalCost 40009 is for sweden with 278 seats, while French train is 510*1.9 assuming coupled, so 139456. 40009/278*510*1.9
BanAvgift=[6957,6091]; % BanAvgift for every departure in peak and offpeak
%% run the model
Model=SpecifySupply_SPD1(CostScaleParameter,DCValue,SeatCapacity);

% Supply=SpecifySupply_Regional();
% Population=SpecifyPopulationSegment_Regional();
% an example to update attributes in Supply

% check the validity of the model
CheckModelStructure(Model);
[VarNamesStackUpdated,DemandSegmentStackUpdated,AlternativeStack_Nest1_Updated,AlternativeStack_Nest2_Updated]=ParseModelAttributes(Model);
ModelCopy=CopyModel(Model);
%% Unittest of get and set functions
% unitest pass
% get supply variables
GetSupplyInfo={};
GetSupplyInfo.FirstWaitTimeBus=199;
GetSupplyInfo.DiscomfortRail=199;
AttributeGet=GetAttribute(Model,GetSupplyInfo);
% set supply variables
UpdateSupplyInfo={};
UpdateSupplyInfo.DiscomfortRail=-1.5;
UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);
% get what is set to check if the set function works properly.
GetSupplyInfo={};
GetSupplyInfo.DiscomfortRail=1;
AttributeGet_2=GetAttribute(UpdatedModel,GetSupplyInfo);
%% Demand calibrations and Demand function unit test
% calculate Demand
Demand_Initial=CalculateDemandLogit(Model);
% calibrate comfort given mode share
TargetDemand=table();
TargetDemand.('All_Rail')=3750; % >0 ASC, this means with 0 ASC value, we get a lower demand than the target (2500) in this case. 1992
TargetDemand.('All_Bus')=3750/0.16825*0.03925;  % <0 ASC, this means with 0 ASC value, we get a higher demand than the target (55) in this case.
TargetDemand.('All_Air')=3750/0.16825*0.09425;  % >0 ASC
TargetDemand.('All_Car')=3750/0.16825*0.69825;  % >0 ASC

% update discomfort variables in model.
UpdateSupplyInfo={};
UpdateSupplyInfo.DiscomfortRail=DCValue(1)^(TargetDemand.('All_Rail')/(SeatCapacity(1)*6)); % here we have 12 trains
Model=UppdateModel(Model,UpdateSupplyInfo);

% update population size
Model.PopulationSize.All=TargetDemand.('All_Rail')+TargetDemand.('All_Bus')+...
    TargetDemand.('All_Air')+TargetDemand.('All_Car');

% make a function to calibrate ASC values, right hand side of the function is the initial value, make sure to change it
% if the corresponding demand segment returns value that deviates significantly against what is observed.


% if scaleparameter=0.5, use the following
CalibrateParameters.All.Bus.ASCBus=-1;
CalibrateParameters.All.Air.ASCAir=15  ;
CalibrateParameters.All.Car.ASCCar=10;

CalibrationStatistics=CalibrateLogitParameters(Model,CalibrateParameters,TargetDemand);
TargetDemandDisplay=CalibrationStatistics.TargetDemand
CalibratedDemandDisplay=CalibrationStatistics.FinalModeShare
% calculate Demand
[ModelDemand,Utility]=CalculateDemandLogit(Model);
% calculate elasticity of all supply variables
[Elasticity,DemandShift]=ElasticityLogit(Model);  % elasticity already *100%

% scenario test 40% improvement for each Attractiveness and delay improvement
UpdateSupplyInfo={};
UpdateSupplyInfo.Att_Booking=1*1.4;
NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
% [CapacitatedDemand,CapacitatedUtility,FinalModel,ComfortBefore,ComfortAfter]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
[CapacitatedDemand_Booking,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
[ModelDemand_Booking,Utility]=CalculateDemandLogit(NewTrialModel);
CapacitatedDemand_Booking
ModelDemand_Booking

UpdateSupplyInfo={};
UpdateSupplyInfo.Att_Information=130*1.4;
NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
[CapacitatedDemand_Information,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);

UpdateSupplyInfo={};
UpdateSupplyInfo.Att_Service=130*1.4;
NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
[CapacitatedDemand_Service,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);

% delay improvement  frequency (????) and 19% increase in punctuality
UpdateSupplyInfo={};
% 25% decrease in number of trains (12): 12*0.75; punctuality 90% increased by 19%: 0.9*0.19
% average delay is 2.5 min for those <5 min delay trains; average delay min for >5 min delay trains is 30 min
UpdateSupplyInfo.DelayRail=3.92;  
NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
[CapacitatedDemand_Delay,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);

% frequency improvement 6 trains to 9 trains
UpdateSupplyInfo={};
UpdateSupplyInfo.FirstWaitTimeRail=60/(9)/2;
% 25% decrease in number of trains (12): 12*0.75; punctuality 90% increased by 19%: 0.9*0.19
% average delay is 2.5 min for those <5 min delay trains; average delay min for >5 min delay trains is 30 min
NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
[CapacitatedDemand_Frequency,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
CapacitatedDemand_Booking
CapacitatedDemand_Information
CapacitatedDemand_Service
CapacitatedDemand_Delay
CapacitatedDemand_Frequency

% draw elasticity curve 
DemandElasticity=zeros(11,5);
DemandElasticity(:,1)=0:5:50;
for i=1:11
    UpdateSupplyInfo={};
    UpdateSupplyInfo.Att_Booking=(1+0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Booking,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
   % [CapacitatedDemand_Booking,Utility]=CalculateDemandLogit(NewTrialModel);
    DemandElasticity(i,2)=(CapacitatedDemand_Booking.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
       
    UpdateSupplyInfo={};
    UpdateSupplyInfo.Att_Information=130.*(1+0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Information,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
    DemandElasticity(i,3)=(CapacitatedDemand_Information.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
    
    UpdateSupplyInfo={};
    UpdateSupplyInfo.Att_Service=130.*(1+0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Service,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
    DemandElasticity(i,4)=(CapacitatedDemand_Service.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
    
    UpdateSupplyInfo={};
    UpdateSupplyInfo.CostRail=47*10.67.*(1-0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Cost,~,~,~,~]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
    DemandElasticity(i,5)=(CapacitatedDemand_Cost.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
end
figure(1)
plot(DemandElasticity(:,1),DemandElasticity(:,2:end))
legend({'Booking','Information','Service','Cost'},'FontSize', 14)
xlabel('Improvement (%)','FontSize', 14) 
ylabel('Demand increase (%)','FontSize', 14) 



% draw elasticity curve
figure(2)
DemandElasticity=zeros(11,5);
DemandElasticity(:,1)=0:5:50;
for i=1:11
    UpdateSupplyInfo={};
    UpdateSupplyInfo.Att_Booking=(1+0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Booking,~]=CalculateDemandLogit(NewTrialModel);
   % [CapacitatedDemand_Booking,Utility]=CalculateDemandLogit(NewTrialModel);
    DemandElasticity(i,2)=(CapacitatedDemand_Booking.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
       
    UpdateSupplyInfo={};
    UpdateSupplyInfo.Att_Information=130.*(1+0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Information,~]=CalculateDemandLogit(NewTrialModel);
    DemandElasticity(i,3)=(CapacitatedDemand_Information.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
    
    UpdateSupplyInfo={};
    UpdateSupplyInfo.Att_Service=130.*(1+0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Service,~]=CalculateDemandLogit(NewTrialModel);
    DemandElasticity(i,4)=(CapacitatedDemand_Service.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
    
    UpdateSupplyInfo={};
    UpdateSupplyInfo.CostRail=47*10.67.*(1-0.05*(i-1));
    NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
    [CapacitatedDemand_Cost,~]=CalculateDemandLogit(NewTrialModel);
    DemandElasticity(i,5)=(CapacitatedDemand_Cost.('All_Rail')-TargetDemand.('All_Rail'))./TargetDemand.('All_Rail')*100;
end

plot(DemandElasticity(:,1),DemandElasticity(:,2:end))
legend({'Booking','Information','Service','Cost'},'FontSize', 14)
xlabel('Improvement (%)','FontSize', 14) 
ylabel('Demand increase (%)','FontSize', 14) 
%% Unitest of some functions
% 
% DecisionVariable={};
% DecisionVariable.CostRail=1;
% DecisionVariable.FirstWaitTimeRail=1;
% 
% DiscomfortDiff function unitest
% UpdateSupplyInfo={};
% UpdateSupplyInfo.CostRail=47*10.67;
% NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
% [FinalDiscomfortDiffUnitest]=DiscomfortDifference(NewTrialModel,RailDiscomfort,SeatCapacity);
% [UpdatedModel]=UppdateDiscomfortInModel(NewTrialModel,RailDiscomfort,SeatCapacity);
% 
% GetSupplyInfo={};
% GetSupplyInfo.('DiscomfortRail')=1;
% DiscomfortRailOriginal=GetAttribute(Model,GetSupplyInfo)
% DiscomfortRailUpdated=GetAttribute(UpdatedModel,GetSupplyInfo)
% 
% % Unit test ConsumerSurplus function
% UpdateSupplyInfo={};
% UpdateSupplyInfo.CostRail=350; % 403
% NewTrialModel=UppdateModel(Model,UpdateSupplyInfo);
% %test consumer surplus
% [CS_Logsum,CS_RuleOfHalf]=ConsumerSurplus(DecisionVariable,Model,NewTrialModel);
% CS_Logsum
% CS_RuleOfHalf
% clear NewTrialModel




%% optimization setup
DecisionVariable={};
DecisionVariable.CostRail=1;
DecisionVariable.FirstWaitTimeRail=1;

[ObjectiveFunctionBaseline,...
 ObjectiveFunctionOptimal,...
 OptimizedDemandOptimal,...
 FinalDecisionVariablesOptimal,...
 UpdatedModelOptimal,...
 ElasticityOptimal]=OptimizationProblem_SPD_1(Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS);








