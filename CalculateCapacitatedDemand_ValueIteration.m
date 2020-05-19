function [CapacitatedDemand,SupplyUpdated,TimeTrace]=CalculateCapacitatedDemand_ValueIteration(Supply,Population,VDF,CarTimeVarName,IterDisplay)
% this function returns the capacitated demand 
% CarTimeVarName is a string telling you which variable in Supply is car travel time
MaxIter=300;
ModeAlternatives=fieldnames(Supply);
CarAlternativeNames={};
for i=1:length(ModeAlternatives)
    VarNames_mode_i=fieldnames(Supply.(ModeAlternatives{i}));
    if ismember(CarTimeVarName,VarNames_mode_i)
        CarAlternativeNames=[CarAlternativeNames,ModeAlternatives{i}];
    end
end
CarTimeRelativeDiff=inf;
SupplyUpdated=Supply;
CarTimeNew=SupplyUpdated.(CarAlternativeNames{1}).(CarTimeVarName).Attribute;
Iter=1;
TimeTrace(1)=CarTimeNew;
while CarTimeRelativeDiff>0.01 && Iter<=MaxIter
    CarTimeOld=CarTimeNew;
    UpdateInfo.(CarTimeVarName)=CarTimeOld;
    SupplyUpdated=UpdateSupply(SupplyUpdated,UpdateInfo);
    Demand=CalculateDemandMNL(SupplyUpdated,Population);
    CarDemandTotal=0;
    for i=1:length(CarAlternativeNames)
        CarDemandTotal=CarDemandTotal+Demand.(CarAlternativeNames{i});
    end
    CarTimeNew=VDF(CarDemandTotal);
    TimeTrace(Iter+1)=CarTimeNew;
    CarTimeRelativeDiff=abs((CarTimeNew-CarTimeOld)./CarTimeOld);
    if IterDisplay==true
       fprintf('Number of iterations between demand and supply: %8.0f \n', Iter )
    end

    if Iter==MaxIter
        fprintf('Number of iterations exceeds max iter: %8.0f \n', Iter )
    end
    Iter=Iter+1;
end

if Iter>MaxIter
    CarTimeNew=mean(TimeTrace(end-50:end));
    for j=1:100
        CarTimeOld=CarTimeNew;
        UpdateInfo.(CarTimeVarName)=CarTimeOld;
        SupplyUpdated=UpdateSupply(SupplyUpdated,UpdateInfo);
        Demand=CalculateDemandMNL(SupplyUpdated,Population);
        CarDemandTotal=0;
        for i=1:length(CarAlternativeNames)
            CarDemandTotal=CarDemandTotal+Demand.(CarAlternativeNames{i});
        end
        CarTimeNew=VDF(CarDemandTotal);
        TimeTrace(Iter+1)=CarTimeNew;
        Iter=Iter+1;
    end    
end

for i=1:length(CarAlternativeNames)
    SupplyUpdated.(CarAlternativeNames{i}).(CarTimeVarName).Attribute=CarTimeNew;
end
CapacitatedDemand=CalculateDemandMNL(SupplyUpdated,Population);

return