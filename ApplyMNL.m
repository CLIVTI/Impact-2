function ModeShare=ApplyMNL(Supply,Population)
% this function applies MNL model given supply and population segment specified in  function: 
% SpecifySupply() and SpecifyPopulationSegment().

ModeAlternativeNames=fieldnames(Supply);
PopulationSegmentNames=fieldnames(Population);
TotalPopulation=0;
Demand=zeros(length(ModeAlternativeNames),1);
for k=1:length(PopulationSegmentNames)  % loop each demand segment
    flag=0;  % flag to check if there is any variable that has a parameter defined in Supply but does not have a corresponding variable in Population
    Utility_PopulationSegment_i=zeros(length(ModeAlternativeNames),1);
    PopulationSegment_i=Population.(PopulationSegmentNames{k});
    VarNames_PopulationSegment_i=fieldnames(PopulationSegment_i);
    for i=1:length(ModeAlternativeNames) % loop each mode alternative
        VarNames_Alternative_i=fieldnames(Supply.(ModeAlternativeNames{i}));
        for j=1:length(VarNames_Alternative_i) % loop each variable
            FieldName_Var=fieldnames(Supply.(ModeAlternativeNames{i}).(VarNames_Alternative_i{j}));
            if ismember('Attribute',FieldName_Var)   % if attribute is in Supply
                Utility_PopulationSegment_i(i)=Utility_PopulationSegment_i(i)+...
                    Supply.(ModeAlternativeNames{i}).(VarNames_Alternative_i{j}).Parameter.*...
                    Supply.(ModeAlternativeNames{i}).(VarNames_Alternative_i{j}).Attribute;
            else
                if ismember(VarNames_Alternative_i{j},VarNames_PopulationSegment_i)  % if attribute is in Population
                    Utility_PopulationSegment_i(i)=Utility_PopulationSegment_i(i)+...
                        Supply.(ModeAlternativeNames{i}).(VarNames_Alternative_i{j}).Parameter.*...
                        PopulationSegment_i.(VarNames_Alternative_i{j});
                else
                    fprintf('variable: %-15s is not a variable name in population segment: %-15s \n', VarNames_Alternative_i{j} ,PopulationSegmentNames{k} )
                    flag=1;
                end
            end
        end % end loop j
    end %% end loop i
    if flag==1
        fprintf('the calculated demand may be wrong. \n')
        ModeShare=nan(length(ModeAlternativeNames),1);
        return
    else
        if sum(isnan(Demand))>0
            fprintf('there is nan value in the input Supply and Population, please check. \n')
            ModeShare=nan(length(ModeAlternativeNames),1);
            return
        else
            logsum=log(sum(exp(Utility_PopulationSegment_i-max(Utility_PopulationSegment_i))))+max(Utility_PopulationSegment_i);
            Demand_PopulationSegment_i=PopulationSegment_i.PopulationSize.*exp(Utility_PopulationSegment_i-logsum);
            Demand=Demand+Demand_PopulationSegment_i;
            TotalPopulation=TotalPopulation+PopulationSegment_i.PopulationSize;
        end
    end % end if flag==1
end  % end loop k
ModeShare=Demand./TotalPopulation;


return