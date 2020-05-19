function [DemandOutput,UtilityOutput,ConsumerSurplus]=CalculateDemandLogit(Model)
% this function applies Logit model (MNL and Nested) given supply and population segment specified in  function: 
% SpecifySupply() and SpecifyPopulationSegment().
Supply=Model.('Supply');
PopulationSize=Model.('PopulationSize');
DemandSegmentName=fieldnames(Supply);
% ModeAlternativeNames=fieldnames(Supply);


DemandOutput=table();
UtilityOutput=table();
% [VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);

for k=1:length(DemandSegmentName)  % loop each demand segment
    ModelDemandSegment=Supply.(DemandSegmentName{k});
    ModeAlternativeNames_Nest1=fieldnames(ModelDemandSegment);
    Utility_PopulationSegment_i=zeros(length(ModeAlternativeNames_Nest1),1);
    PNests={};
    UtilityNests={};
    AlternativeNames={};
    
    for i=1:length(ModeAlternativeNames_Nest1) % loop each mode alternative
        if isa(ModelDemandSegment.(ModeAlternativeNames_Nest1{i}),'containers.Map')  % no nests
            AlternativeNames=[AlternativeNames,strcat(DemandSegmentName{k},'_',ModeAlternativeNames_Nest1{i})];
            VarNames_Alternative_i=keys(ModelDemandSegment.(ModeAlternativeNames_Nest1{i}));
            for j=1:length(VarNames_Alternative_i)
                ParameterValuePair=ModelDemandSegment.(ModeAlternativeNames_Nest1{i})(VarNames_Alternative_i{j});
                if ~strcmp(VarNames_Alternative_i{j},'ScaleParameter')
                    Utility_PopulationSegment_i(i)=Utility_PopulationSegment_i(i)+...
                    ParameterValuePair(1).*ParameterValuePair(2);
                end
            end
        else   % if there is nest
            ModeAlternativeNames_Nest2=fieldnames(ModelDemandSegment.(ModeAlternativeNames_Nest1{i}));
            UtilityLowerNest=zeros(length(ModeAlternativeNames_Nest2),1);
            for u=1:length(ModeAlternativeNames_Nest2)
                AlternativeNames=[AlternativeNames,strcat(DemandSegmentName{k},'_',ModeAlternativeNames_Nest1{i},'_',ModeAlternativeNames_Nest2{u})];
                VarNames_Alternative_i_u=keys(ModelDemandSegment.(ModeAlternativeNames_Nest1{i}).(ModeAlternativeNames_Nest2{u}));
                for j=1:length(VarNames_Alternative_i_u)
                    if ~strcmp(VarNames_Alternative_i_u{j},'ScaleParameter')
                        ParameterValuePair=ModelDemandSegment.(ModeAlternativeNames_Nest1{i}).(ModeAlternativeNames_Nest2{u})(VarNames_Alternative_i_u{j});
                        UtilityLowerNest(u)=UtilityLowerNest(u)+ParameterValuePair(1).*ParameterValuePair(2);
                    else
                        scaleParameter=ModelDemandSegment.(ModeAlternativeNames_Nest1{i}).(ModeAlternativeNames_Nest2{u})(VarNames_Alternative_i_u{j});
                    end
                end
            end
            [PNest,logsumNests]=Logit(UtilityLowerNest);
            PNests.(ModeAlternativeNames_Nest1{i})=PNest;
            UtilityNests.(ModeAlternativeNames_Nest1{i})=UtilityLowerNest;
            Utility_PopulationSegment_i(i)=scaleParameter.*logsumNests;
        end
    end %% end loop i
    if sum(isnan(Utility_PopulationSegment_i))>0
        fprintf('there is nan value in the input "Model", please check. \n')
        DemandOutput=nan;
        UtilityOutput=nan;
        return
    else
        [Probility_Upper,Logsum_PopulationSegment_i]=Logit(Utility_PopulationSegment_i);
        count=1;
        ProbilityTotal=[];
        UtilityTotal=[];
        for i=1:length(Utility_PopulationSegment_i) % loop each mode alternative
            if isa(ModelDemandSegment.(ModeAlternativeNames_Nest1{i}),'containers.Map')  % no nests
                ProbilityTotal(count)=Probility_Upper(i);
                UtilityTotal(count)=Utility_PopulationSegment_i(i);
                scaleParameter=1;
                count=count+1;
            else
                ProbNestsFinal=Probility_Upper(i).*PNests.(ModeAlternativeNames_Nest1{i});
                UtilityNestFinal=UtilityNests.(ModeAlternativeNames_Nest1{i});
                for u=1:length(ProbNestsFinal)
                    ProbilityTotal(count)=ProbNestsFinal(u);
                    UtilityTotal(count)=UtilityNestFinal(u);
                    count=count+1;
                end
            end
        end
    end
    Demand_PopulationSegment_i=PopulationSize.(DemandSegmentName{k}).*ProbilityTotal;
    if k==1
        DemandOutput=array2table(Demand_PopulationSegment_i,'VariableNames',AlternativeNames');
        UtilityOutput=array2table(UtilityTotal,'VariableNames',AlternativeNames');
        ConsumerSurplus=(1./Model.UtilityScaleParameter(k)).*(1/scaleParameter).*Logsum_PopulationSegment_i.*sum(Demand_PopulationSegment_i);
    else
        for n=1:length(Demand_PopulationSegment_i)
            DemandOutput.(AlternativeNames{n})=Demand_PopulationSegment_i(n);
            UtilityOutput.(AlternativeNames{n})=UtilityTotal(n);
        end
        ConsumerSurplus=ConsumerSurplus+(1./Model.UtilityScaleParameter(k)).*(1/scaleParameter).*Logsum_PopulationSegment_i.*sum(Demand_PopulationSegment_i);
    end
end  % end loop k



return


function [Probability,logsum]=Logit(Utility)
logsum=log(sum(exp(Utility-max(Utility))))+max(Utility);
Probability=exp(Utility-logsum);
return