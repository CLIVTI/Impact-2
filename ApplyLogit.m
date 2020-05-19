function ModeShare=ApplyLogit(Supply,Population)
% this function applies MNL model given supply and population segment specified in  function: 
% SpecifySupply() and SpecifyPopulationSegment().  git tested 123123

ModeAlternativeNames=fieldnames(Supply);
PopulationSegmentNames=fieldnames(Population);
TotalPopulation=0;

for k=1:length(PopulationSegmentNames)  % loop each demand segment
    Utility_PopulationSegment_i=zeros(length(ModeAlternativeNames),1);
    PopulationSegment_i=Population.(PopulationSegmentNames{k});
    VarNames_PopulationSegment_i=fieldnames(PopulationSegment_i);
    for i=1:length(ModeAlternativeNames) % loop each mode alternative
        if isa(Supply.(ModeAlternativeNames{i}),'containers.Map')  % no nests
            VarNames_Alternative_i=keys(Supply.(ModeAlternativeNames{i}));
            for j=1:length(VarNames_Alternative_i)
                ParameterValuePair=Supply.(ModeAlternativeNames{i})(VarNames_Alternative_i{j});
                if length(ParameterValuePair)==2
                    Utility_PopulationSegment_i(i)=Utility_PopulationSegment_i(i)+...
                    ParameterValuePair(1).*ParameterValuePair(2);
                else
                    Utility_PopulationSegment_i(i)=Utility_PopulationSegment_i(i)+...
                    ParameterValuePair(1).*PopulationSegment_i.(VarNames_Alternative_i{j});
                end
            end
        else   % if there is nest
            NestedAlternatives=fieldnames(Supply.(ModeAlternativeNames{i}));
            PNests={};
            Utility_PopulationSegment_i_u=zeros(length(NestedAlternatives),1);
            for u=1:length(NestedAlternatives)
                VarNames_Alternative_i_u=keys(Supply.(ModeAlternativeNames{i}).(NestedAlternatives{u}));
                for j=1:length(VarNames_Alternative_i_u)
                    if ~strcmp(VarNames_Alternative_i_u{j},'ScaleParameter')
                        ParameterValuePair=Supply.(ModeAlternativeNames{i}).(NestedAlternatives{u})(VarNames_Alternative_i_u{j});
                        if length(ParameterValuePair)==2
                            Utility_PopulationSegment_i_u(u)=Utility_PopulationSegment_i_u(u)+...
                                ParameterValuePair(1).*ParameterValuePair(2);
                        else
                            Utility_PopulationSegment_i_u(u)=Utility_PopulationSegment_i_u(u)+...
                                ParameterValuePair(1).*PopulationSegment_i.(VarNames_Alternative_i_u{j});
                        end
                    else
                        scaleParameter=Supply.(ModeAlternativeNames{i}).(NestedAlternatives{u})(VarNames_Alternative_i_u{j});
                    end
                end
            end
            [PNest,logsumNests]=Logit(Utility_PopulationSegment_i_u);
            PNests.(ModeAlternativeNames{i})=PNest;
            Utility_PopulationSegment_i(i)=scaleParameter.*logsumNests;
        end
    end %% end loop i
    if sum(isnan(Utility_PopulationSegment_i))>0
        fprintf('there is nan value in the input Supply and Population, please check. \n')
        ModeShare=nan(length(ModeAlternativeNames),1);
        return
    else
        [Probility_Upper,~]=Logit(Utility_PopulationSegment_i);
        count=1;
        for i=1:length(ModeAlternativeNames) % loop each mode alternative
            if isa(Supply.(ModeAlternativeNames{i}),'containers.Map')  % no nests
                ProbilityTotal(count)=Probility_Upper(i);
                count=count+1;
            else
                ProbNests=Probility_Upper(i).*PNests.(ModeAlternativeNames{i});
                for u=1:length(ProbNests)
                    ProbilityTotal(count)=ProbNests(u);
                    count=count+1;
                end
            end
        end
        Demand_PopulationSegment_i=PopulationSegment_i.PopulationSize.*ProbilityTotal;
        if k==1
            Demand=Demand_PopulationSegment_i;
        else
            Demand=Demand+Demand_PopulationSegment_i;
        end
        TotalPopulation=TotalPopulation+PopulationSegment_i.PopulationSize;
    end
end  % end loop k
ModeShare=(Demand./TotalPopulation)';


return


function [Probability,logsum]=Logit(Utility)
logsum=log(sum(exp(Utility-max(Utility))))+max(Utility);
Probability=exp(Utility-logsum);
return