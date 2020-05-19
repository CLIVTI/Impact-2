function [SupplyAttribute]=GetAttribute(Model,UpdateInfo)
% a short function to get the supply given the UpdateInfo
% UpdateInfo has the following structure:
% UpdateInfo.VarName=Numeric.

Update_VarNames=fieldnames(UpdateInfo);

[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);
SupplyAttribute=zeros(length(Update_VarNames),1);


for i=1:length(Update_VarNames)
   if ismember(Update_VarNames{i},VarNamesStack)==0
   else
       StackIndex=find(ismember(VarNamesStack,Update_VarNames{i}));
       if strcmp(AlternativeStack_Nest2{StackIndex(1)},'')
           ParameterValuePair=Model.('Supply').(DemandSegmentStack{StackIndex(1)}).(AlternativeStack_Nest1{StackIndex(1)})(Update_VarNames{i});
           SupplyAttribute(i)=ParameterValuePair(2);
       else
           ParameterValuePair=Model.('Supply').(DemandSegmentStack{StackIndex(1)}).(AlternativeStack_Nest1{StackIndex(1)}).(AlternativeStack_Nest2{StackIndex(1)})(Update_VarNames{i});
           SupplyAttribute(i)=ParameterValuePair(2);
       end
   end
end

SupplyAttribute=array2table(SupplyAttribute','VariableNames',Update_VarNames);

return