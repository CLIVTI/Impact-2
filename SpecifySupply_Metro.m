function Supply=SpecifySupply_Metro()
% this function specifies the supply variables and it returns a structure that stores all supply variables and parameter
% values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameter values come from Sampers report from ytan: Sampers4_rapport_v1.2.docx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Supply={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all parameters should be included here.
% only supply variables and land use variables such as time and cost are included here.
% socio-demographic parameters are specified here but variables are specified in PopulationSegment.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Naming convention: the same attribute name should be used if they have intrinsically same value
% e.g. travel time for car driver and car passenger should be the same since they use the same infrastructure
% but cost for car driver and cost for bus  are different, so we should name them differently.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBS: note that all attribute values are just a random guess now. Need to fill the real
% values!!!!!!! time unit is min.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Supply has the following structure: 
% Supply.ModeChoiceAlternativeName.VariableName.Parameter stores the parameter value for VariableName in ModeChoiceAlternativeName
% Supply.ModeChoiceAlternativeName.VariableName.Attribute stores the attribute value for VariableName in ModeChoiceAlternativeName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter.
Supply.PT.Metro=containers.Map();           %     parameter                           , value
Supply.PT.Metro('ASCMetro')=               [1.42,                       1];  % use container.Map to store data
Supply.PT.Metro('InVehMetro')=             [-0.06,                      41];  
Supply.PT.Metro('AuxInVehMetro')=          [-0.08,                       0];  % use container.Map to store data
Supply.PT.Metro('AccessTimeMetro')=        [-0.05,                       5]; 
Supply.PT.Metro('FirstWaitTimeMetro')=     [-0.03,                       2.5]; 
Supply.PT.Metro('TransferTimeMetro')=      [-0.04,                       0]; 
Supply.PT.Metro('CostMetro')=              [-0.78,                      24.74]; 
Supply.PT.Metro('ScaleParameter')=          1/1.16;  % use container.Map to store data

%% specify the parameter and variable values for mode alterantive bus. exact the same parameters and variables as rail.
Supply.PT.Bus=containers.Map();           %     parameter              , value
Supply.PT.Bus('ASCBus')=                 [0.69,                         1];  % use container.Map to store data
Supply.PT.Bus('InVehBus')=               [-0.06,                       40];  
Supply.PT.Bus('AuxInVehBus')=            [-0.12,                       0];  
Supply.PT.Bus('AccessTimeBus')=          [-0.05,                       5]; 
Supply.PT.Bus('FirstWaitTimeBus')=       [-0.03,                       7.5]; 
Supply.PT.Bus('TransferTimeBus')=        [-0.04,                       0]; 
Supply.PT.Bus('CostBus')=                [-0.78,                      24.74]; 
Supply.PT.Bus('ScaleParameter')=          1/1.16;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!


%% specify the parameter and variable values for mode alterantive Bike
% for car time, please specify free flow travel time here. Congestion effect will be considered,
% and the attribute of Time will be iterated. (min)
Supply.Bike=containers.Map();           %     parameter                           , value
Supply.Bike('ASCBike')=                 [-0.9,                         1];  % use container.Map to store data
Supply.Bike('BikeTime')=                [-0.08,                       120];  % use container.Map to store data
Supply.Bike('Women')=                    -0.65;  % use container.Map to store data

%% specify the parameter and variable values for mode alterantive CarDriver
Supply.CarDriver=containers.Map();           %     parameter                           , value
Supply.CarDriver('ASCCarDriver')=            [21,                         1];  % use container.Map to store data
Supply.CarDriver('CarTime')=                 [-0.09,                         30];  % use container.Map to store data
Supply.CarDriver('CostCarDriver')=           [-0.78,                         20*1.8];  % use container.Map to store data
Supply.CarDriver('CarCompetition')=           -1.02;  % use container.Map to store data
Supply.CarDriver('NumberCars')=               0.73;  % use container.Map to store data
Supply.CarDriver('NoCar')=                    -1.91;  % use container.Map to store data
Supply.CarDriver('Women')=                    -1.26;  % use container.Map to store data

%% specify the parameter and variable values for mode alterantive CarPassenger
Supply.CarPassenger=containers.Map();           %     parameter                           , value
Supply.CarPassenger('ASCCarPassenger')=       [19,                       1];  % use container.Map to store data
Supply.CarPassenger('CarTime')=               [-0.09,                      30];  % use container.Map to store data
Supply.CarPassenger('CostCarPassenger')=      [-0.78,                  20*1.8];  % use container.Map to store data
Supply.CarPassenger('NoCar')=                  -0.87;  % use container.Map to store data

% Supply.CarPassenger('Women')=                  -0.5;  % use container.Map to store data
[~,~]=CheckSupply(Supply);

return