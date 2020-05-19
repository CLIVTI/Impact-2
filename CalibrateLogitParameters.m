function [CalibrationStatistics]=CalibrateLogitParameters(Model,CalibrateInfo,TargetDemand)
% this is a least square calibration function to calibrate parameters specified in CalibrateInfo

%% validity check
[VarNamesStack,DemandSegmentStack,AlternativeStack_Nest1,AlternativeStack_Nest2]=ParseModelAttributes(Model);
Demand_Initial=CalculateDemandLogit(Model);
if  ~isequal(fieldnames(Demand_Initial),fieldnames(TargetDemand))
    fprintf('Please check input Alternative names in TargetDemand.')
    CalibrationStatistics.OptimizationOutput=nan;
    CalibrationStatistics.TargetDemand=TargetDemand;
    CalibrationStatistics.FinalModeShare=nan;
    return
end

DemandSegmentName=fieldnames(CalibrateInfo);
Nvar=0;
CalibarateVarNamesStack={};
CalibrateDemandSegmentStack={};
CalibrateAlternativeStack_Nest1={};
CalibrateAlternativeStack_Nest2={};
for i=1:length(DemandSegmentName)
    TimeSegmentName=fieldnames(CalibrateInfo.(DemandSegmentName{i}));
    for j=1:length(TimeSegmentName)
        ModeSegmentNames=fieldnames(CalibrateInfo.(DemandSegmentName{i}).(TimeSegmentName{j}));
        for k=1:length(ModeSegmentNames)
            if isnumeric(CalibrateInfo.(DemandSegmentName{i}).(TimeSegmentName{j}).(ModeSegmentNames{k})) 
                if length(ModeSegmentNames)~=1
                    fprintf('Alternative: %15s has more than one parameter to be calibartaed.', strcat(DemandSegmentName{i},'_',TimeSegmentName{j}))
                    CalibrationStatistics.OptimizationOutput=nan;
                    CalibrationStatistics.TargetModeShare=TargetModeShare;
                    CalibrationStatistics.FinalModeShare=nan;
                    return
                else
                    Nvar=Nvar+1;
                    CalibarateVarNamesStack{end+1}=ModeSegmentNames{1};
                    CalibrateDemandSegmentStack{end+1}=DemandSegmentName{i};
                    CalibrateAlternativeStack_Nest1{end+1}=TimeSegmentName{j};
                    CalibrateAlternativeStack_Nest2{end+1}='';
                end
            else
                VarNames=fieldnames(CalibrateInfo.(DemandSegmentName{i}).(TimeSegmentName{j}).(ModeSegmentNames{k}));
                if length(VarNames)~=1
                    fprintf('Alternative: %15s has more than one parameter to be calibartaed.', strcat(DemandSegmentName{i},'_',TimeSegmentName{j},'_',ModeSegmentNames{k}))
                    CalibrationStatistics.OptimizationOutput=nan;
                    CalibrationStatistics.TargetModeShare=TargetModeShare;
                    CalibrationStatistics.FinalModeShare=nan;
                    return
                else
                    Nvar=Nvar+1;
                    CalibarateVarNamesStack{end+1}=VarNames{1};
                    CalibrateDemandSegmentStack{end+1}=DemandSegmentName{i};
                    CalibrateAlternativeStack_Nest1{end+1}=TimeSegmentName{j};
                    CalibrateAlternativeStack_Nest2{end+1}=ModeSegmentNames{k};
                end
           
            end
        end
    end
end


if Nvar~=(size(TargetDemand,2)-1)
    fprintf('Number of variables in CalibrateInfo should not be more than degree of freedom from TargetModeShare. \n' )
    CalibrationStatistics.OptimizationOutput=nan;
    CalibrationStatistics.TargetDemand=TargetDemand;
    CalibrationStatistics.FinalModeShare=nan;
    return
end

if abs(sum(table2array(TargetDemand))-sum(table2array(Demand_Initial)))>0.1
    fprintf('The sum of TargetModeShare should be one. \n' )
    CalibrationStatistics.OptimizationOutput=nan;
    CalibrationStatistics.TargetDemand=TargetDemand;
    CalibrationStatistics.FinalModeShare=nan;
    return
end


%% calibration
startValue=zeros(Nvar,1);
for i=1:Nvar
    if strcmp(CalibrateAlternativeStack_Nest2{i},'')==1
        startValue(i)=CalibrateInfo.(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i}).(CalibarateVarNamesStack{i});
    else
        startValue(i)=CalibrateInfo.(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i}).(CalibrateAlternativeStack_Nest2{i}).(CalibarateVarNamesStack{i});
    end

end
options = optimset('GradObj','off','LargeScale','on','Display','Iter','TolFun',1e-6,'TolX',1e-20','MaxFunEvals',10000,'MaxIter',3000);
[beta,fval,~,output,~,~]= fminunc(@(Parameters)LeastSquareLogit(Parameters,Model,TargetDemand,...
    CalibrateDemandSegmentStack,...
    CalibrateAlternativeStack_Nest1,...
    CalibrateAlternativeStack_Nest2,...
    CalibarateVarNamesStack),startValue,options); % '@' is a handle for the LogLikelihood below
 
Obj_Zero=LeastSquareLogit(zeros(Nvar,1),Model,TargetDemand,...
    CalibrateDemandSegmentStack,...
    CalibrateAlternativeStack_Nest1,...
    CalibrateAlternativeStack_Nest2,...
    CalibarateVarNamesStack);

Obj_Final=LeastSquareLogit(beta,Model,TargetDemand,...
    CalibrateDemandSegmentStack,...
    CalibrateAlternativeStack_Nest1,...
    CalibrateAlternativeStack_Nest2,...
    CalibarateVarNamesStack);
fprintf('The objective function at zero: %+8.4f \n', Obj_Zero)
fprintf('The objective function at final: %+8.4f \n', Obj_Final)

fprintf('\n\n----------------- DISPLAY RESULTS ---------------------')
fprintf('\n %-40s : %8s %8s \n' , ['Parameter'],['InitialValue'],['Estimates']);
for i=1:length(beta) 
    if strcmp(CalibrateAlternativeStack_Nest2{i},'')==1
        VarName=strcat(CalibrateDemandSegmentStack{i},'_',CalibrateAlternativeStack_Nest1{i},'_',CalibarateVarNamesStack{i});
    else
        VarName=strcat(CalibrateDemandSegmentStack{i},'_',CalibrateAlternativeStack_Nest1{i},'_',CalibrateAlternativeStack_Nest2{i},'_',CalibarateVarNamesStack{i});
    end
    
    fprintf('%-15s : %+8.4f %+8.4f \n', VarName, startValue(i) , beta(i))
end

for i=1:length(beta) 
    if strcmp(CalibrateAlternativeStack_Nest2{i},'')==1
        ParameterValuePair=Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i})(CalibarateVarNamesStack{i});
        ParameterValuePair(1)=beta(i);
        Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i})(CalibarateVarNamesStack{i})=ParameterValuePair;
    else
        ParameterValuePair=Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i}).(CalibrateAlternativeStack_Nest2{i})(CalibarateVarNamesStack{i});
        ParameterValuePair(1)=beta(i);
        Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i}).(CalibrateAlternativeStack_Nest2{i})(CalibarateVarNamesStack{i})=ParameterValuePair;
    end
    
    
end

CalibrationStatistics.OptimizationOutput=output;
CalibrationStatistics.TargetDemand=TargetDemand;
CalibrationStatistics.FinalModeShare=CalculateDemandLogit(Model);

return

function [ObjFunction]=LeastSquareLogit(Parameters,Model,TargetDemand,CalibrateDemandSegmentStack,...
    CalibrateAlternativeStack_Nest1,...
    CalibrateAlternativeStack_Nest2,...
    CalibarateVarNamesStack)

for i=1:length(Parameters) 
    if strcmp(CalibrateAlternativeStack_Nest2{i},'')==1
        ParameterValuePair=Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i})(CalibarateVarNamesStack{i});
        ParameterValuePair(1)=Parameters(i);
        Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i})(CalibarateVarNamesStack{i})=ParameterValuePair;
    else
        ParameterValuePair=Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i}).(CalibrateAlternativeStack_Nest2{i})(CalibarateVarNamesStack{i});
        ParameterValuePair(1)=Parameters(i);
        Model.('Supply').(CalibrateDemandSegmentStack{i}).(CalibrateAlternativeStack_Nest1{i}).(CalibrateAlternativeStack_Nest2{i})(CalibarateVarNamesStack{i})=ParameterValuePair;
    end
    
end
ModelDemand=CalculateDemandLogit(Model);
ObjFunction=sqrt(sum((table2array(ModelDemand)-table2array(TargetDemand)).^2));
return
