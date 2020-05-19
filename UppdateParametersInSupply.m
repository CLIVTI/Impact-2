function SupplyUpdated=UppdateParametersInSupply(Supply,CalibrateInfo)
% this function checks if variables in CalibrateInfo appear in Supply
SupplyUpdated=CopySupply(Supply);
CalibrateModes=fieldnames(CalibrateInfo);
for i=1:length(CalibrateModes)
    NextLayerVar=fieldnames(CalibrateInfo.(CalibrateModes{i}));
    for j=1:length(NextLayerVar)
        if isa(CalibrateInfo.(CalibrateModes{i}).(NextLayerVar{j}),'struct')
            NextNextLayerVar=fieldnames(CalibrateInfo.(CalibrateModes{i}).(NextLayerVar{j}));
            for k=1:length(NextNextLayerVar)
                ParameterValuePair=SupplyUpdated.(CalibrateModes{i}).(NextLayerVar{j})(NextNextLayerVar{k});
                ParameterValue=CalibrateInfo.(CalibrateModes{i}).(NextLayerVar{j}).(NextNextLayerVar{k});
                ParameterValuePair(1)=ParameterValue;
                SupplyUpdated.(CalibrateModes{i}).(NextLayerVar{j})(NextNextLayerVar{k})=ParameterValuePair;
            end
        else
            ParameterValuePair=SupplyUpdated.(CalibrateModes{i})(NextLayerVar{j});
            ParameterValue=CalibrateInfo.(CalibrateModes{i}).(NextLayerVar{j});
            ParameterValuePair(1)=ParameterValue;
            SupplyUpdated.(CalibrateModes{i})(NextLayerVar{j})=ParameterValuePair;
        end
    end
end
return