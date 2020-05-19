function CheckModelStructure(Model)
% this function checks the validity of the input model structure.
% specifically it checks:
% 1. whether same attribute names have the same attribute value.
% 2. whether each demand segment has a population size.
%% check if attribute with the same name have the same value
Supply=Model.('Supply');
PopulationSize=Model.('PopulationSize');

DemandSegmentName=fieldnames(Supply);
% check if each demand segment has a population size.
for  i=1:length(DemandSegmentName)
    try
        Population=PopulationSize.(DemandSegmentName{i});
    catch
        warning(fprintf('Demand segment %-15s does not have a population specified.',DemandSegmentName{i}));
        return
    end
end


% check whether same attribute names have the same attribute value

[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);


% check whether all attributes with same name have the same value 
[UniqueVarNames,IA,IC]=unique(VarNamesStack);
for i=1:length(UniqueVarNames)
    if sum(ismember(VarNamesStack,UniqueVarNames{i}))>1 && ~strcmp(UniqueVarNames{i},'ScaleParameter')
        Index_Duplicate=ismember(VarNamesStack,UniqueVarNames{i});
        DemandSegmentName_duplicated=DemandSegmentStack(Index_Duplicate);
        AlternativeStack_Nest1_duplicated=AlternativeStack_Nest1(Index_Duplicate);
        AlternativeStack_Nest2_duplicated=AlternativeStack_Nest2(Index_Duplicate);
        AttributeValue_duplicated=zeros(sum(Index_Duplicate),1);
        for j=1:sum(Index_Duplicate)
            if ~strcmp(AlternativeStack_Nest2_duplicated{j},'')
                ParameterValuePair= Supply.(DemandSegmentName_duplicated{j}).(AlternativeStack_Nest1_duplicated{j}).(AlternativeStack_Nest2_duplicated{j})(UniqueVarNames{i});
                AttributeValue_duplicated(j)=ParameterValuePair(2);
            else
                ParameterValuePair= Supply.(DemandSegmentName_duplicated{j}).(AlternativeStack_Nest1_duplicated{j})(UniqueVarNames{i});
                AttributeValue_duplicated(j)=ParameterValuePair(2);
            end
        end
        if sum(AttributeValue_duplicated==AttributeValue_duplicated(1))~=length(AttributeValue_duplicated)
            fprintf('Attribute %15s does not have same values in the model.', UniqueVarNames{i})
        end
    end
end
        
% if FlagScaleParameter==false
%     fprintf('ScaleParameter must be a variable name in the nested mode alternatives. \n' )
% end

return





