function [ModelCopy]=UppdateModel(Model,UpdateInfo)
% a short function to get the supply given the UpdateInfo
% UpdateInfo has the following structure:
% UpdateInfo.VarName=Numeric.'

ModelCopy=CopyModel(Model);
Update_VarNames=fieldnames(UpdateInfo);

[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);
for i=1:length(Update_VarNames)
   if ismember(Update_VarNames{i},VarNamesStack)==0
      fprintf('Variable: %8s does not exist in the model.', Update_VarNames{i})
      return
   else
       StackIndex=find(ismember(VarNamesStack,Update_VarNames{i}));
       for j=1:length(StackIndex)
           if strcmp(AlternativeStack_Nest2{StackIndex(j)},'')
               ParameterValuePair=Model.('Supply').(DemandSegmentStack{StackIndex(j)}).(AlternativeStack_Nest1{StackIndex(j)})(Update_VarNames{i});
               ParameterValuePair(2)=UpdateInfo.(Update_VarNames{i});
               ModelCopy.('Supply').(DemandSegmentStack{StackIndex(j)}).(AlternativeStack_Nest1{StackIndex(j)})(Update_VarNames{i})=ParameterValuePair;
           else
               ParameterValuePair=Model.('Supply').(DemandSegmentStack{StackIndex(j)}).(AlternativeStack_Nest1{StackIndex(j)}).(AlternativeStack_Nest2{StackIndex(j)})(Update_VarNames{i});
               ParameterValuePair(2)=UpdateInfo.(Update_VarNames{i});
               ModelCopy.('Supply').(DemandSegmentStack{StackIndex(j)}).(AlternativeStack_Nest1{StackIndex(j)}).(AlternativeStack_Nest2{StackIndex(j)})(Update_VarNames{i})=ParameterValuePair;
           end
       end
       

   end
end


return