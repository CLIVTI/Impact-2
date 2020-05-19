function Elasticity=ElasticityMNL(Supply,Population)
% this function returns elasticity for the whole population
ModeShareBase=ApplyMNL(Supply,Population);

ModeAlternatives=fieldnames(Supply);
VarNamesStack={};
AlternativeStack={};

for i=1:length(ModeAlternatives)
    VarNames_Alternative_i=fieldnames(Supply.(ModeAlternatives{i}));
    VarNamesStack=[VarNamesStack;VarNames_Alternative_i]; 
    AlternativeStack=[AlternativeStack;repmat({ModeAlternatives{i}},[length(VarNames_Alternative_i),1])];
end
count=0;
NameList={};
UniqueVarNames=unique(VarNamesStack);
for i=1:length(UniqueVarNames)
    FlagIsSupply=0;   % flag to denote if the given variable is a supply variable
    SupplyChange=Supply;
    if sum(ismember(VarNamesStack,UniqueVarNames{i}))>0
        AlternativeName=AlternativeStack(ismember(VarNamesStack,UniqueVarNames{i}));
        for j=1:length(AlternativeName)
            FieldsInAlternative_1=fieldnames(Supply.(AlternativeName{j}).(UniqueVarNames{i}));
            if ismember('Attribute',FieldsInAlternative_1)
                SupplyChange.(AlternativeName{j}).(UniqueVarNames{i}).Attribute=Supply.(AlternativeName{j}).(UniqueVarNames{i}).Attribute.*1.1;
                FlagIsSupply=1;
            end      
        end
    end
    if FlagIsSupply==1
       count=count+1;
       ModeShareChange=ApplyMNL(SupplyChange,Population);
       Elasticity_Var_i(count,:)=(ModeShareChange-ModeShareBase)';
       NameList=[NameList,UniqueVarNames{i}];
    end   
end
Elasticity=array2table(Elasticity_Var_i,'RowNames',NameList,'VariableNames',ModeAlternatives);


return