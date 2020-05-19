function [ObjectiveFunctionBaseline,ObjectiveFunctionFinal,OptimizedDemand_Final,DecisionVariables_Final,UpdatedModel_Final,Elasticity_Final]=OptimizationProblem_SPD_2(Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS)
% wrapper function that calls the Actual optimization function.
[ObjectiveFunctionBaseline,ObjectiveFunctionNonInteger,OptimizedDemandNonInteger,FinalDecisionVariablesNonInteger,~]=...
    OptimizeSupply_ConstraintReformulation_SPD_2(Model,DecisionVariable,RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS);

try
  FrequencyRail_NonInteger=60.*1/FinalDecisionVariablesNonInteger.('FirstWaitTimeRail')/2;
catch
    GetSupplyInfo={};
    GetSupplyInfo.('FirstWaitTimeRail')=1;
    FirstWaitTime=table2array(GetAttribute(Model,GetSupplyInfo));
    FrequencyRail_NonInteger=60.*1/FirstWaitTime(1)/2;
end

FrequencyRail_Lower=floor(FrequencyRail_NonInteger);
FrequencyRail_Upper=floor(FrequencyRail_NonInteger)+1;
FirstWaitTimeRail_Lower=60.*1/FrequencyRail_Lower/2;
FirstWaitTimeRail_Upper=60.*1/FrequencyRail_Upper/2;


% define some structures
ObjectiveFunctionFinalSelection={};
OptimizedDemandSelection={};
FinalDecisionVariablesSelection={};
UpdatedModelSelection={};
FrequencyName={};
% first optimize low 
UpdateSupplyInfo_Low={};
UpdateSupplyInfo_Low.FirstWaitTimeRail=FirstWaitTimeRail_Lower;
ModelFrequency_Low=UppdateModel(Model,UpdateSupplyInfo_Low);

DecisionVariable_Low={};
DecisionVariable_Low.CostRail=1;
[~,ObjectiveFunctionFinal_Low,OptimizedDemand_Low,FinalDecisionVariables_Low,UpdatedModel_Low]=OptimizeSupply_ConstraintReformulation_SPD_2(ModelFrequency_Low,DecisionVariable_Low,RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS);
ObjectiveFunctionFinalSelection.Low=ObjectiveFunctionFinal_Low;
OptimizedDemandSelection.Low=OptimizedDemand_Low;
FinalDecisionVariablesSelection.Low=FinalDecisionVariables_Low;
UpdatedModelSelection.Low=UpdatedModel_Low;
FrequencyName.Low=UpdateSupplyInfo_Low;

% first optimize high 
UpdateSupplyInfo_High={};
UpdateSupplyInfo_High.FirstWaitTimeRail=FirstWaitTimeRail_Upper;
ModelFrequency_High=UppdateModel(Model,UpdateSupplyInfo_High);

DecisionVariable_High={};
DecisionVariable_High.CostRail=1;
[~,ObjectiveFunctionFinal_High,OptimizedDemand_High,FinalDecisionVariables_High,UpdatedModel_High]=OptimizeSupply_ConstraintReformulation_SPD_2(ModelFrequency_High,DecisionVariable_High,RailDiscomfort,SeatCapacity,MaxSeatCapacity,BanAvgift,CSorPS);
ObjectiveFunctionFinalSelection.High=ObjectiveFunctionFinal_High;
OptimizedDemandSelection.High=OptimizedDemand_High;
FinalDecisionVariablesSelection.High=FinalDecisionVariables_High;
UpdatedModelSelection.High=UpdatedModel_High;
FrequencyName.High=UpdateSupplyInfo_High;


% compare and decide which one is the best
ObjectiveFunctionCompare=[ObjectiveFunctionFinal_Low.ObjectiveFunction,ObjectiveFunctionFinal_High.ObjectiveFunction];
[~,BestIndex]=max(ObjectiveFunctionCompare);
StringName={'Low','High'};
% fprintf('The following combination: %-15s has the highest objective function.',StringName{BestIndex})

ObjectiveFunctionFinal=ObjectiveFunctionFinalSelection.(StringName{BestIndex});
OptimizedDemand_Final=OptimizedDemandSelection.(StringName{BestIndex});
DecisionVariables_Final=FinalDecisionVariablesSelection.(StringName{BestIndex});
UpdatedModel_Final=UpdatedModelSelection.(StringName{BestIndex});

% print out the final objective function values
fprintf('\n\n----------------- DISPLAY OBJECTIVE FUNCTION ---------------------')
fprintf('\n%-15s : %8s %8s %8s\n'    , ['Parameter'],           ['Initial'],     ['OptimalResult'], ['Difference'] );
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'ObjectiveFunction:',    ObjectiveFunctionBaseline.ObjectiveFunction,  ObjectiveFunctionFinal.ObjectiveFunction, ObjectiveFunctionFinal.ObjectiveFunction-ObjectiveFunctionBaseline.ObjectiveFunction        )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'CS:',                   ObjectiveFunctionBaseline.CS,              ObjectiveFunctionFinal.CS ,                  ObjectiveFunctionFinal.CS-ObjectiveFunctionBaseline.CS  )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'Revenue:',               ObjectiveFunctionBaseline.Revenue,     ObjectiveFunctionFinal.Revenue,                 ObjectiveFunctionFinal.Revenue-ObjectiveFunctionBaseline.Revenue    )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'OperationalCost:',     ObjectiveFunctionBaseline.OperationalCost,   ObjectiveFunctionFinal.OperationalCost,     ObjectiveFunctionFinal.OperationalCost-ObjectiveFunctionBaseline.OperationalCost    )
fprintf('%-15s : %+8.1f %+8.1f %+8.1f \n', 'BanAvgift:',            ObjectiveFunctionBaseline.BanAvgift,              ObjectiveFunctionFinal.BanAvgift,     ObjectiveFunctionFinal.BanAvgift-ObjectiveFunctionBaseline.BanAvgift    )


% print out the final decision variable value
DecisionVariable.DiscomfortRail=1;
fprintf('\n\n----------------- DISPLAY DECISION VARIABLES ---------------------')
fprintf('\n%-15s : %8s %8s \n' , ['Parameter'],['InitialValue'],['Estimates']);
Varnames=FinalDecisionVariablesNonInteger.Properties.VariableNames;
DecisionVariableBaseline=GetAttribute(Model,DecisionVariable);
for i=1:length(Varnames) 
    if strcmp(Varnames{i},'FirstWaitTimeRail')
         fprintf('%-15s : %+8.3f %+8.3f \n', 'FrequencyPeakRail', 60.*1/DecisionVariableBaseline.(Varnames{i})/2 , 60.*1/FrequencyName.(StringName{BestIndex}).('FirstWaitTimeRail')/2)
    else
         fprintf('%-15s : %+8.3f %+8.3f \n', Varnames{i}, DecisionVariableBaseline.(Varnames{i}) , DecisionVariables_Final.(Varnames{i}))
    end
end


GetSupplyInfo={};
GetSupplyInfo.('FirstWaitTimeRail')=1;
UpdatedWaitingTime=table2array(GetAttribute(UpdatedModel_Final,GetSupplyInfo));

fprintf('\n\n----------------- DISPLAY CAPACITY ---------------------')
fprintf('\n%-15s : %8s %8s %8s \n' , ['CapacitySegment'],['MaxCapacity'],['Demand'],['Occupancy']);
fprintf('%-15s : %+8.2f %+8.2f %+8.2f \n', 'Rail',     60.*1/UpdatedWaitingTime(1)/2.*MaxSeatCapacity(1) , OptimizedDemand_Final.('All_Rail'), OptimizedDemand_Final.('All_Rail')/(60.*1/UpdatedWaitingTime(1)/2.*MaxSeatCapacity(1)))

% Elasticity of the final model
[Elasticity_Final,~]=ElasticityLogit(UpdatedModel_Final);  % elasticity already *100%
% %% result validation
% % 1. consumer surplus difference calculated by rule-of-a-half and logsum
% [CS_logsum,CS_RuleOfHalf]=ConsumerSurplus(DecisionVariable,Model,UpdatedModel_Final);
% fprintf('\n')
% fprintf('CS_with_rule-of-a-half: %+8.3f \n', CS_RuleOfHalf)
% fprintf('CS_with_logsum: %+8.3f \n', CS_logsum)
% 
% % 2. check if the final model satisfies the equality constraints.
% [FinalDiscomfortDiffUnitest]=DiscomfortDifference(UpdatedModel_Final,RailDiscomfort,SeatCapacity);
% FinalDiscomfortDiffUnitest
% % 3. final discomfort variables
% GetSupplyInfo={};
% GetSupplyInfo.('DiscomfortRail')=1;
% DiscomfortRailFinal=GetAttribute(UpdatedModel_Final,GetSupplyInfo)
[ModelDemand,~]=CalculateDemandLogit(Model);
AlternativeNames=ModelDemand.Properties.VariableNames;
fprintf('\n\n----------------- DISPLAY DEMAND ---------------------')
fprintf('\n%-15s : %8s %8s \n' , ['DemandSegment'],['Demand_Initial'],['Demand_Optimal']);
for i=1:length(AlternativeNames)
    fprintf('%-15s : %+8.2f %+8.2f  \n', 'Private_Peak_Rail',   ModelDemand.(AlternativeNames{i}),  OptimizedDemand_Final.(AlternativeNames{i}))

end

return