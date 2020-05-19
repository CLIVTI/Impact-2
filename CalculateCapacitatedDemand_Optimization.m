function [CapacitatedDemand,SupplyUpdated,TimeDiff]=CalculateCapacitatedDemand_Optimization(Supply,Population,RoadCapacity)
% this function returns the capacitated demand 
% CarTimeVarName is a string telling you which variable in Supply is car travel time
% BusTimeVarName is a string telling you which variable in Supply is bus invehicle time, since bus will also get into
% congestion
CarTimeVarName=RoadCapacity.CarTimeVarName;

try
    BusTimeVarName=RoadCapacity.BusTimeVarName;
catch
    % warning('BusTimeVarName is not specified. Bus time not affected.');
    BusTimeVarName='';
end

VDF=RoadCapacity.VDF;
ModeAlternatives=fieldnames(Supply);
% mode alternatives that involve car time
CarAlternativeNames={};
for i=1:length(ModeAlternatives)
    VarNames_mode_i=fieldnames(Supply.(ModeAlternatives{i}));
    if ismember(CarTimeVarName,VarNames_mode_i)
        CarAlternativeNames=[CarAlternativeNames,ModeAlternatives{i}];
    end
end

BusAlternativeNames={};
for i=1:length(ModeAlternatives)
    VarNames_mode_i=fieldnames(Supply.(ModeAlternatives{i}));
    if ismember(BusTimeVarName,VarNames_mode_i)
        BusAlternativeNames=[BusAlternativeNames,ModeAlternatives{i}];
    end
end

% mode alternatives that involve bus time

SupplyUpdated=Supply;
CarTimeNew=SupplyUpdated.(CarAlternativeNames{1}).(CarTimeVarName).Attribute;

startValue=CarTimeNew;
options = optimset('GradObj','off','LargeScale','off','Display','off','TolFun',1e-4,'TolX',1e-6','MaxFunEvals',10000,'MaxIter',3000);
 [FinalCarTime,fval,~,output,~,~]= fminunc(@(CarTime)CarTimeDiff(Supply,Population,CarTime,CarTimeVarName,BusTimeVarName,CarAlternativeNames,VDF),startValue,options); % '@' is a handle for the LogLikelihood below

TimeDiff=CarTimeDiff(Supply,Population,FinalCarTime,CarTimeVarName,BusTimeVarName,CarAlternativeNames,VDF);


for i=1:length(CarAlternativeNames)
    SupplyUpdated.(CarAlternativeNames{i}).(CarTimeVarName).Attribute=FinalCarTime;
end

for i=1:length(BusAlternativeNames)
    SupplyUpdated.(BusAlternativeNames{i}).(BusTimeVarName).Attribute=FinalCarTime;
end
CapacitatedDemand=CalculateDemandMNL(SupplyUpdated,Population);

return

function TimeDiff=CarTimeDiff(Supply,Population,CarTime,CarTimeVarName,BusTimeVarName,CarAlternativeNames,VDF)
CarTimeOld=CarTime;
UpdateInfo.(CarTimeVarName)=CarTime;
if ~strcmp(BusTimeVarName,'')
    UpdateInfo.(BusTimeVarName)=CarTime;
end
SupplyUpdated=UpdateSupply(Supply,UpdateInfo);
Demand=CalculateDemandMNL(SupplyUpdated,Population);
CarDemandTotal=0;
for i=1:length(CarAlternativeNames)
    CarDemandTotal=CarDemandTotal+Demand.(CarAlternativeNames{i});
end
CarTimeNew=VDF(CarDemandTotal);
TimeDiff=(CarTimeNew-CarTimeOld).^2;
return