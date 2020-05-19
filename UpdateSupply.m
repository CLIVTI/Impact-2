function [UpdatedSupply,UppdatedPopulation]=UpdateSupplyPopulation(Supply,Population,UpdateInfo)
% a short function to update the supply given the UpdateInfo
% UpdateInfo has the following structure:
% UpdateInfo.VarName=Numeric.
UpdatedSupply=CopySupply(Supply);
UppdatedPopulation=Population;
Update_VarNames=fieldnames(UpdateInfo);

[VarNamesStack,AlternativeStack]=CheckSupply(Supply);

for i=1:length(Update_VarNames)
   if ismember(Update_VarNames{i},VarNamesStack)==0
       fprintf('Attribute: %-15s is not included in the supply data!! \n', Update_VarNames{i} )
   else
       AlternativeToUppdate=AlternativeStack(ismember(VarNamesStack,Update_VarNames{i}));
       for j=1:length(AlternativeToUppdate)
           if isa(AlternativeToUppdate{j},'char')
               ParameterValuePair=UpdatedSupply.(AlternativeToUppdate{j})(Update_VarNames{i});
               if length(ParameterValuePair)==2
                   ParameterValuePair(2)=UpdateInfo.(Update_VarNames{i});
                   UpdatedSupply.(AlternativeToUppdate{j})(Update_VarNames{i})=ParameterValuePair;
               else
                   UppdatedPopulation.(Update_VarNames{i})=UpdateInfo.(Update_VarNames{i});
               end
               
           else
               ParameterValuePair=UpdatedSupply.(AlternativeToUppdate{j}{1}).(AlternativeToUppdate{j}{2})(Update_VarNames{i});
               if length(ParameterValuePair)==2
                   ParameterValuePair=UpdatedSupply.(AlternativeToUppdate{j}{1}).(AlternativeToUppdate{j}{2})(Update_VarNames{i});
                   ParameterValuePair(2)=UpdateInfo.(Update_VarNames{i});
                   UpdatedSupply.(AlternativeToUppdate{j}{1}).(AlternativeToUppdate{j}{2})(Update_VarNames{i})=ParameterValuePair;
               else
                  UppdatedPopulation.(Update_VarNames{i})=UpdateInfo.(Update_VarNames{i});
               end  
           end
       end
   end

end


return