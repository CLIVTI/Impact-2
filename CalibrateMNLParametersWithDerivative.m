function [Supply_Calibrated,CalibrationStatistics]=CalibrateMNLParametersWithDerivative(Supply,Population,CalibrateInfo,TargetModeShare)
% this is a least square calibration function to calibrate parameters specified in CalibrateInfo
ModeAlternatives=fieldnames(Supply);
CalibrateModes=fieldnames(CalibrateInfo);

% validity check
flag=0;
Nvar=0;
for i=1:length(CalibrateModes)
    if ~ismember(CalibrateModes{i},ModeAlternatives) % check if all CalibrateModes is within the ModeAlternatives 
        fprintf('mode: %-15s in CalibrateInfo is not a mode name in Supply. \n', CalibrateModes{i} )
        flag=1;
    else
        Nvar_mode_i=fieldnames(CalibrateInfo.(CalibrateModes{i}));
        VarNames_mode=fieldnames(Supply.(CalibrateModes{i}));
        for j=1:length(Nvar_mode_i)
            if ~ismember(Nvar_mode_i{j},VarNames_mode)
                fprintf('variable: %-15s in CalibrateInfo is not a variable in Supply for alternative: %-15s. \n', Nvar_mode_i{j},CalibrateModes{i})
                flag=1;
            else
                Nvar=Nvar+1;
            end
        end
    end
end

if flag==1
    Supply_Calibrated=nan;
    CalibrationStatistics.OptimizationOutput=nan;
    CalibrationStatistics.TargetModeShare=TargetModeShare;
    CalibrationStatistics.FinalModeShare=nan;
    return
end

if Nvar>(length(TargetModeShare)-1)
    fprintf('Number of variables in CalibrateInfo should not be more than degree of freedom from TargetModeShare. \n' )
    Supply_Calibrated=nan;
    CalibrationStatistics.OptimizationOutput=nan;
    CalibrationStatistics.TargetModeShare=TargetModeShare;
    CalibrationStatistics.FinalModeShare=nan;
    return
end

if sum(TargetModeShare)~=1
    fprintf('The sum of TargetModeShare should be one. \n' )
    Supply_Calibrated=nan;
    CalibrationStatistics.OptimizationOutput=nan;
    CalibrationStatistics.TargetModeShare=TargetModeShare;
    CalibrationStatistics.FinalModeShare=nan;
    return
end


% validity check done 
Supply_Calibrated=Supply;
startValue=zeros(Nvar,1);
options = optimset('GradObj','on','LargeScale','off','Display','Iter','TolFun',1e-6,'TolX',1e-6','MaxFunEvals',10000,'MaxIter',3000);
 [beta,fval,~,output,~,~]= fminunc(@(Parameters)LeastSquareMNL(Supply,Population,Parameters,CalibrateInfo,TargetModeShare),startValue,options); % '@' is a handle for the LogLikelihood below
 
 fprintf('\n\n----------------- DISPLAY RESULTS ---------------------')
fprintf('\n %-8s %-8s: %15s  \n' ,  ['Mode'],['Parameter'],['Estimate'])
count=1;
for i=1:length(CalibrateModes)
    Nvar_mode_i=fieldnames(CalibrateInfo.(CalibrateModes{i}));
    for j=1:length(Nvar_mode_i)
       Supply_Calibrated.(CalibrateModes{i}).(Nvar_mode_i{j}).Parameter=beta(count);
       fprintf('%-8s %-8s: %+15f  \n', CalibrateModes{i}, Nvar_mode_i{j},beta(count) )
       count=count+1;   
    end
end 


CalibrationStatistics.OptimizationOutput=output;
CalibrationStatistics.TargetModeShare=TargetModeShare;
CalibrationStatistics.FinalModeShare=ApplyMNL(Supply_Calibrated,Population);
return

function [ObjFunction,Derivatives]=LeastSquareMNL(Supply,Population,Parameters,CalibrateInfo,TargetModeShare)
CalibrateModes=fieldnames(CalibrateInfo);
count=1;
SupplyCalibrate=Supply;
for i=1:length(CalibrateModes)
    Nvar_mode_i=fieldnames(CalibrateInfo.(CalibrateModes{i}));
    for j=1:length(Nvar_mode_i)
       SupplyCalibrate.(CalibrateModes{i}).(Nvar_mode_i{j}).Parameter=Parameters(count);
       count=count+1;
    end
end
ModeShare=ApplyMNL(SupplyCalibrate,Population);
ObjFunction=sum((ModeShare-TargetModeShare).^2);
Derivatives=zeros(length(CalibrateModes),1);

for i=1:length(CalibrateModes)
    VarNameCell=fieldnames(CalibrateInfo.(CalibrateModes{i}));
    VarName=VarNameCell{1};
    Derivatives_vector=ApplyMNLDerivative(SupplyCalibrate,Population,VarName);
    Derivatives(i)=sum(2.*(ModeShare-TargetModeShare).*Derivatives_vector);  % Nalternative*1
end

return