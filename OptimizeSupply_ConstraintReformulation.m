function [ObjectiveFunctionBaseline,ObjectiveFunctionFinal,OptimizedDemand,FinalDecisionVariables,UpdatedModel]=OptimizeSupply_ConstraintReformulation(Model,UserDefinedParameters,DecisionVariable)
% this function optimizes supply given the decision variables specified in DecisionVariable
% DecisionVariable is a structure.
%% parse the UserDefinedParameters
ParsedUserDefinedParameters=CheckUserDefinedParameters(UserDefinedParameters);
DCValue=ParsedUserDefinedParameters.DCValue;
ExtraCostBaseValue=ParsedUserDefinedParameters.ExtraCostBaseValue;
DCVarName=ParsedUserDefinedParameters.DCVarName;
SeatCapacity=ParsedUserDefinedParameters.SeatCapacity;
CSorPS=ParsedUserDefinedParameters.CSorPS;
OperationalCost=ParsedUserDefinedParameters.OperationalCost;
BanAvgift=ParsedUserDefinedParameters.BanAvgift;
%%
% RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS
RailDiscomfort={};
RailDiscomfort.Varnames=DCVarName;
RailDiscomfort.DCValue=DCValue;


if strcmp(CSorPS,'CS')==0 && strcmp(CSorPS,'PS')==0 ...
        && strcmp(CSorPS,'PS_1a')==0 && strcmp(CSorPS,'CS_1a')==0 &&...
        strcmp(CSorPS,'PS_2a')==0 && strcmp(CSorPS,'CS_2a')==0 && ...
        strcmp(CSorPS,'PS_3a')==0 && strcmp(CSorPS,'CS_3a')==0
    disp('/n Please make sure only CS or PS is specified in the global parameter setting.')
    ObjectiveFunctionBaseline=nan;
    ObjectiveFunctionFinal=nan;
    OptimizedDemand=nan;
    FinalDecisionVariables=nan;
    UpdatedModel=nan;
    return
end


DecisionVariable.DiscomfortCostPrivatePeakRail=1;
DecisionVariable.DiscomfortCostPrivateOffpeakRail=1;
DecisionVariable.DiscomfortCostBusinessPeakRail=1;
DecisionVariable.DiscomfortCostBusinessOffpeakRail=1;
startValueTable=GetAttribute(Model,DecisionVariable);

startValue=table2array(startValueTable)';
startValueDisplay=table2array(startValueTable)';
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
% [CapacitatedDemandBaseline,CapacitatedUtilityBaseline,~,~,~,CSBaseline]=CalculateCapacitatedDemand(Model,RailDiscomfort,SeatCapacity);
% Model=UppdateDiscomfortInModel(Model,UserDefinedParameters);
[CapacitatedDemandBaseline,CapacitatedUtilityBaseline,CSBaseline]=CalculateDemandLogit(Model);
ObjectiveFunctionBaseline={};
ObjectiveFunctionBaseline.CapacitatedDemandBaseline=CapacitatedDemandBaseline;
ObjectiveFunctionBaseline.CapacitatedUtilityBaseline=CapacitatedUtilityBaseline;
ObjectiveFunctionBaseline.CS=CSBaseline;


GetSupplyInfo={};
GetSupplyInfo.('CostPrivatePeakRail')=1;
GetSupplyInfo.('CostPrivateOffpeakRail')=1;
GetSupplyInfo.('CostBusinessPeakRail')=1;
GetSupplyInfo.('CostBusinessOffpeakRail')=1;
GetSupplyInfo.('DiscomfortCostPrivatePeakRail')=1;
GetSupplyInfo.('DiscomfortCostPrivateOffpeakRail')=1;
GetSupplyInfo.('DiscomfortCostBusinessPeakRail')=1;
GetSupplyInfo.('DiscomfortCostBusinessOffpeakRail')=1;
CostValues=GetAttribute(Model,GetSupplyInfo);




RevenueBase=(CostValues.('CostPrivatePeakRail')+ExtraCostBaseValue(1).*CostValues.('DiscomfortCostPrivatePeakRail')).*(CapacitatedDemandBaseline.('Private_Peak_Rail'))+...
            (CostValues.('CostPrivateOffpeakRail')+ExtraCostBaseValue(2).*CostValues.('DiscomfortCostPrivateOffpeakRail')).*(CapacitatedDemandBaseline.('Private_Offpeak_Rail'))+...
            (CostValues.('CostBusinessPeakRail')+ExtraCostBaseValue(3).*CostValues.('DiscomfortCostBusinessPeakRail')).*(CapacitatedDemandBaseline.('Business_Peak_Rail'))+...
            (CostValues.('CostBusinessOffpeakRail')+ExtraCostBaseValue(4).*CostValues.('DiscomfortCostBusinessOffpeakRail')).*(CapacitatedDemandBaseline.('Business_Offpeak_Rail'));
ObjectiveFunctionBaseline.Revenue=RevenueBase;        

% calculate the Operational cost.
GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimePeakRail')=1;
GetSupplyInfo.('FirstWaitTimeOffpeakRail')=1;
WaitingTime=table2array(GetAttribute(Model,GetSupplyInfo));
% OperationalCostBase=(60.*7/WaitingTime(1)+60.*9/WaitingTime(2)).*(((31.83+(278*0.12))*455)+(((94.44+(278*0.32))*180)));
% OperationalCostBase=(60.*7/WaitingTime(1)).*((78812+BanAvgift(1)).*1.33-BanAvgift(1))+60.*9/WaitingTime(2).*((78812+BanAvgift(2)).*0.67-BanAvgift(2));
% OperationalCostBase=(60.*7/WaitingTime(1)).*((78812+BanAvgift(1)).*1.44-BanAvgift(1))+60.*9/WaitingTime(2).*((78812+BanAvgift(2)).*0.56-BanAvgift(2));
% OperationalCostBase=(60.*7/WaitingTime(1)).*((62673+BanAvgift(1)).*1.33-BanAvgift(1))+60.*9/WaitingTime(2).*((62673+BanAvgift(2)).*0.67-BanAvgift(2));
OperationalCostBase=(60.*7/WaitingTime(1)/2).*OperationalCost(1)+(60.*9/WaitingTime(2)/2).*OperationalCost(2);
ObjectiveFunctionBaseline.OperationalCost=OperationalCostBase;

% calculate the BanAvgift
BanAvgiftBase=(60.*7/WaitingTime(1)/2).*BanAvgift(1)+(60.*9/WaitingTime(2)/2).*BanAvgift(2);
ObjectiveFunctionBaseline.BanAvgift=BanAvgiftBase;

if strcmp(CSorPS,'CS')==1 || strcmp(CSorPS,'CS_1a')==1 || strcmp(CSorPS,'CS_2a')==1 || strcmp(CSorPS,'CS_3a')==1
    ObjectiveFunctionBaseline.ObjectiveFunction=CSBaseline+RevenueBase-OperationalCostBase-BanAvgiftBase;
elseif strcmp(CSorPS,'PS')==1 || strcmp(CSorPS,'PS_1a')==1 || strcmp(CSorPS,'PS_2a')==1 || strcmp(CSorPS,'PS_3a')==1
    ObjectiveFunctionBaseline.ObjectiveFunction=RevenueBase-OperationalCostBase-BanAvgiftBase;
end



%%
A = [];
b = [];
Aeq = [];
beq = [];
lb_noComfort = zeros(1,length(startValue)-4);
lb=[lb_noComfort,-inf,-inf,-inf,-inf];
ub = [];
nonlcon =@(DecisionVariableValues)CapacityConstraints(DecisionVariableValues,Model,DecisionVariable,UserDefinedParameters);
options = optimset('GradObj','off','LargeScale','off','Display','iter','TolFun',1e-6,'TolX',1e-6,'MaxFunEvals',10000,'MaxIter',3000);
[beta,fval,~,output,~,~]= fmincon(@(DecisionVariableValues)ObjectiveFunction(DecisionVariableValues,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,UserDefinedParameters),startValue,A,b,Aeq,beq,lb,ub,nonlcon ,options); % '@' is a handle for the LogLikelihood below

[MinusWelfare,OptimizedDemand,UpdatedModel,ObjectiveFunctionFinal]=ObjectiveFunction(beta,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,UserDefinedParameters);
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
    fprintf('%-15s : %+8.3f %+8.3f \n', 'TrueCostPrivatePeakRail', startValueTable.('CostPrivatePeakRail')+ExtraCostBaseValue(1).*startValueTable.('DiscomfortCostPrivatePeakRail') , FinalDecisionVariables.('CostPrivatePeakRail')+ExtraCostBaseValue(1).*FinalDecisionVariables.('DiscomfortCostPrivatePeakRail'))
    fprintf('%-15s : %+8.3f %+8.3f \n', 'TrueCostPrivateOffpeakRail', startValueTable.('CostPrivateOffpeakRail')+ExtraCostBaseValue(1).*startValueTable.('DiscomfortCostPrivateOffpeakRail') , FinalDecisionVariables.('CostPrivateOffpeakRail')+ExtraCostBaseValue(1).*FinalDecisionVariables.('DiscomfortCostPrivateOffpeakRail'))
    fprintf('%-15s : %+8.3f %+8.3f \n', 'TrueCostBusinessPeakRail', startValueTable.('CostBusinessPeakRail')+ExtraCostBaseValue(1).*startValueTable.('DiscomfortCostBusinessPeakRail') , FinalDecisionVariables.('CostBusinessPeakRail')+ExtraCostBaseValue(1).*FinalDecisionVariables.('DiscomfortCostBusinessPeakRail'))
    fprintf('%-15s : %+8.3f %+8.3f \n', 'TrueCostBusinessOffpeakRail', startValueTable.('CostBusinessOffpeakRail')+ExtraCostBaseValue(1).*startValueTable.('DiscomfortCostBusinessOffpeakRail') , FinalDecisionVariables.('CostBusinessOffpeakRail')+ExtraCostBaseValue(1).*FinalDecisionVariables.('DiscomfortCostBusinessOffpeakRail'))
% print out the capacity of the final model compared to its demand
[c,~]=CapacityConstraints(beta,UpdatedModel,DecisionVariable,UserDefinedParameters);
fprintf('\n\n----------------- DISPLAY CAPACITY ---------------------')
fprintf('\n %-15s : %8s %8s \n' , ['CapacitySegment'],['MaxCapacity'],['Demand']);
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Rail',     OptimizedDemand.('Private_Peak_Rail')+OptimizedDemand.('Business_Peak_Rail')-c(1) , OptimizedDemand.('Private_Peak_Rail')+OptimizedDemand.('Business_Peak_Rail'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Offpeak_Rail',  OptimizedDemand.('Private_Offpeak_Rail')+OptimizedDemand.('Business_Offpeak_Rail')-c(2) , OptimizedDemand.('Private_Offpeak_Rail')+OptimizedDemand.('Business_Offpeak_Rail'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Bus',      OptimizedDemand.('Private_Peak_Bus')+OptimizedDemand.('Business_Peak_Bus')-c(3) , OptimizedDemand.('Private_Peak_Bus')+OptimizedDemand.('Business_Peak_Bus'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Offpeak_Bus',   OptimizedDemand.('Private_Offpeak_Bus')-c(4) , OptimizedDemand.('Private_Offpeak_Bus'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Air',      OptimizedDemand.('Private_Peak_Air')+OptimizedDemand.('Business_Peak_Air')-c(5), OptimizedDemand.('Private_Peak_Air')+OptimizedDemand.('Business_Peak_Air'))
fprintf('%-15s : %+8.2f %+8.2f \n', 'OffPeak_Air',   OptimizedDemand.('Private_Offpeak_Air')-c(6) , OptimizedDemand.('Private_Offpeak_Air'))


% output PS for all modes and demand for all modes


return



function [MinusWelfare,CapacitatedDemandTrialSolution,UpdatedModel,ObjectiveFunctionFinal]=ObjectiveFunction(DecisionVariableValues,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,UserDefinedParameters)
% calculate the consumer surplus using rule of a half since we have several attribute changes in different alternatives.

ParsedUserDefinedParameters=CheckUserDefinedParameters(UserDefinedParameters);
ExtraCostBaseValue=ParsedUserDefinedParameters.ExtraCostBaseValue;
CSorPS=ParsedUserDefinedParameters.CSorPS;
OperationalCost=ParsedUserDefinedParameters.OperationalCost;
BanAvgift=ParsedUserDefinedParameters.BanAvgift;

DecisionVariableNames=fieldnames(DecisionVariable);
for i=1:length(DecisionVariableNames)
    DecisionVariable.(DecisionVariableNames{i})=DecisionVariableValues(i);
end
UpdatedModel=UppdateModel(Model,DecisionVariable);
[CapacitatedDemandTrialSolution,CapacitatedUtilityTrialSolution,CSTrialSolution]=CalculateDemandLogit(UpdatedModel);

% CSTrialSolution=((1/UpdatedModel.UtilityScaleParameter)).*LogsumTrialSolution;
% [CapacitatedDemandTrialSolution,CapacitatedUtilityTrialSolution,UpdatedModel,~,~,CSTrialSolution]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
% clear NewTrialModel
ObjectiveFunctionFinal={};
% Consumer surplus part
CSBase=ObjectiveFunctionBaseline.CS;

% Rule of a half
% [CSTrialSolution, CS_RuleOfHalf]=ConsumerSurplus(DecisionVariable,Model,UpdatedModel);

[CapacitatedDemandBaseline,CapacitatedUtilityBaseline,~]=CalculateDemandLogit(Model);
CS_RuleOfHalf=0;
UtilityScaleParameter=UpdatedModel.UtilityScaleParameter;
for i=1:length(AlternativeNames)
    if strfind(AlternativeNames{i},'Private')
        CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(1)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
          (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
    elseif strfind(AlternativeNames{i},'Business')
        CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(2)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
          (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
    end
    
end
ObjectiveFunctionFinal.CS=CSTrialSolution;

%% choose to use Rule-of-a-half or logsum to calculate consumer surplus
% % change here for using rule-of-a-half
% CapacitatedDemandBaseline=ObjectiveFunctionBaseline.CapacitatedDemandBaseline;
% CapacitatedUtilityBaseline=ObjectiveFunctionBaseline.CapacitatedUtilityBaseline;
% CSDiff=0;
% for i=1:length(AlternativeNames)
%     CSDiff=CSDiff+100.*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
%           (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
% end

% change here for using logsum
% CSDiff=CSTrialSolution-CSBase;
% CSDiff=CS_RuleOfHalf;
CSDiff=CSTrialSolution-CSBase;


CostPrivatePeakRail=UpdatedModel.Supply.Private.Peak.Rail('CostPrivatePeakRail');
CostBusinessPeakRail=UpdatedModel.Supply.Business.Peak.Rail('CostBusinessPeakRail');
% fprintf('%+8.3f %+8.3f %+8.3f %+8.3f\n', CostPrivatePeakRail(2),CostBusinessPeakRail(2),CSTrialSolution-CSBase,CS_RuleOfHalf);
% fprintf('%+8.3f %+8.3f\n',   CSTrialSolution,CSBase);
%%
% revenue part
RevenueBase=ObjectiveFunctionBaseline.Revenue; 

GetSupplyInfo={};
GetSupplyInfo.('CostPrivatePeakRail')=1;
GetSupplyInfo.('CostPrivateOffpeakRail')=1;
GetSupplyInfo.('CostBusinessPeakRail')=1;
GetSupplyInfo.('CostBusinessOffpeakRail')=1;
GetSupplyInfo.('DiscomfortCostPrivatePeakRail')=1;
GetSupplyInfo.('DiscomfortCostPrivateOffpeakRail')=1;
GetSupplyInfo.('DiscomfortCostBusinessPeakRail')=1;
GetSupplyInfo.('DiscomfortCostBusinessOffpeakRail')=1;
CostValues=GetAttribute(UpdatedModel,GetSupplyInfo);

RevenueTrialSolution=(CostValues.('CostPrivatePeakRail')+ExtraCostBaseValue(1).*CostValues.('DiscomfortCostPrivatePeakRail')).*(CapacitatedDemandTrialSolution.('Private_Peak_Rail'))+...
            (CostValues.('CostPrivateOffpeakRail')+ExtraCostBaseValue(2).*CostValues.('DiscomfortCostPrivateOffpeakRail')).*(CapacitatedDemandTrialSolution.('Private_Offpeak_Rail'))+...
            (CostValues.('CostBusinessPeakRail')+ExtraCostBaseValue(3).*CostValues.('DiscomfortCostBusinessPeakRail')).*(CapacitatedDemandTrialSolution.('Business_Peak_Rail'))+...
            (CostValues.('CostBusinessOffpeakRail')+ExtraCostBaseValue(4).*CostValues.('DiscomfortCostBusinessOffpeakRail')).*(CapacitatedDemandTrialSolution.('Business_Offpeak_Rail'));
        
ObjectiveFunctionFinal.Revenue=RevenueTrialSolution;
RevenueDiff=RevenueTrialSolution-RevenueBase;


% Operational cost part
OperationalCostBase=ObjectiveFunctionBaseline.OperationalCost; 
GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimePeakRail')=1;
GetSupplyInfo.('FirstWaitTimeOffpeakRail')=1;
WaitingTime=table2array(GetAttribute(UpdatedModel,GetSupplyInfo));
% OperationalCostTrialSolution=(60.*7/WaitingTime(1)+60.*9/WaitingTime(2)).*(((31.83+(278*0.12))*455)+(((94.44+(278*0.32))*180)));
% OperationalCostTrialSolution=(60.*7/WaitingTime(1)).*((78812+BanAvgift(1)).*1.33-BanAvgift(1))+60.*9/WaitingTime(2).*((78812+BanAvgift(2)).*0.67-BanAvgift(1));
% OperationalCostTrialSolution=(60.*7/WaitingTime(1)).*((78812+BanAvgift(1)).*1.44-BanAvgift(1))+60.*9/WaitingTime(2).*((78812+BanAvgift(2)).*0.56-BanAvgift(2));
% OperationalCostTrialSolution=(60.*7/WaitingTime(1)).*((62673+BanAvgift(1)).*1.33-BanAvgift(1))+60.*9/WaitingTime(2).*((62673+BanAvgift(2)).*0.67-BanAvgift(2));
OperationalCostTrialSolution=(60.*7/WaitingTime(1)/2).*OperationalCost(1)+(60.*9/WaitingTime(2)/2).*OperationalCost(2);  % true value 78489
ObjectiveFunctionFinal.OperationalCost=OperationalCostTrialSolution;
OperationalCostDiff=OperationalCostTrialSolution-OperationalCostBase;

% BanAvgift part
BanAvgiftBase=ObjectiveFunctionBaseline.BanAvgift;
if strcmp(CSorPS,'CS')==1
    BanAvgiftTrialSolution=(60.*7/WaitingTime(1)/2).*BanAvgift(1)+(60.*9/WaitingTime(2)/2).*BanAvgift(2);
elseif strcmp(CSorPS,'PS')==1
    BanAvgiftTrialSolution=(60.*7/WaitingTime(1)/2).*BanAvgift(1)+(60.*9/WaitingTime(2)/2).*BanAvgift(2);
elseif strcmp(CSorPS,'CS_1a')==1 || strcmp(CSorPS,'PS_1a')==1
    BanAvgiftTrialSolution=(60.*7/WaitingTime(1)/2).*(BanAvgift(1)+3000*2)+(60.*9/WaitingTime(2)/2).*(BanAvgift(2)+3000*2);
elseif strcmp(CSorPS,'CS_2a')==1 || strcmp(CSorPS,'PS_2a')==1
    BanAvgiftTrialSolution=(60.*7/WaitingTime(1)/2).*(BanAvgift(1)+3000*5)+(60.*9/WaitingTime(2)/2).*(BanAvgift(2)+3000*5);
elseif strcmp(CSorPS,'CS_3a')==1 || strcmp(CSorPS,'PS_3a')==1
    BanAvgiftTrialSolution=(60.*7/WaitingTime(1)/2).*(BanAvgift(1)+3000*5)+(60.*9/WaitingTime(2)/2).*(BanAvgift(2)+3000*2);
end
% BanAvgiftTrialSolution=(60.*7/WaitingTime(1)/2).*BanAvgift(1)+(60.*9/WaitingTime(2)/2).*BanAvgift(2);
ObjectiveFunctionFinal.BanAvgift=BanAvgiftTrialSolution;
BanAvgiftDiff=BanAvgiftTrialSolution-BanAvgiftBase;

if strcmp(CSorPS,'CS')==1 || strcmp(CSorPS,'CS_1a')==1 || strcmp(CSorPS,'CS_2a')==1 || strcmp(CSorPS,'CS_3a')==1
    MinusWelfare=-(CSDiff+RevenueDiff-OperationalCostDiff-BanAvgiftDiff);  % change the objective function "+CS"
    ObjectiveFunctionFinal.ObjectiveFunction=CSBase+RevenueBase-OperationalCostBase-BanAvgiftBase-MinusWelfare;
elseif strcmp(CSorPS,'PS')==1 || strcmp(CSorPS,'PS_1a')==1 || strcmp(CSorPS,'PS_2a')==1 || strcmp(CSorPS,'PS_3a')==1
    MinusWelfare=-(RevenueDiff-OperationalCostDiff-BanAvgiftDiff);  % change the objective function "+CS"
    ObjectiveFunctionFinal.ObjectiveFunction=RevenueBase-OperationalCostBase-BanAvgiftBase-MinusWelfare;
end



return


function [c,ceq]=CapacityConstraints(DecisionVariableValues,Model,DecisionVariable,UserDefinedParameters)

ParsedUserDefinedParameters=CheckUserDefinedParameters(UserDefinedParameters);
SeatCapacity=ParsedUserDefinedParameters.SeatCapacity;
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
GetSupplyInfo.('FirstWaitTimeOffpeakBus')=1;
GetSupplyInfo.('FrequencyWaitTimePeakAir')=1;
GetSupplyInfo.('FrequencyWaitTimeOffpeakAir')=1;
UpdatedWaitingTime=table2array(GetAttribute(ConstraintModel,GetSupplyInfo));
UpdatedCapacity=[];  % capacity for the capacity constraints
%% important to update the capacity using number of seats here
UpdatedCapacity(1)=60.*7/UpdatedWaitingTime(1)/2.*SeatCapacity(1);   
UpdatedCapacity(2)=60.*9/UpdatedWaitingTime(2)/2.*SeatCapacity(2);
UpdatedCapacity(3)=60.*7/UpdatedWaitingTime(3)/2.*120;
UpdatedCapacity(4)=60.*9/UpdatedWaitingTime(4)/2.*120;
UpdatedCapacity(5)=60.*7/UpdatedWaitingTime(5)/2.*900;
UpdatedCapacity(6)=60.*9/UpdatedWaitingTime(6)/2.*900;
%%
[CapacitatedDemandConstraint,~,~]=CalculateDemandLogit(ConstraintModel);
c(1)=CapacitatedDemandConstraint.('Private_Peak_Rail')+CapacitatedDemandConstraint.('Business_Peak_Rail')-UpdatedCapacity(1);
c(2)=CapacitatedDemandConstraint.('Private_Offpeak_Rail')+CapacitatedDemandConstraint.('Business_Offpeak_Rail')-UpdatedCapacity(2);
c(3)=CapacitatedDemandConstraint.('Private_Peak_Bus')+CapacitatedDemandConstraint.('Business_Peak_Bus')-UpdatedCapacity(3);
c(4)=CapacitatedDemandConstraint.('Private_Offpeak_Bus')+CapacitatedDemandConstraint.('Business_Offpeak_Bus')-UpdatedCapacity(4);
c(5)=CapacitatedDemandConstraint.('Private_Peak_Air')+CapacitatedDemandConstraint.('Business_Peak_Air')-UpdatedCapacity(5);
c(6)=CapacitatedDemandConstraint.('Private_Offpeak_Air')+CapacitatedDemandConstraint.('Business_Offpeak_Air')-UpdatedCapacity(6);

[DiscomfortDiff]=DiscomfortDifference(ConstraintModel,UserDefinedParameters);
for i=1:length(DiscomfortDiff)
    ceq(i)=DiscomfortDiff(i);
end

clear ConstraintModel
return 



