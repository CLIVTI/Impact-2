function [UpdatedSupply,UppdatedPopulation]=UpdateSupplyPopulation(Supply,Population,UpdateSupplyInfo,UpdatePopulationinfo)
% a short function to update the supply given the UpdateSupplyInfo
% UpdateSupplyInfo has the following structure:
% UpdateSupplyInfo.VarName=Numeric.

if nargin<=3
   UpdatePopulationinfo={};
elseif nargin<=2
    UpdatedSupply=CopySupply(Supply);
    UppdatedPopulation=Population;
    warning('Warning: no supply and population attributes are updated. \n')
    return
elseif nargin<=1
    fprintf('Error: please specify at least UpdateSupplyInfo or UpdatePopulationinfo. \n')
    return
end

UpdatedSupply=CopySupply(Supply);
UppdatedPopulation=Population;


[VarNamesStack,AlternativeStack]=CheckSupply(Supply);
if ~isempty(UpdateSupplyInfo)
    Update_VarNames=fieldnames(UpdateSupplyInfo);
    for i=1:length(Update_VarNames)
        if ismember(Update_VarNames{i},VarNamesStack)==0
            warning('Attribute: %-15s is not included in the supply data!! \n', Update_VarNames{i})
        else
            AlternativeToUppdate=AlternativeStack(ismember(VarNamesStack,Update_VarNames{i}));
            for j=1:length(AlternativeToUppdate)
                if isa(AlternativeToUppdate{j},'char')
                    ParameterValuePair=UpdatedSupply.(AlternativeToUppdate{j})(Update_VarNames{i});
                    if length(ParameterValuePair)==2
                        ParameterValuePair(2)=UpdateSupplyInfo.(Update_VarNames{i});
                        UpdatedSupply.(AlternativeToUppdate{j})(Update_VarNames{i})=ParameterValuePair;
                    else
                         warning('Warning: variable: %-8s appears in population data.Please specify it in UpdatePopulationinfo.', Update_VarNames{i})
                    end
                    
                else
                    ParameterValuePair=UpdatedSupply.(AlternativeToUppdate{j}{1}).(AlternativeToUppdate{j}{2})(Update_VarNames{i});
                    if length(ParameterValuePair)==2
                        ParameterValuePair=UpdatedSupply.(AlternativeToUppdate{j}{1}).(AlternativeToUppdate{j}{2})(Update_VarNames{i});
                        ParameterValuePair(2)=UpdateSupplyInfo.(Update_VarNames{i});
                        UpdatedSupply.(AlternativeToUppdate{j}{1}).(AlternativeToUppdate{j}{2})(Update_VarNames{i})=ParameterValuePair;
                    else
                       warning('Warning: variable: %-8s appears in population data.Please specify it in UpdatePopulationinfo. \n', Update_VarNames{i})
                    end
                end
            end
        end
        
    end
end 

if ~isempty(UpdatePopulationinfo)
    PopulationSegmentNames=fieldnames(UpdatePopulationinfo);
    for i=1:length(PopulationSegmentNames)
        VarNames=fieldnames(UpdatePopulationinfo.(PopulationSegmentNames{i}));
        for j=1:length(VarNames)
            try
                UppdatedPopulation.(PopulationSegmentNames{i}).(VarNames{j})=UpdatePopulationinfo.(PopulationSegmentNames{i}).(VarNames{j});
            catch
                fprintf(' variable: %-8s does not appear in population data.  \n', VarNames{j} )
            end
            
        end
    end
end



return