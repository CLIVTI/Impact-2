function [ParameterAttribute]=GetParameter(Supply,UpdateInfo)
% a short function to update the supply given the UpdateInfo
% UpdateInfo has the following structure:
% UpdateInfo.VarName=Numeric.
UpdatedSupply=CopySupply(Supply);
Update_VarNames=fieldnames(UpdateInfo);

[VarNamesStack,AlternativeStack]=CheckSupply(Supply);
ParameterAttribute=zeros(length(Update_VarNames),1);


for i=1:length(Update_VarNames)
    NotInSupplyFlag=0;
   if ismember(Update_VarNames{i},VarNamesStack)==0
       NotInSupplyFlag=1;
   else
       AlternativeToGet=AlternativeStack(ismember(VarNamesStack,Update_VarNames{i}));
       for j=1:length(AlternativeToGet)
           if isa(AlternativeToGet{j},'char')
               ParameterValuePair=UpdatedSupply.(AlternativeToGet{j})(Update_VarNames{i});
               if length(ParameterValuePair)==2
                   ParameterAttribute(i)=ParameterValuePair(1);
               else
                   ParameterAttribute(i)=ParameterValuePair(1);
               end
               
           else
               ParameterValuePair=UpdatedSupply.(AlternativeToGet{j}{1}).(AlternativeToGet{j}{2})(Update_VarNames{i});
               if length(ParameterValuePair)==2
                   ParameterAttribute(i)=ParameterValuePair(1);
               else
                   ParameterAttribute(i)=ParameterValuePair(1);
               end   
           end
       end
   end

   if NotInSupplyFlag==1
     fprintf('Variable:  %-8s is missing in both supply and population data.  \n', Update_VarNames{i}) 
   end
end

ParameterAttribute=array2table(ParameterAttribute','VariableNames',Update_VarNames);

return