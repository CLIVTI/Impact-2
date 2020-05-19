function [PolulationAttribute]=GetPopulation(Population,UpdateInfo)
% a short function to update the supply given the UpdateInfo
% UpdateInfo has the following structure:
% UpdateInfo.VarName=Numeric.
PopulationSegmentNames=fieldnames(UpdateInfo);

PolulationAttribute={};
for i=1:length(PopulationSegmentNames)
    VarNames=fieldnames(UpdateInfo.(PopulationSegmentNames{i}));
    for j=1:length(VarNames)
        try
            PolulationAttribute.(PopulationSegmentNames{i}).(VarNames{j})=Population.(PopulationSegmentNames{i}).(VarNames{j});
        catch
            fprintf('Variable: %-8s does not appear in population data.  \n', VarNames{j} )
        end
        
    end
    

    
end
return