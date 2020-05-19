function [ObjectiveFunctionBaseline,ObjectiveFunctionFinal,OptimizedDemand,FinalDecisionVariables,UpdatedModel]=OptimizeSupply_ConstraintReformulation_SPD_2(Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS)
% this function optimizes supply given the decision variables specified in DecisionVariable
% DecisionVariable is a structure.

if nargin<7
    CSorPS='CS';
end

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


DecisionVariable.DiscomfortRail=1;
AttributeGet=GetAttribute(Model,DecisionVariable);

startValue=table2array(AttributeGet)';
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
% [CapacitatedDemandBaseline,CapacitatedUtilityBaseline,~,~,~,CSBaseline]=CalculateCapacitatedDemand(Model,RailDiscomfort,SeatCapacity);
[CapacitatedDemandBaseline,CapacitatedUtilityBaseline,CSBaseline]=CalculateDemandLogit(Model);
ObjectiveFunctionBaseline={};
ObjectiveFunctionBaseline.CapacitatedDemandBaseline=CapacitatedDemandBaseline;
ObjectiveFunctionBaseline.CapacitatedUtilityBaseline=CapacitatedUtilityBaseline;
ObjectiveFunctionBaseline.CS=CSBaseline;


GetSupplyInfo={};
GetSupplyInfo.('CostRail')=199;
AttributeGet=GetAttribute(Model,GetSupplyInfo);
CostPrivatePeakRailBase=table2array(AttributeGet);

RevenueBase=CostPrivatePeakRailBase.*(CapacitatedDemandBaseline.('All_Rail'));
ObjectiveFunctionBaseline.Revenue=RevenueBase;        

% calculate the Operational cost.
GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimeRail')=1;
WaitingTime=table2array(GetAttribute(Model,GetSupplyInfo));
OperationalCostBase=(60.*1/WaitingTime(1)/2).*40009;
ObjectiveFunctionBaseline.OperationalCost=OperationalCostBase;

% calculate the BanAvgift
BanAvgiftBase=(60.*1/WaitingTime(1)/2).*BanAvgift(1);
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
lb_noComfort = zeros(1,length(startValue)-1);
lb=[lb_noComfort,-inf];
ub = [];
nonlcon =@(DecisionVariableValues)CapacityConstraints(DecisionVariableValues,Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity);
options = optimset('GradObj','off','LargeScale','off','Display','off','TolFun',1e-6,'TolX',1e-6,'MaxFunEvals',10000,'MaxIter',3000);
[beta,fval,~,output,~,~]= fmincon(@(DecisionVariableValues)ObjectiveFunction(DecisionVariableValues,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,RailDiscomfort,SeatCapacity,BanAvgift,CSorPS),startValue,A,b,Aeq,beq,lb,ub,nonlcon ,options); % '@' is a handle for the LogLikelihood below

[MinusWelfare,OptimizedDemand,UpdatedModel,ObjectiveFunctionFinal]=ObjectiveFunction(beta,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,RailDiscomfort,SeatCapacity,BanAvgift,CSorPS);
WelfareIncrease=-MinusWelfare;
CS=ObjectiveFunctionFinal.CS;
Revenue=ObjectiveFunctionFinal.Revenue;
OperationalCost=ObjectiveFunctionFinal.OperationalCost;
BanAvgift=ObjectiveFunctionFinal.BanAvgift;




FinalDecisionVariables=GetAttribute(UpdatedModel,DecisionVariable);

% % print results
% % print out the final objective function values
% fprintf('\n\n----------------- DISPLAY OBJECTIVE FUNCTION ---------------------')
% fprintf('\n %-15s : %8s %8s\n'    , ['Parameter'],           ['Initial'],     ['OptimalResult'] );
% fprintf('%-15s : %+8.1f %+8.1f \n', 'ObjectiveFunction:',    RevenueBase-OperationalCostBase-BanAvgiftBase,  RevenueBase-OperationalCostBase-BanAvgiftBase+ WelfareIncrease          )
% fprintf('%-15s : %+8.1f %+8.1f \n', 'CS:',                   CSBaseline,              CS    )
% fprintf('%-15s : %+8.1f %+8.1f \n', 'Revenue:',               RevenueBase,     Revenue    )
% fprintf('%-15s : %+8.1f %+8.1f \n', 'OperationalCost:',     OperationalCostBase,         OperationalCost    )
% fprintf('%-15s : %+8.1f %+8.1f \n', 'BanAvgift:',            BanAvgiftBase,              BanAvgift    )
% % print out the final decision variable value
% fprintf('\n\n----------------- DISPLAY DECISION VARIABLES ---------------------')
% fprintf('\n %-15s : %8s %8s \n' , ['Parameter'],['InitialValue'],['Estimates']);
% for i=1:length(beta) 
%     if isempty(strfind(DecisionNames{i} , 'FirstWaitTimeRail'))==0
%         fprintf('%-15s : %+8.3f %+8.3f \n', 'FrequencyRail', 60.*1/startValueDisplay(i)/2 , 60.*1/beta(i)/2)
%     else
%         fprintf('%-15s : %+8.3f %+8.3f \n', DecisionNames{i}, startValueDisplay(i) , beta(i))
%     end
%     
% end
% 
% % print out the capacity of the final model compared to its demand
% [c,~]=CapacityConstraints(beta,UpdatedModel,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity);
% fprintf('\n\n----------------- DISPLAY CAPACITY ---------------------')
% fprintf('\n %-15s : %8s %8s \n' , ['CapacitySegment'],['MaxCapacity'],['Demand']);
% fprintf('%-15s : %+8.2f %+8.2f \n', 'Peak_Rail',     OptimizedDemand.('All_Rail')-c(1) , OptimizedDemand.('All_Rail'))
% output PS for all modes and demand for all modes


return



function [MinusWelfare,CapacitatedDemandTrialSolution,UpdatedModel,ObjectiveFunctionFinal]=ObjectiveFunction(DecisionVariableValues,Model,ObjectiveFunctionBaseline,DecisionVariable,AlternativeNames,RailDiscomfort,SeatCapacity,BanAvgift,CSorPS)
% calculate the consumer surplus using rule of a half since we have several attribute changes in different alternatives.

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
[CSTrialSolution, ~]=ConsumerSurplus(DecisionVariable,Model,UpdatedModel);

% [CapacitatedDemandBaseline,CapacitatedUtilityBaseline,~]=CalculateDemandLogit(Model);
% CS_RuleOfHalf=0;
% UtilityScaleParameter=UpdatedModel.UtilityScaleParameter;
% for i=1:length(AlternativeNames)
%     if strfind(AlternativeNames{i},'Private')
%         CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(1)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
%           (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
%     elseif strfind(AlternativeNames{i},'Business')
%         CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(2)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
%           (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
%     end
%     
% end
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


% CostPrivatePeakRail=UpdatedModel.Supply.Private.Peak.Rail('CostPrivatePeakRail');
% CostBusinessPeakRail=UpdatedModel.Supply.Business.Peak.Rail('CostBusinessPeakRail');
% fprintf('%+8.3f %+8.3f %+8.3f %+8.3f\n', CostPrivatePeakRail(2),CostBusinessPeakRail(2),CSTrialSolution-CSBase,CS_RuleOfHalf);
% fprintf('%+8.3f %+8.3f\n',   CSTrialSolution,CSBase);
%%
% revenue part
RevenueBase=ObjectiveFunctionBaseline.Revenue; 
GetSupplyInfo={};
GetSupplyInfo.CostRail=0;
CostPrivatePeakRailTrialSolution=table2array(GetAttribute(UpdatedModel,GetSupplyInfo));
RevenueTrialSolution=CostPrivatePeakRailTrialSolution.*(CapacitatedDemandTrialSolution.('All_Rail'));

ObjectiveFunctionFinal.Revenue=RevenueTrialSolution;
RevenueDiff=RevenueTrialSolution-RevenueBase;


% Operational cost part
OperationalCostBase=ObjectiveFunctionBaseline.OperationalCost; 
GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimeRail')=1;
WaitingTimeTrialSolution=table2array(GetAttribute(UpdatedModel,GetSupplyInfo));
OperationalCostTrialSolution=(60.*1/WaitingTimeTrialSolution(1)/2).*40009;
ObjectiveFunctionFinal.OperationalCost=OperationalCostTrialSolution;
OperationalCostDiff=OperationalCostTrialSolution-OperationalCostBase;

% BanAvgift part
BanAvgiftBase=ObjectiveFunctionBaseline.BanAvgift;
BanAvgiftTrialSolution=(60.*1/WaitingTimeTrialSolution(1)/2).*BanAvgift(1);
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
GetSupplyInfo.('FirstWaitTimeRail')=1;
UpdatedWaitingTime=table2array(GetAttribute(ConstraintModel,GetSupplyInfo));
UpdatedCapacity=[];  % capacity for the capacity constraints
%% important to update the capacity using number of seats here
UpdatedCapacity(1)=60.*1/UpdatedWaitingTime(1)/2.*MaxSeatCapacity(1);   
%%
[CapacitatedDemandConstraint,~,~]=CalculateDemandLogit(ConstraintModel);
c(1)=CapacitatedDemandConstraint.('All_Rail')-UpdatedCapacity(1);

[DiscomfortDiff]=DiscomfortDifference(ConstraintModel,RailDiscomfort,SeatCapacity);
for i=1:length(DiscomfortDiff)
    ceq(i)=DiscomfortDiff(i);
end

clear ConstraintModel
return 



