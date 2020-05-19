function [CapacitatedDemand,CapacitatedUtility,UpdatedModel,ComfortBefore,ComfortAfter,ConsumerSurplus]=CalculateCapacitatedDemand(Model,UserDefinedParameters)
% this function returns the capacitated demand 
% PeakRailDiscomfort and OffpeakRailDiscomfort are two strings telling you which variable name it is.
% congestion
% 

%% parse the user-defined parameters
ParsedUserDefinedParameters=CheckUserDefinedParameters(UserDefinedParameters);
DCVarName=ParsedUserDefinedParameters.DCVarName;
DCValue=ParsedUserDefinedParameters.DCValue;
SeatCapacity=ParsedUserDefinedParameters.SeatCapacity;
%% star the actual job

RailDiscomfort=DCVarName;
startValue=zeros(1,length(RailDiscomfort));
for i=1:length(RailDiscomfort)
    GetSupplyInfo={};
    GetSupplyInfo.(RailDiscomfort{i})=0;
    startValue(i)=table2array(GetAttribute(Model,GetSupplyInfo));
end

ParsedDiscomfort={};
for i=1:length(RailDiscomfort)
    ParsedDiscomfort.(RailDiscomfort{i})=ParseDiscomfortAttributes(Model, RailDiscomfort{i});
end

ComfortBefore=array2table(startValue,'VariableNames',RailDiscomfort);
%%

options = optimset('GradObj','off','LargeScale','off','Display','off','TolFun',1e-6,'TolX',1e-6','MaxFunEvals',10000,'MaxIter',3000);
 [FinalDiscomfortValue,fval,~,output,~,~]= fminunc(@(DiscomfortValue)DiscomfortDiff(Model,DiscomfortValue,ParsedDiscomfort,SeatCapacity,DCValue),startValue ,options); % '@' is a handle for the LogLikelihood below

ComfortAfter=array2table(FinalDiscomfortValue,'VariableNames',RailDiscomfort);
RailDiscomfort=fieldnames(ParsedDiscomfort);
UpdateSupplyInfo={};
for i=1:length(RailDiscomfort)
    UpdateSupplyInfo.(RailDiscomfort{i})=FinalDiscomfortValue(i);
end

UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);
[CapacitatedDemand,CapacitatedUtility,ConsumerSurplus]=CalculateDemandLogit(UpdatedModel);
DIFF=DiscomfortDiff(Model,FinalDiscomfortValue,ParsedDiscomfort,SeatCapacity,DCValue);
if abs(DIFF)>1e-4
    fprintf('Alarm: Convergence Discomfort is %+8.8f \n',  DIFF)
end

return

function Diff=DiscomfortDiff(Model,DiscomfortValue,ParsedDiscomfort,SeatCapacity,DCValue)
% update the structure with the value
RailDiscomfort=fieldnames(ParsedDiscomfort);
UpdateSupplyInfo={};
for i=1:length(RailDiscomfort)
    UpdateSupplyInfo.(RailDiscomfort{i})=DiscomfortValue(i);
end

UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);
UpdatedDemand=CalculateDemandLogit(UpdatedModel);

DiscomfortValue_FromDemand=zeros(1,length(RailDiscomfort));

for i=1:length(RailDiscomfort)
    ParsedDiscomfortVar=ParsedDiscomfort.(RailDiscomfort{i});
    DemandSumVar=0;
    Nvar=ParsedDiscomfortVar.Nvar;
    if Nvar>1
        for j=1:Nvar
            if ~strcmp(ParsedDiscomfortVar.AlternativeStack_Nest2_RailDiscomfort{j},'')
                AlternativeName=strcat(ParsedDiscomfortVar.DemandSegmentRailDiscomfort{j},'_',ParsedDiscomfortVar.AlternativeStack_Nest1_RailDiscomfort{j},'_',ParsedDiscomfortVar.AlternativeStack_Nest2_RailDiscomfort{j});
                DemandSumVar=DemandSumVar+UpdatedDemand.(AlternativeName);
            else
                AlternativeName=strcat(ParsedDiscomfortVar.DemandSegmentRailDiscomfort{j},'_',ParsedDiscomfortVar.AlternativeStack_Nest1_RailDiscomfort{j});
                DemandSumVar=DemandSumVar+UpdatedDemand.(AlternativeName);
            end
        end
    else
        if ~strcmp(ParsedDiscomfortVar.AlternativeStack_Nest2_RailDiscomfort,'')
            AlternativeName=strcat(ParsedDiscomfortVar.DemandSegmentRailDiscomfort,'_',ParsedDiscomfortVar.AlternativeStack_Nest1_RailDiscomfort,'_',ParsedDiscomfortVar.AlternativeStack_Nest2_RailDiscomfort);
            DemandSumVar=DemandSumVar+UpdatedDemand.(AlternativeName);
        else
            AlternativeName=strcat(ParsedDiscomfortVar.DemandSegmentRailDiscomfort,'_',ParsedDiscomfortVar.AlternativeStack_Nest1_RailDiscomfort);
            DemandSumVar=DemandSumVar+UpdatedDemand.(AlternativeName);
        end
    end

    
    
    if strcmp(AlternativeName,'Private_Peak_Rail')
        DemandSumVar=DemandSumVar+UpdatedDemand.('Business_Peak_Rail');
    elseif strcmp(AlternativeName,'Business_Peak_Rail')
        DemandSumVar=DemandSumVar+UpdatedDemand.('Private_Peak_Rail');
    elseif strcmp(AlternativeName,'Private_Offpeak_Rail')
        DemandSumVar=DemandSumVar+UpdatedDemand.('Business_Offpeak_Rail');
    elseif strcmp(AlternativeName,'Business_Offpeak_Rail')
        DemandSumVar=DemandSumVar+UpdatedDemand.('Private_Offpeak_Rail');
    end
    
    
    try
       DemandSegmentName=ParsedDiscomfort.(RailDiscomfort{i}).DemandSegmentRailDiscomfort{1};
       NestName_1=ParsedDiscomfort.(RailDiscomfort{i}).AlternativeStack_Nest1_RailDiscomfort{1};
       NestName_2=ParsedDiscomfort.(RailDiscomfort{i}).AlternativeStack_Nest2_RailDiscomfort{1};
    catch
       DemandSegmentName=ParsedDiscomfort.(RailDiscomfort{i}).DemandSegmentRailDiscomfort;
       NestName_1=ParsedDiscomfort.(RailDiscomfort{i}).AlternativeStack_Nest1_RailDiscomfort;
       NestName_2=ParsedDiscomfort.(RailDiscomfort{i}).AlternativeStack_Nest2_RailDiscomfort;
    end
    
    if  isempty(NestName_2)==1
        VarNamesUtility=UpdatedModel.Supply.(DemandSegmentName).(NestName_1).keys;
    else
        VarNamesUtility=UpdatedModel.Supply.(DemandSegmentName).(NestName_1).(NestName_2).keys;
    end
    
    for k=1:length(VarNamesUtility)  % loop each variable name in the utility function and find the one with FirstWaitTime
        if isempty(strfind(VarNamesUtility{k}, 'FirstWaitTime'))==0
           VarNameFrequency=VarNamesUtility{k};
           break
        end
    end
    
    if  isempty(NestName_2)==1
        ParameterValuePair=UpdatedModel.Supply.(DemandSegmentName).(NestName_1)(VarNameFrequency);
    else
        ParameterValuePair=UpdatedModel.Supply.(DemandSegmentName).(NestName_1).(NestName_2)(VarNameFrequency);
    end
    
    if strcmp(NestName_1,'Peak')
        Frequency=7*60/ParameterValuePair(2)/2;
        DiscomfortValue_FromDemand(i)=(DemandSumVar./(SeatCapacity(1).*Frequency));
    elseif strcmp(NestName_1,'Offpeak')
        Frequency=9*60/ParameterValuePair(2)/2;
        DiscomfortValue_FromDemand(i)=(DemandSumVar./(SeatCapacity(2).*Frequency));
    else
        Frequency=1*60/ParameterValuePair(2)/2;
        DiscomfortValue_FromDemand(i)=(DemandSumVar./(SeatCapacity(1).*Frequency));
    end 
    
end


Diff=sum((log(DiscomfortValue+1)./log(DCValue)-DiscomfortValue_FromDemand).^2);
clear UpdatedModel
return


% function [c,ceq]=Constraints(Model,DiscomfortValue,ParsedDiscomfort,SeatCapacity,DCValue)
% c=[];
% ceq=[];
% RailDiscomfort=fieldnames(ParsedDiscomfort);
% UpdateSupplyInfo={};
% for i=1:length(RailDiscomfort)
%     UpdateSupplyInfo.(RailDiscomfort{i})=DiscomfortValue(i);
% end
% 
% UpdatedModel=UppdateModel(Model,UpdateSupplyInfo);
% UpdatedDemand=CalculateDemandLogit(UpdatedModel);
% 
% GetSupplyInfo={};
% GetSupplyInfo.FirstWaitTimePeakRail=1;
% WaitTime=table2array(GetAttribute(UpdatedModel,GetSupplyInfo));
% FrequencyPeak=WaitTimeToFrequency(WaitTime);
% c(1)=UpdatedDemand.('Private_Peak_Rail')+UpdatedDemand.('Business_Peak_Rail')-FrequencyPeak*7.*SeatCapacity(1);
% 
% GetSupplyInfo={};
% GetSupplyInfo.FirstWaitTimeOffpeakRail=1;
% WaitTime=table2array(GetAttribute(UpdatedModel,GetSupplyInfo));
% FrequencyOffpeak=WaitTimeToFrequency(WaitTime);
% c(2)=UpdatedDemand.('Private_Offpeak_Rail')+UpdatedDemand.('Business_Offpeak_Rail')-FrequencyOffpeak*9.*SeatCapacity(2);
% return

function [ParsedDiscomfort]=ParseDiscomfortAttributes(Model,DiscomfortName)
ParsedDiscomfort={};
[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);

VarNamesRailDiscomfort=DiscomfortName;
LocationIndex=find(ismember(VarNamesStack,DiscomfortName));
if length(LocationIndex)>1
    DemandSegmentStackRailDiscomfort={};
    AlternativeStack_Nest1_RailDiscomfort={};
    AlternativeStack_Nest2_RailDiscomfort={};
    for i=1:length(LocationIndex)
        DemandSegmentStackRailDiscomfort{end+1}=DemandSegmentStack{LocationIndex(i)};
        AlternativeStack_Nest1_RailDiscomfort{end+1}=AlternativeStack_Nest1{LocationIndex(i)};
        AlternativeStack_Nest2_RailDiscomfort{end+1}=AlternativeStack_Nest2{LocationIndex(i)};
        if i==1
            if ~strcmp(AlternativeStack_Nest2{LocationIndex(i)},'')
                ParamaterValuePair=Model.Supply.(DemandSegmentStack{LocationIndex(i)}).(AlternativeStack_Nest1{LocationIndex(i)}).(AlternativeStack_Nest2{LocationIndex(i)})(VarNamesRailDiscomfort);
                ParameterDiscomfort=ParamaterValuePair(2);
            else
                ParamaterValuePair=Model.Supply.(DemandSegmentStack{LocationIndex(i)}).(AlternativeStack_Nest1{LocationIndex(i)})(VarNamesRailDiscomfort);
                ParameterDiscomfort=ParamaterValuePair(2);
            end
        else
            if ~strcmp(AlternativeStack_Nest2{LocationIndex(i)},'')
                ParamaterValuePair=Model.Supply.(DemandSegmentStack{LocationIndex(i)}).(AlternativeStack_Nest1{LocationIndex(i)}).(AlternativeStack_Nest2{LocationIndex(i)})(VarNamesRailDiscomfort);
                ParameterDiscomfortToCompare=ParamaterValuePair(2);
            else
                ParamaterValuePair=Model.Supply.(DemandSegmentStack{LocationIndex(i)}).(AlternativeStack_Nest1{LocationIndex(i)})(VarNamesRailDiscomfort);
                ParameterDiscomfortToCompare=ParamaterValuePair(2);
            end
            if ParameterDiscomfort~=ParameterDiscomfortToCompare
               fprintf('Parameter of %15s in the model has different values', VarNamesRailDiscomfort)
            end
        end
    end
else
    DemandSegmentStackRailDiscomfort=DemandSegmentStack{LocationIndex};
    AlternativeStack_Nest1_RailDiscomfort=AlternativeStack_Nest1{LocationIndex};
    AlternativeStack_Nest2_RailDiscomfort=AlternativeStack_Nest2{LocationIndex};
    if ~strcmp(AlternativeStack_Nest2{LocationIndex},'')
        ParamaterValuePair=Model.Supply.(DemandSegmentStack{LocationIndex}).(AlternativeStack_Nest1{LocationIndex}).(AlternativeStack_Nest2{LocationIndex})(VarNamesRailDiscomfort);
        ParameterDiscomfort=ParamaterValuePair(2);
    else
        ParamaterValuePair=Model.Supply.(DemandSegmentStack{LocationIndex}).(AlternativeStack_Nest1{LocationIndex})(VarNamesRailDiscomfort);
        ParameterDiscomfort=ParamaterValuePair(2);
    end
end

ParsedDiscomfort.Nvar=length(LocationIndex);
ParsedDiscomfort.Value=ParameterDiscomfort;
ParsedDiscomfort.VarNamesRailDiscomfort=VarNamesRailDiscomfort;
ParsedDiscomfort.DemandSegmentRailDiscomfort=DemandSegmentStackRailDiscomfort;
ParsedDiscomfort.AlternativeStack_Nest1_RailDiscomfort=AlternativeStack_Nest1_RailDiscomfort;
ParsedDiscomfort.AlternativeStack_Nest2_RailDiscomfort=AlternativeStack_Nest2_RailDiscomfort;
return