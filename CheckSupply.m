function [VarNamesStack,AlternativeStack]=CheckSupply(Supply)
% this function checks if attributes with the same name have the same value
% returns a string vector VarNamesStack with all variables (not unique)
% returns a string vector AlternativeStack with each element as a cell containing which mode the given variable belongs
% to.
%% check if attribute with the same name have the same value
ModeAlternatives=fieldnames(Supply);
VarNamesStack={};
AlternativeStack={};
NestFlag=zeros(length(ModeAlternatives),1);
for i=1:length(ModeAlternatives)
    NestFlag(i)=CheckNest(Supply.(ModeAlternatives{i}));
    if NestFlag(i)==0  % if alternative i does not have a nest under
        VarNames_Alternative_i=keys(Supply.(ModeAlternatives{i}));
        VarNamesStack=[VarNamesStack;VarNames_Alternative_i'];
        for j=1:length(VarNames_Alternative_i)
            AlternativeStack{end+1}=ModeAlternatives{i};
        end
    else
        NestedAlternativeNames=fieldnames(Supply.(ModeAlternatives{i}));
        for j=1:length(NestedAlternativeNames)
            VarNames_Alternative_i_j=keys(Supply.(ModeAlternatives{i}).(NestedAlternativeNames{j}));
            VarNamesStack=[VarNamesStack;VarNames_Alternative_i_j'];
            for k=1:length(VarNames_Alternative_i_j)
                AlternativeStack{end+1}={ModeAlternatives{i};NestedAlternativeNames{j}};
            end
        end
    end
    
end

% FlagScaleParameter=false;
UniqueVarNames=unique(VarNamesStack);
for i=1:length(UniqueVarNames)
    if sum(ismember(VarNamesStack,UniqueVarNames{i}))>1 
        AlternativeNameWithDuplicatedVariable=AlternativeStack(ismember(VarNamesStack,UniqueVarNames{i}));
        for j=1:length(AlternativeNameWithDuplicatedVariable)
            if isa(AlternativeNameWithDuplicatedVariable{j},'char')
                ParameterValuePair=Supply.(AlternativeNameWithDuplicatedVariable{j})(UniqueVarNames{i});
                if length(ParameterValuePair)==2
                    if j==1
                        VarValue=ParameterValuePair(2);
                        AlternativeName_1=AlternativeNameWithDuplicatedVariable{j};
                    else
                        VarValueToCompare=ParameterValuePair(2);
                        if VarValueToCompare~=VarValue
                            disp(strcat(UniqueVarNames{i},' in alternative: ', AlternativeName_1, ' has a different value as the one in alternative: ', AlternativeNameWithDuplicatedVariable{j}))
                        end
                    end
                elseif length(ParameterValuePair)==1
                   %  fprintf('the variable %-15s in alternative %-15s does not have an attribute specifíed in the supply \n',UniqueVarNames{i},AlternativeNameWithDuplicatedVariable{j}) 
                end 
            else
                ParameterValuePair=Supply.(AlternativeNameWithDuplicatedVariable{j}{1}).(AlternativeNameWithDuplicatedVariable{j}{2})(UniqueVarNames{i});
                if length(ParameterValuePair)==2
                    if j==1
                        VarValue=ParameterValuePair(2); 
                        AlternativeName_2=AlternativeNameWithDuplicatedVariable{j}{2};
                    else
                        VarValueToCompare=ParameterValuePair(2);
                        if VarValueToCompare~=VarValue
                            disp(strcat(UniqueVarNames{i},' in alternative: ', AlternativeName_2, ' has a different value as the one in alternative: ', AlternativeNameWithDuplicatedVariable{j}{2}))
                        end
                    end
                elseif length(ParameterValuePair)==1
                    if strcmp(UniqueVarNames{i},'ScaleParameter')
                       %  FlagScaleParameter=true;
                    else
                        fprintf('the variable %-15s in alternative %-15s does not have an attribute specifíed in the supply \n',UniqueVarNames{i},AlternativeNameWithDuplicatedVariable{j}{2})
                    end
                    
                end 
            end
        end
    end
end
% if FlagScaleParameter==false
%     fprintf('ScaleParameter must be a variable name in the nested mode alternatives. \n' )
% end

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
