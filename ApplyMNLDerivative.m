function Derivative=ApplyMNLDerivative(Supply,Population,VarName)
% this function applies MNL model given supply and population segment specified in  function: 
% SpecifySupply() and SpecifyPopulationSegment().
ModeAlternativeNames=fieldnames(Supply);
VarInAlternativeFlag=zeros(length(ModeAlternativeNames),1);
for i=1:length(ModeAlternativeNames)
    VarNames_Alternative_i=fieldnames(Supply.(ModeAlternativeNames{i}));
    if ismember(VarName,VarNames_Alternative_i)
        VarInAlternativeFlag(i)=1;
    end
end



PopulationSegmentNames=fieldnames(Population);
TotalPopulation=0;
DemandDer=zeros(length(ModeAlternativeNames),1);
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
        Derivative=nan(length(ModeAlternativeNames),1);
        return
    else
        if sum(isnan(DemandDer))>0
            fprintf('there is nan value in the input Supply and Population, please check. \n')
            Derivative=nan(length(ModeAlternativeNames),1);
            return
        else
            logsum=log(sum(exp(Utility_PopulationSegment_i-max(Utility_PopulationSegment_i))))+max(Utility_PopulationSegment_i);
            P=exp(Utility_PopulationSegment_i-logsum);
            PX=zeros(length(ModeAlternativeNames),1);
            for u=1:length(ModeAlternativeNames)
                if  VarInAlternativeFlag(u)==1
                    X_i=Supply.(ModeAlternativeNames{u}).(VarName).Attribute;
                    PX(u)=P(u).*X_i;
                end
            end
            Der=zeros(length(ModeAlternativeNames),1);
            for u=1:length(ModeAlternativeNames)
                if  VarInAlternativeFlag(u)==1
                    X_i=Supply.(ModeAlternativeNames{u}).(VarName).Attribute;
                    Der(u)=X_i-sum(PX);
                else
                    Der(u)=-sum(PX);
                end
                
            end
            Demand_PopulationSegment_i=PopulationSegment_i.PopulationSize.*P.*Der;
            DemandDer=DemandDer+Demand_PopulationSegment_i;
            TotalPopulation=TotalPopulation+PopulationSegment_i.PopulationSize;
        end
    end % end if flag==1
end  % end loop k
Derivative=DemandDer./TotalPopulation;


return