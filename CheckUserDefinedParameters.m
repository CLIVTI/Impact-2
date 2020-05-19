function ParsedUserDefinedParameters=CheckUserDefinedParameters(UserDefinedParameters)
% funct

try 
    ParsedUserDefinedParameters={};
    
    ParsedUserDefinedParameters.CostScaleParameter=[UserDefinedParameters.CostScaleParameter.Private,UserDefinedParameters.CostScaleParameter.Business];
    ParsedUserDefinedParameters.DCValue=[UserDefinedParameters.DCValue.Private.Peak,UserDefinedParameters.DCValue.Private.Offpeak,UserDefinedParameters.DCValue.Business.Peak,UserDefinedParameters.DCValue.Business.Offpeak];
    ParsedUserDefinedParameters.ExtraCostBaseValue=[UserDefinedParameters.ExtraCostBaseValue.Private.Peak,UserDefinedParameters.ExtraCostBaseValue.Private.Offpeak,UserDefinedParameters.ExtraCostBaseValue.Business.Peak,UserDefinedParameters.ExtraCostBaseValue.Business.Offpeak];
    ParsedUserDefinedParameters.DCVarName={UserDefinedParameters.DCVarName.Private.Peak,UserDefinedParameters.DCVarName.Private.Offpeak,UserDefinedParameters.DCVarName.Business.Peak,UserDefinedParameters.DCVarName.Business.Offpeak};
    ParsedUserDefinedParameters.SeatCapacity=[UserDefinedParameters.SeatCapacity.Peak,UserDefinedParameters.SeatCapacity.Offpeak];
    ParsedUserDefinedParameters.CSorPS=UserDefinedParameters.CSorPS;
    ParsedUserDefinedParameters.OperationalCost=[UserDefinedParameters.OperationalCost.Peak,UserDefinedParameters.OperationalCost.Offpeak];
    ParsedUserDefinedParameters.BanAvgift=[UserDefinedParameters.BanAvgift.Peak,UserDefinedParameters.BanAvgift.Offpeak];
catch
    msg = 'Please make sure UserDefinedParameters include all necessary parameters.';
    error(msg)
end
return