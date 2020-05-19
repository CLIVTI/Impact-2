function [CS_Logsum, CS_RuleOfHalf]=ConsumerSurplus(DecisionVariable,Model,NewTrialModel)
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
[CapacitatedDemandBaseline,CapacitatedUtilityBaseline,ConsumeSurplus]=CalculateDemandLogit(Model);
ConsumerSurplusBaseline=ConsumeSurplus;
% [CapacitatedDemandBaseline,CapacitatedUtilityBaseline,~,~,~,ConsumerSurplusBaseline]=CalculateCapacitatedDemand(Model,RailDiscomfort,SeatCapacity);
[CapacitatedDemandTrialSolution,CapacitatedUtilityTrialSolution,ConsumeSurplusTrialSolution]=CalculateDemandLogit(NewTrialModel);

% [CapacitatedDemandTrialSolution,CapacitatedUtilityTrialSolution,~,~,~,ConsumerSurplusTrialSolution]=CalculateCapacitatedDemand(NewTrialModel,RailDiscomfort,SeatCapacity);
UtilityScaleParameter=NewTrialModel.UtilityScaleParameter;
CS_RuleOfHalf=0;
for i=1:length(AlternativeNames)
    if strfind(AlternativeNames{i},'Private')
        CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(1)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
          (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
    elseif strfind(AlternativeNames{i},'Business')
        CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(2)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
          (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
    else
        CS_RuleOfHalf=CS_RuleOfHalf+(1./UtilityScaleParameter(1)).*((CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*CapacitatedDemandBaseline.(AlternativeNames{i})+...
          (CapacitatedUtilityTrialSolution.(AlternativeNames{i})-CapacitatedUtilityBaseline.(AlternativeNames{i})).*(CapacitatedDemandTrialSolution.(AlternativeNames{i})-CapacitatedDemandBaseline.(AlternativeNames{i}))./2);
    end
    
end
CS_Logsum=ConsumeSurplusTrialSolution-ConsumerSurplusBaseline;


return