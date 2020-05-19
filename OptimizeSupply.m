function [ObjectiveFunctionBaseline,ObjectiveFunctionFinal,OptimizedDemand,FinalDecisionVariables,UpdatedModel]=OptimizeSupply(Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity,CSorPS)
% this function optimizes supply given the decision variables specified in DecisionVariable
% DecisionVariable is a structure.

if nargin<6
    CSorPS='CS';
end

if strcmp(CSorPS,'CS')==0 && strcmp(CSorPS,'PS')==0 
    disp('/n Please make sure only CS or PS is specified in the global parameter setting.')
    ObjectiveFunctionBaseline=nan;
    ObjectiveFunctionFinal=nan;
    OptimizedDemand=nan;
    FinalDecisionVariables=nan;
    UpdatedModel=nan;
    return
end

AttributeGet=GetAttribute(Model,DecisionVariable);

startValue=table2array(AttributeGet)'+rand(1).*10;
startValueDisplay=table2array(AttributeGet)';
% get the corresponding alternative names that will change if Decision variables change. AlternativeNames
[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);
DecisionNames=fieldnames(DecisionVariable);
AlternativeNameStack={};
for i=1:length(DecisionNames)
    DecisionNameIndex=find(ismember(VarNamesStack,DecisionNames));
    for j=1:length(DecisionNameIndex)
        if strcmp(AlternativeStack_Nest2{DecisionNameIndex(j)},'') % no nest
            AlternativeNameStack{end+1}=strcat(DemandSegmentStack{DecisionNameIndex(j)},'_',AlternativeStack_Nest1{DecisionNameIndex(j)});
        else
            AlternativeNameStack{end+1}=strcat(DemandSegmentStack{DecisionNameIndex(j)},'_',AlternativeStack_Nest1{DecisionNameIndex(j)},'_',AlternativeStack_Nest2{DecisionNameIndex(j)});
        end
    end
end
AlternativeNames=unique(AlternativeNameStack,'stable');
%% calculate the revenue for the baseline
% calculate the ticket revenue for rail
[CapacitatedDemandBaseline,CapacitatedUtilityBaseline,~,~,~,CSBaseline]=CalculateCapacitatedDemand(Model,RailDiscomfort,SeatCapacity);
ObjectiveFunctionBaseline={};
ObjectiveFunctionBaseline.CapacitatedDemandBaseline=CapacitatedDemandBaseline;
ObjectiveFunctionBaseline.CapacitatedUtilityBaseline=CapacitatedUtilityBaseline;

ObjectiveFunctionBaseline.CS=CSBaseline;

CostPrivatePeakRailBase=Model.Supply.Private.Peak.Rail('CostPrivatePeakRail');
CostPrivatePeakRailBase=CostPrivatePeakRailBase(2);
CostPrivateOffpeakRailBase=Model.Supply.Private.Offpeak.Rail('CostPrivateOffpeakRail');
CostPrivateOffpeakRailBase=CostPrivateOffpeakRailBase(2);
CostBusinessPeakRailBase=Model.Supply.Business.Peak.Rail('CostBusinessPeakRail');
CostBusinessPeakRailBase=CostBusinessPeakRailBase(2);

RevenueBase=CostPrivatePeakRailBase.*(CapacitatedDemandBaseline.('Private_Peak_Rail'))+...
            CostPrivateOffpeakRailBase.*(CapacitatedDemandBaseline.('Private_Offpeak_Rail'))+...
            CostBusinessPeakRailBase.*(CapacitatedDemandBaseline.('Business_Peak_Rail'));
ObjectiveFunctionBaseline.Revenue=RevenueBase;        

% calculate the Operational cost.
GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimePeakRail')=1;
GetSupplyInfo.('FirstWaitTimeOffpeakRail')=1;
WaitingTime=table2array(GetAttribute(Model,GetSupplyInfo));
% OperationalCostBase=(60.*7/WaitingTime(1)+60.*9/WaitingTime(2)).*(((31.83+(278*0.12))*455)+(((94.44+(278*0.32))*180)));
OperationalCostBase=(60.*7/WaitingTime(1)).*((78812+6957).*1.33-6957)+60.*9/WaitingTime(2).*((78812+6957).*0.67-6957);
ObjectiveFunctionBaseline.OperationalCost=OperationalCostBase;

% calculate the BanAvgift
BanAvgiftBase=(60.*7/WaitingTime(1)).*6957+(60.*9/WaitingTime(2)).*6091;
ObjectiveFunctionBaseline.BanAvgift=BanAvgiftBase;

ObjectiveFunctionBaseline.ObjectiveFunction=CSBaseline+RevenueBase-OperationalCostBase-BanAvgiftBase;

%%
A = [];
b = [];
Aeq = [];
beq = [];
lb = zeros(1,length(startValue));
ub = [];
nonlcon =@(DecisionVariableValues) CapacityConstraints(DecisionVariableValues,Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity);
options = optimset('GradObj','off','LargeScale','off','Display','iter-detailed','TolFun',1e-7,'TolX',1e-7,'MaxFunEvals',10000,'MaxIter',3000);
[beta,fval,~,output,~,~]= fmincon(@(DecisionVariableValues)ObjectiveFunction(DecisionVariableValues,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,RailDiscomfort,SeatCapacity,CSorPS),startValue,A,b,Aeq,beq,lb,ub,nonlcon ,options); % '@' is a handle for the LogLikelihood below

[MinusWelfare,OptimizedDemand,UpdatedModel,ObjectiveFunctionFinal]=ObjectiveFunction(beta,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,RailDiscomfort,SeatCapacity,CSorPS);
WelfareIncrease=-MinusWelfare;
CS=ObjectiveFunctionFinal.CS;
Revenue=ObjectiveFunctionFinal.Revenue;
OperationalCost=ObjectiveFunctionFinal.OperationalCost;
BanAvgift=ObjectiveFunctionFinal.BanAvgift;




FinalDecisionVariables=GetAttribute(UpdatedModel,DecisionVariable);

% print out the final objective function values
fprintf('\n\n----------------- DISPLAY OBJECTIVE FUNCTION ---------------------')
fprintf('\n %-15s : %8s %8s\n'    , ['Parameter'],           ['Initial'],     ['OptimalResult'] );
fprintf('%-15s : %+8.1f %+8.1f \n', 'ObjectiveFunction:',    RevenueBase-OperationalCostBase-BanAvgiftBase,  RevenueBase-OperationalCostBase-BanAvgiftBase+ WelfareIncrease          )
fprintf('%-15s : %+8.1f %+8.1f \n', 'CS:',                   CSBaseline,              CS    )
fprintf('%-15s : %+8.1f %+8.1f \n', 'Revenue:',               RevenueBase,     Revenue    )
fprintf('%-15s : %+8.1f %+8.1f \n', 'OperationalCost:',     OperationalCostBase,         OperationalCost    )
fprintf('%-15s : %+8.1f %+8.1f \n', 'BanAvgift:',            BanAvgiftBase,              BanAvgift    )
% print out the final decision variable value
fprintf('\n\n----------------- DISPLAY DECISION VARIABLES ---------------------')
fprintf('\n %-15s : %8s %8s \n' , ['Parameter'],['InitialValue'],['Estimates']);
for i=1:length(beta) 
    fprintf('%-15s : %+8.3f %+8.3f \n', DecisionNames{i}, startValueDisplay(i) , beta(i))
end

% print out the capacity of the final model compared to its demand
[c,~]=CapacityConstraints(beta,UpdatedModel,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity);
fprintf('\n\n----------------- DISPLAY CAPACITY ---------------------')
fprintf('\n %-15s : %8s %8s \n' , ['CapacitySegment'],['MaxCapacity'],['Demand']);
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Rail',     OptimizedDemand.('Private_Peak_Rail')+OptimizedDemand.('Business_Peak_Rail')-c(1) , OptimizedDemand.('Private_Peak_Rail')+OptimizedDemand.('Business_Peak_Rail'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Offpeak_Rail',  OptimizedDemand.('Private_Offpeak_Rail')-c(2) , OptimizedDemand.('Private_Offpeak_Rail'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Bus',      OptimizedDemand.('Private_Peak_Bus')+OptimizedDemand.('Business_Peak_Bus')-c(3) , OptimizedDemand.('Private_Peak_Bus')+OptimizedDemand.('Business_Peak_Bus'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Offpeak_Bus',   OptimizedDemand.('Private_Offpeak_Bus')-c(4) , OptimizedDemand.('Private_Offpeak_Bus'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Air',      OptimizedDemand.('Private_Peak_Air')+OptimizedDemand.('Business_Peak_Air')-c(5), OptimizedDemand.('Private_Peak_Air')+OptimizedDemand.('Business_Peak_Air'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'OffPeak_Air',   OptimizedDemand.('Private_Offpeak_Air')-c(6) , OptimizedDemand.('Private_Offpeak_Air'))


% output PS for all modes and demand for all modes


return



function [MinusWelfare,CapacitatedDemandTrialSolution,UpdatedModel,ObjectiveFunctionFinal]=ObjectiveFunction(DecisionVariableValues,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,RailDiscomfort,SeatCapacity,CSorPS)
% calculate the consumer surplus using rule of a half since we have several attribute changes in different alternatives.

DecisionVariableNames=fieldnames(DecisionVariable);
for i=1:length(DecisionVariableNames)
    DecisionVariable.(DecisionVariableNames{i})=DecisionVariableValues(i);
end
NewTrialModel=UppdateModel(Model,DecisionVariable);


[CapacitatedDemandTrialSolution,CapacitatedUtilityTrialSolution,UpdatedModel,~,~,CSTrialSolution]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
clear NewTrialModel
ObjectiveFunctionFinal={};
% Consumer surplus part
CSBase=ObjectiveFunctionBaseline.CS;
ObjectiveFunctionFinal.CS=CSTrialSolution;

%% choose to use Rule-of-a-half or logsum to calculate consumer surplus
CapacitatedDemandBaseline=ObjectiveFunctionBaseline.CapacitatedDemandBaseline;
CapacitatedUtilityBaseline=ObjectiveFunctionBaseline.CapacitatedUtilityBaseline;
CSDiff=0;
for i=1:length(AlternativeNames)
    CSDiff=CSDiff+100.*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
          (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
end

% CSDiff=CSTrialSolution-CSBase;
%%
% revenue part
RevenueBase=ObjectiveFunctionBaseline.Revenue; 
CostPrivatePeakRailTrialSolution=UpdatedModel.Supply.Private.Peak.Rail('CostPrivatePeakRail');
CostPrivatePeakRailTrialSolution=CostPrivatePeakRailTrialSolution(2);
CostPrivateOffpeakRailTrialSolution=UpdatedModel.Supply.Private.Offpeak.Rail('CostPrivateOffpeakRail');
CostPrivateOffpeakRailTrialSolution=CostPrivateOffpeakRailTrialSolution(2);
CostBusinessPeakRailTrialSolution=UpdatedModel.Supply.Business.Peak.Rail('CostBusinessPeakRail');
CostBusinessPeakRailTrialSolution=CostBusinessPeakRailTrialSolution(2);

RevenueTrialSolution=CostPrivatePeakRailTrialSolution.*(CapacitatedDemandTrialSolution.('Private_Peak_Rail'))+...
            CostPrivateOffpeakRailTrialSolution.*(CapacitatedDemandTrialSolution.('Private_Offpeak_Rail'))+...
            CostBusinessPeakRailTrialSolution.*(CapacitatedDemandTrialSolution.('Business_Peak_Rail'));
        
ObjectiveFunctionFinal.Revenue=RevenueTrialSolution;
RevenueDiff=RevenueTrialSolution-RevenueBase;


% Operational cost part
OperationalCostBase=ObjectiveFunctionBaseline.OperationalCost; 
GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimePeakRail')=1;
GetSupplyInfo.('FirstWaitTimeOffpeakRail')=1;
WaitingTime=table2array(GetAttribute(UpdatedModel,GetSupplyInfo));
% OperationalCostTrialSolution=(60.*7/WaitingTime(1)+60.*9/WaitingTime(2)).*(((31.83+(278*0.12))*455)+(((94.44+(278*0.32))*180)));
OperationalCostTrialSolution=(60.*7/WaitingTime(1)).*((78812+6957).*1.33-6957)+60.*9/WaitingTime(2).*((78812+6957).*0.67-6957);
ObjectiveFunctionFinal.OperationalCost=OperationalCostTrialSolution;
OperationalCostDiff=OperationalCostTrialSolution-OperationalCostBase;

% BanAvgift part
BanAvgiftBase=ObjectiveFunctionBaseline.BanAvgift;
BanAvgiftTrialSolution=(60.*7/WaitingTime(1)).*6957+(60.*9/WaitingTime(2)).*6091;
ObjectiveFunctionFinal.BanAvgift=BanAvgiftTrialSolution;
BanAvgiftDiff=BanAvgiftTrialSolution-BanAvgiftBase;

if strcmp(CSorPS,'CS')==1
    MinusWelfare=-(CSDiff+RevenueDiff-OperationalCostDiff-BanAvgiftDiff);  % change the objective function "+CS"
elseif strcmp(CSorPS,'PS')==1
    MinusWelfare=-(RevenueDiff-OperationalCostDiff-BanAvgiftDiff);  % change the objective function "+CS"
end


ObjectiveFunctionFinal.ObjectiveFunction=CSBase+RevenueBase-OperationalCostBase-BanAvgiftBase-MinusWelfare;
return


function [c,ceq]=CapacityConstraints(DecisionVariableValues,Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity)
% the capacity constraints of the model
c=[];
ceq=[];
DecisionVariableNames=fieldnames(DecisionVariable);
for i=1:length(DecisionVariableNames)
    DecisionVariable.(DecisionVariableNames{i})=DecisionVariableValues(i);
end
ConstraintModel=UppdateModel(Model,DecisionVariable);

GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimePeakRail')=1;
GetSupplyInfo.('FirstWaitTimeOffpeakRail')=1;
GetSupplyInfo.('FirstWaitTimePeakBus')=1;
GetSupplyInfo.('FirstWaitTimeOffeakBus')=1;
GetSupplyInfo.('FrequencyWaitTimePeakAir')=1;
GetSupplyInfo.('FrequencyWaitTimeOffpeakAir')=1;
UpdatedWaitingTime=table2array(GetAttribute(ConstraintModel,GetSupplyInfo));
UpdatedCapacity=[];  % capacity for the capacity constraints
%% important to update the capacity using number of seats here
UpdatedCapacity(1)=60.*7/UpdatedWaitingTime(1).*MaxSeatCapacity(1);   
UpdatedCapacity(2)=60.*9/UpdatedWaitingTime(2).*MaxSeatCapacity(2);
UpdatedCapacity(3)=60.*7/UpdatedWaitingTime(3).*100;
UpdatedCapacity(4)=60.*9/UpdatedWaitingTime(4).*100;
UpdatedCapacity(5)=60.*7/UpdatedWaitingTime(5).*120;
UpdatedCapacity(6)=60.*9/UpdatedWaitingTime(6).*120;
%%

[CapacitatedDemandConstraint,~,~,~,~,~]=CalculateCapacitatedDemand(ConstraintModel,RailDiscomfort,SeatCapacity);
c(1)=CapacitatedDemandConstraint.('Private_Peak_Rail')+CapacitatedDemandConstraint.('Business_Peak_Rail')-UpdatedCapacity(1);
c(2)=CapacitatedDemandConstraint.('Private_Offpeak_Rail')-UpdatedCapacity(2);
c(3)=CapacitatedDemandConstraint.('Private_Peak_Bus')+CapacitatedDemandConstraint.('Business_Peak_Bus')-UpdatedCapacity(3);
c(4)=CapacitatedDemandConstraint.('Private_Offpeak_Bus')-UpdatedCapacity(4);
c(5)=CapacitatedDemandConstraint.('Private_Peak_Air')+CapacitatedDemandConstraint.('Business_Peak_Air')-UpdatedCapacity(5);
c(6)=CapacitatedDemandConstraint.('Private_Offpeak_Air')-UpdatedCapacity(6);
clear ConstraintModel
return 



