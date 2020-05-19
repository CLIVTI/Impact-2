function ModelCopy=CopyModel(Model)
% create another instance of Model structure
ModelCopy={};
ModelCopy.('UtilityScaleParameter')=Model.('UtilityScaleParameter');
PopulationSize=Model.('PopulationSize');
ModelCopy.('PopulationSize')=PopulationSize;

Supply=Model.('Supply');
DemandSegmentName=fieldnames(Supply);
for d=1:length(DemandSegmentName)
    ModeAlternatives=fieldnames(Supply.(DemandSegmentName{d}));
    for i=1:length(ModeAlternatives)
        if  isa(Supply.(DemandSegmentName{d}).(ModeAlternatives{i}),'containers.Map')
            ModelCopy.('Supply').(DemandSegmentName{d}).(ModeAlternatives{i})=containers.Map();
            VarNames_alternative_i=keys(Supply.(DemandSegmentName{d}).(ModeAlternatives{i}));
            for j=1:length(VarNames_alternative_i)
                ParameterValuePair=Supply.(DemandSegmentName{d}).(ModeAlternatives{i})(VarNames_alternative_i{j});
                ModelCopy.('Supply').(DemandSegmentName{d}).(ModeAlternatives{i})(VarNames_alternative_i{j})=ParameterValuePair;
            end
        elseif isa(Supply.(DemandSegmentName{d}).(ModeAlternatives{i}),'struct')
            NestedAlternatives=fieldnames(Supply.(DemandSegmentName{d}).(ModeAlternatives{i}));
            for k=1:length(NestedAlternatives)
                ModelCopy.('Supply').(DemandSegmentName{d}).(ModeAlternatives{i}).(NestedAlternatives{k})=containers.Map();
                VarNames_alternative_i_j=keys(Supply.(DemandSegmentName{d}).(ModeAlternatives{i}).(NestedAlternatives{k}));
                for j=1:length(VarNames_alternative_i_j)
                    ParameterValuePair=Supply.(DemandSegmentName{d}).(ModeAlternatives{i}).(NestedAlternatives{k})(VarNames_alternative_i_j{j});
                    ModelCopy.('Supply').(DemandSegmentName{d}).(ModeAlternatives{i}).(NestedAlternatives{k})(VarNames_alternative_i_j{j})=ParameterValuePair;
                end
            end
        end
        
    end
    
end



return