function Supply=SpecifySupply_HighSpeedRail()
% this function specifies the supply variables and it returns a structure that stores all supply variables and parameter
% values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameter values come from WSPs highspeed rail report from ytan:
% Rapport_-_HHT_modellutveckling_på_kort_sikt_121130_leverans.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Supply={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all parameters should be included here.
% only supply variables and land use variables such as time and cost are included here.
% socio-demographic parameters are specified here but variables are specified in PopulationSegment.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Naming convention: the same attribute name should be used if they have intrinsically same value.
% Note that 
% e.g. travel time for car driver and car passenger should be the same since they use the same infrastructure
% but cost for car driver and cost for bus  are different, so we should name them differently.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBS: note that all attribute values are just a random guess now. Need to fill the real
% values!!!!!!! time unit is min.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScaleParameter=0.72426.*0.56471; % scale parameter should be multiplied by everything except ASC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Supply has the following structure: 
% Supply.ModeChoiceAlternativeName.VariableName.Parameter stores the parameter value for VariableName in ModeChoiceAlternativeName
% Supply.ModeChoiceAlternativeName.VariableName.Attribute stores the attribute value for VariableName in ModeChoiceAlternativeName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter. 
Supply.Rail=containers.Map();           %     parameter                           , value
% 'InVehRail: parameter value: 0.03 is cost parameter, 265 SEK/hour is value of time from ASEK 6 Table 7.5. 0.09265
% EURO/SEK. So unit of money is EURO. unit of time is hour. 
Supply.Rail('InVehRail')=               [-0.03*265*0.09265,                   108/60];  
% here we use the the same parameter as the cost parameter but put parameter value in value to avoid problem in
% optimization
% value: -5.746*log(30/60)+16.249 comes from the regression model of ASEK 6 Table 7.9, see excel "ASEK tidsvärde för
% turtäthet.xlsx" på ytan.
Supply.Rail('FirstWaitRail')=           [-0.03,                   30/60*(-5.746*log(30/60)+16.249)];
Supply.Rail('AccessTimeRail')=          [-0.04376*ScaleParameter,                  10/60];
Supply.Rail('TransferTimeRail')=        [-0.68466*ScaleParameter,                      0];
Supply.Rail('NumberTransferRail')=      [-0.014*5*ScaleParameter,                      0];
Supply.Rail('CostRail')=                [-0.03,                  380*0.09265];
Supply.Rail('DelayRail')=               [-1.03188*3.5*ScaleParameter,            4.25/60]; % delay parameter according to Ida is 3.5*VOT (sek/h)*beta_cost/60 =3.5*VOT(sek/min)*beta_cost=3.5*beta_time. % note that VOT=beta_time/beta_cost.
Supply.Rail('ASCRail')=                 [0.38383,                                      1];
Supply.Rail('AttractivenessRail')=      [0*ScaleParameter,                             1];


%% specify the parameter and variable values for mode alterantive bus. exact the same parameters and variables as rail.
Supply.Bus=containers.Map();           %     parameter                           , value

Supply.Bus('ASCBus')=                 [-1.52898,                                       1]; 


%% specify the parameter and variable values for mode alterantive CarDriver
% for car time, please specify free flow travel time here. Congestion effect will be considered,
% and the attribute of Time will be iterated. (min)
Supply.Car=containers.Map();           %     parameter                           , value

Supply.Bus('ASCCar')=                 [0,                                       1]; 
Supply.Car('NoCar')=                  -3.14501*ScaleParameter; 
Supply.Car('Women')=                 -1.34031*ScaleParameter;




%% specify the parameter and variable values for mode alterantive CarPassenger
Supply.Air=containers.Map();           %     parameter                           , value
Supply.Air('AccessEgressTimeAir')=                [0.02572,                                       1]; 
Supply.Air('ASCAir')=                [0.02572,                                       1]; 



CheckSupply(Supply);

return