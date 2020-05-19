close all 
clear variables;
DCArray=3.5;
CSorPSInput='CS';
ObjDiff=zeros(length(DCArray),1);
CSDiff=zeros(length(DCArray),1);
RevenueDiff=zeros(length(DCArray),1);
OperationalCostDiff=zeros(length(DCArray),1);
TrackChargeDiff=zeros(length(DCArray),1);
for i=1:length(DCArray)
    [ObjectiveFunctionBaseline,ObjectiveFunctionFinal]=DisComfortIter(DCArray(i),CSorPSInput);
    ObjDiff(i)=ObjectiveFunctionFinal.ObjectiveFunction-ObjectiveFunctionBaseline.ObjectiveFunction;
    CSDiff(i)=ObjectiveFunctionFinal.CS-ObjectiveFunctionBaseline.CS;
    RevenueDiff(i)=ObjectiveFunctionFinal.Revenue-ObjectiveFunctionBaseline.Revenue;
    OperationalCostDiff(i)=ObjectiveFunctionFinal.OperationalCost-ObjectiveFunctionBaseline.OperationalCost;
    TrackChargeDiff(i)=ObjectiveFunctionFinal.BanAvgift-ObjectiveFunctionBaseline.BanAvgift;
%     ObjDiff(i)=ObjectiveFunctionFinal.ObjectiveFunction;
%     CSDiff(i)=ObjectiveFunctionFinal.CS;
%     RevenueDiff(i)=ObjectiveFunctionFinal.Revenue;
%     OperationalCostDiff(i)=ObjectiveFunctionFinal.OperationalCost;
%     TrackChargeDiff(i)=ObjectiveFunctionFinal.BanAvgift;

end

Output=[DCArray',ObjDiff,CSDiff,RevenueDiff,OperationalCostDiff,TrackChargeDiff];
Output=array2table(Output,'VariableNames',{'DCValue','ObjDiff','CSDiff','RevenueDiff','OperationalCostDiff','TrackChargeDiff'});
% writetable(Output,'CS_DiscomfortIter.xlsx')
% Test=array2table([1,2;3,4],'VariableNames',{'DCValue','Test'})
% writetable(Test,'text.xlsx')

Output=table2array(readtable('CS_DiscomfortIter.xlsx'));
plot(Output(:,1),Output(:,2),Output(:,1),Output(:,4),Output(:,1),Output(:,5),Output(:,1),Output(:,6),Output(:,1),Output(:,3))
hold on
legend('ObjDiff','RevenueDiff','OperationalCostDiff','TrackChargeDiff','CSDiff')
xlabel('Discomfort factor') 
ylabel('Monetary value(SEK)') 