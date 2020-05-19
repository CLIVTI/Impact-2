function []=PrintSupply(Supply)
% this function checks if attributes with the same name have the same value
% returns a string vector VarNamesStack with all variables (not unique)
% returns a string vector AlternativeStack with each element as a cell containing which mode the given variable belongs
% to.
%% check if attribute with the same name have the same value
ModeAlternatives=fieldnames(Supply);

NestFlag=zeros(length(ModeAlternatives),1);
for i=1:length(ModeAlternatives)
    NestFlag(i)=CheckNest(Supply.(ModeAlternatives{i}));
    if NestFlag(i)==0  % if alternative i does not have a nest under
        VarNames_Alternative_i=keys(Supply.(ModeAlternatives{i}));
        for j=1:length(VarNames_Alternative_i)
            ParameterValuePair=Supply.(ModeAlternatives{i})(VarNames_Alternative_i{j});
            if length(ParameterValuePair)==2
                fprintf('Variable: %-20s in alternative: %-15s  has parameter: %-10s and attribute : %-10s \n', VarNames_Alternative_i{j}, ModeAlternatives{i},num2str(ParameterValuePair(1)),num2str(ParameterValuePair(2)) )
            elseif length(ParameterValuePair)==1
                fprintf('Variable: %-20s in alternative: %-15s  has parameter: %-10s \n', VarNames_Alternative_i{j}, ModeAlternatives{i},num2str(ParameterValuePair(1)) )
            end
        end
    else
        NestedAlternativeNames=fieldnames(Supply.(ModeAlternatives{i}));
        for j=1:length(NestedAlternativeNames)
            VarNames_Alternative_i_j=keys(Supply.(ModeAlternatives{i}).(NestedAlternativeNames{j}));
            for k=1:length(VarNames_Alternative_i_j)
                ParameterValuePair=Supply.(ModeAlternatives{i}).(NestedAlternativeNames{j})(VarNames_Alternative_i_j{k});
                if length(ParameterValuePair)==2
                    fprintf('Variable: %-20s in alternative: %-15s and %10s  has parameter: %-10s and attribute : %-10s \n', VarNames_Alternative_i_j{j}, ModeAlternatives{i},NestedAlternativeNames{j},num2str(ParameterValuePair(1)),num2str(ParameterValuePair(2)) )
                elseif length(ParameterValuePair)==1
                    fprintf('Variable: %-20s in alternative: %-15s and %10s  has parameter: %-10s \n', VarNames_Alternative_i_j{j}, ModeAlternatives{i},NestedAlternativeNames{j},num2str(ParameterValuePair(1)))
                end
            end
        end
    end
    
end


return


function flag=CheckNest(Map)
if isa(Map,'containers.Map')
    flag=0;
elseif isa(Map,'struct')  % if the object is a structure, that means there is still nest
    flag=1;
else 
    flag=nan;
end
return
