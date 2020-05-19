function [VarNamesStackUpdated,DemandSegmentStackUpdated,AlternativeStack_Nest1_Updated,AlternativeStack_Nest2_Updated]=ParseModelAttributes(Model)
% this function parses the model structure and extracts the attribute names and its corresponding alternatives as a
% plain list.
% input:
%       Supply: the structure representing the supply.
%       VarNamesStack: attribute name list to be updated
%       DemandSegmentStack: Demand segment name list to be udpated.
%       AlternativeStack_Nest1: alternative name list for the upper level nest to be updated.
%       AlternativeStack_Nest2: alternative name list for the lower level nest to be updated.
% output:
%       the updated four lists
VarNamesStack={};
DemandSegmentStack={};
AlternativeStack_Nest1={};
AlternativeStack_Nest2={};
Supply=Model.('Supply');

DemandSegmentName=fieldnames(Supply);
VarNamesStackUpdated=VarNamesStack;
DemandSegmentStackUpdated=DemandSegmentStack;
AlternativeStack_Nest1_Updated=AlternativeStack_Nest1;
AlternativeStack_Nest2_Updated=AlternativeStack_Nest2;

for d=1:length(DemandSegmentName)
    Model_DemandSegment=Supply.(DemandSegmentName{d});
    ModeAlternatives_Nest1=fieldnames(Model_DemandSegment);
    NestFlag=zeros(length(ModeAlternatives_Nest1),1);
    for i=1:length(ModeAlternatives_Nest1)
        NestFlag(i)=CheckNest(Model_DemandSegment.(ModeAlternatives_Nest1{i}));
        if NestFlag(i)==0  % if alternative i does not have a nest under
            VarNames_Alternative_i=keys(Model_DemandSegment.(ModeAlternatives_Nest1{i}));
            VarNamesStackUpdated=[VarNamesStackUpdated;VarNames_Alternative_i'];
            for j=1:length(VarNames_Alternative_i)
                DemandSegmentStackUpdated{end+1}=DemandSegmentName{d};
                AlternativeStack_Nest1_Updated{end+1}=ModeAlternatives_Nest1{i};
                AlternativeStack_Nest2_Updated{end+1}='';
            end
        else
            ModeAlternatives_Nest2=fieldnames(Model_DemandSegment.(ModeAlternatives_Nest1{i}));
            for j=1:length(ModeAlternatives_Nest2)
                VarNames_Alternative_i_j=keys(Model_DemandSegment.(ModeAlternatives_Nest1{i}).(ModeAlternatives_Nest2{j}));
                VarNamesStackUpdated=[VarNamesStackUpdated;VarNames_Alternative_i_j'];
                for k=1:length(VarNames_Alternative_i_j)
                    DemandSegmentStackUpdated{end+1}=DemandSegmentName{d};
                    AlternativeStack_Nest1_Updated{end+1}=ModeAlternatives_Nest1{i};
                    AlternativeStack_Nest2_Updated{end+1}=ModeAlternatives_Nest2{j};
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