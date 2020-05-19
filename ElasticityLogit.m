function [Elasticity,DemandShift]=ElasticityLogit(Model)
% this function returns elasticity for the whole population
% elasticity already *100%
ModelDemandInitial=CalculateDemandLogit(Model);
AlternativeNames=ModelDemandInitial.Properties.VariableNames;
[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);


%% elasticity calculation
NameList={};
UniqueVarNames=unique(VarNamesStack,'stable');
DemandChange=zeros(sum(~ismember(UniqueVarNames,'ScaleParameter')),size(ModelDemandInitial,2));
Elasticity_Var_i=zeros(sum(~ismember(UniqueVarNames,'ScaleParameter')),size(ModelDemandInitial,2));
count=0;
for i=1:length(UniqueVarNames)
    ModelCopy=CopyModel(Model);
    if ~strcmp(UniqueVarNames{i},'ScaleParameter')
        count=count+1;
        NameList{end+1}=UniqueVarNames{i};
        if sum(ismember(VarNamesStack,UniqueVarNames{i}))==1
            IndexVar_i=find(ismember(VarNamesStack,UniqueVarNames{i}));
            if ~strcmp(AlternativeStack_Nest2{IndexVar_i},'')
                ParameterValuePair=Model.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i}).(AlternativeStack_Nest2{IndexVar_i})(UniqueVarNames{i});
                ParameterValuePair(2)=ParameterValuePair(2)*1.01;
                ModelCopy.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i}).(AlternativeStack_Nest2{IndexVar_i})(UniqueVarNames{i})=ParameterValuePair;
            else
                ParameterValuePair=Model.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i})(UniqueVarNames{i});
                ParameterValuePair(2)=ParameterValuePair(2)*1.01;
                ModelCopy.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i})(UniqueVarNames{i})=ParameterValuePair;
            end
        elseif sum(ismember(VarNamesStack,UniqueVarNames{i}))>1
            IndexVar_is=find(ismember(VarNamesStack,UniqueVarNames{i}));
            for j=1:length(IndexVar_is)
                IndexVar_i=IndexVar_is(j);
                if ~strcmp(AlternativeStack_Nest2{IndexVar_i},'')
                    ParameterValuePair=Model.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i}).(AlternativeStack_Nest2{IndexVar_i})(UniqueVarNames{i});
                    ParameterValuePair(2)=ParameterValuePair(2)*1.01;
                    ModelCopy.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i}).(AlternativeStack_Nest2{IndexVar_i})(UniqueVarNames{i})=ParameterValuePair;
                else
                    ParameterValuePair=Model.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i})(UniqueVarNames{i});
                    ParameterValuePair(2)=ParameterValuePair(2)*1.01;
                    ModelCopy.Supply.(DemandSegmentStack{IndexVar_i}).(AlternativeStack_Nest1{IndexVar_i})(UniqueVarNames{i})=ParameterValuePair;
                end
            end 
        end
        ModelDemandChanged=CalculateDemandLogit(ModelCopy);
        DemandChange(count,:)=(table2array(ModelDemandChanged)-table2array(ModelDemandInitial));
        Elasticity_Var_i(count,:)=(table2array(ModelDemandChanged)-table2array(ModelDemandInitial))./(table2array(ModelDemandInitial)).*100; 
    end
    clear ModelCopy
end

DemandShift=array2table(DemandChange,'RowNames',NameList,'VariableNames',AlternativeNames);
Elasticity=array2table(Elasticity_Var_i,'RowNames',NameList,'VariableNames',AlternativeNames);


return