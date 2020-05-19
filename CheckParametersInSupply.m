function [Parameters,Flag,Nvar]=CheckParametersInSupply(Supply,CalibrateInfo)
% this function checks and gets if variables in CalibrateInfo appear in Supply
Flag=true;
Nvar=0;
Parameters=[];
CalibrateModes=fieldnames(CalibrateInfo);
for i=1:length(CalibrateModes)
    NextLayerVar=fieldnames(CalibrateInfo.(CalibrateModes{i}));
    for j=1:length(NextLayerVar)
        if isa(CalibrateInfo.(CalibrateModes{i}).(NextLayerVar{j}),'struct')
            NextNextLayerVar=fieldnames(CalibrateInfo.(CalibrateModes{i}).(NextLayerVar{j}));
            for k=1:length(NextNextLayerVar)
                try
                    ParameterValuePair=Supply.(CalibrateModes{i}).(NextLayerVar{j})(NextNextLayerVar{k});
                    Nvar=Nvar+1;
                    Parameters(Nvar)=ParameterValuePair(1);
                catch
                    Flag=false;
                    fprintf('variable: %-15s in CalibrateInfo is not included in Supply. \n', NextNextLayerVar{k} )
                end
            end
        else
            try
                ParameterValuePair=Supply.(CalibrateModes{i})(NextLayerVar{j});
                Nvar=Nvar+1;
                Parameters(Nvar)=ParameterValuePair(1);
            catch
                Flag=false;
                fprintf('variable: %-15s in CalibrateInfo is not included in Supply. \n', NextLayerVar{j} )
            end
        end
    end
end
return