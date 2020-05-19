function Supply=SpecifySupply_Regional()
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
ScaleParameter=0.73; % scale parameter should be multiplied by everything except ASC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Supply has the following structure: 
% Supply.ModeChoiceAlternativeName.VariableName.Parameter stores the parameter value for VariableName in ModeChoiceAlternativeName
% Supply.ModeChoiceAlternativeName.VariableName.Attribute stores the attribute value for VariableName in ModeChoiceAlternativeName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter.
Supply.Rail=containers.Map();           %     parameter                           , value
Supply.Rail('InVehRail')=               [-0.014*ScaleParameter,                       69];  % use container.Map to store data
Supply.Rail('FirstWaitRail')=           [-0.014*1.5*ScaleParameter,                    6];
Supply.Rail('AccessTimeRail')=          [-0.014*2*ScaleParameter,                     10];
Supply.Rail('TransferTimeRail')=        [-0.014*1.5*ScaleParameter,                    0];
Supply.Rail('NumberTransferRail')=      [-0.014*5*ScaleParameter,                      0];
Supply.Rail('CostRail')=                [-0.015*ScaleParameter,                 44/0.097];
Supply.Rail('DelayRail')=               [3.5*(-0.014)*ScaleParameter,       4.08]; % delay parameter according to Ida is 3.5*VOT (sek/h)*beta_cost/60 =3.5*VOT(sek/min)*beta_cost=3.5*beta_time. % note that VOT=beta_time/beta_cost.
Supply.Rail('DensityAtDestination')=    [0.000004*ScaleParameter,                 6021.4]; % google Berlin population/job density!!!!!!!!!!!!!!!!!!!!!!!!
Supply.Rail('ASCRail')=                 [-0.758,                                       1];
Supply.Rail('AttractivenessRail')=      [0*ScaleParameter,                             1];

%% specify the parameter and variable values for mode alterantive bus. exact the same parameters and variables as bus.
Supply.Bus=containers.Map();           %     parameter                           , value
Supply.Bus('InVehBus')=               [-0.014*ScaleParameter,                       70];  
Supply.Bus('FirstWaitBus')=            [-0.014*1.5*ScaleParameter,                    6];
Supply.Bus('AccessTimeBus')=           [-0.014*2*ScaleParameter,                     10];
Supply.Bus('TransferTimeBus')=         [-0.014*1.5*ScaleParameter,                    0];
Supply.Bus('NumberTransferBus')=       [-0.014*5*ScaleParameter,                      0];
Supply.Bus('CostBus')=                 [-0.019*ScaleParameter,                      100];
Supply.Bus('DelayBus')=                [3.5*(-0.014)*ScaleParameter,                  0];  % ingen delay för buss
Supply.Bus('DensityAtDestination')=    [0.000004*ScaleParameter,                 6021.4];
Supply.Bus('ASCBus')=                  [-0.758,                                       1];



%% specify the parameter and variable values for mode alterantive CarDriver
% for car time, please specify free flow travel time here. Congestion effect will be considered,
% and the attribute of Time will be iterated. (min)
Supply.CarDriver=containers.Map();           %     parameter                           , value
Supply.CarDriver('TimeCar')=               [-0.039*ScaleParameter,                       70]; 
Supply.CarDriver('CostCarDriver')=         [-0.015*ScaleParameter,                   70*1.8]; 
Supply.CarDriver('DensityAtDestination')=  [-0.000002*ScaleParameter,                6021.4]; 
Supply.CarDriver('HaveCarInHH')=            3.388*ScaleParameter; 
Supply.CarDriver('CarCompetition')=        -1.619*ScaleParameter;
Supply.CarDriver('HouseholdSize')=          0.244*ScaleParameter;
Supply.CarDriver('MotherDistance')=        -0.012*ScaleParameter;
Supply.CarDriver('Women')=                 -1.245*ScaleParameter;



%% specify the parameter and variable values for mode alterantive CarPassenger
Supply.CarPassenger=containers.Map();           %     parameter                           , value
Supply.CarPassenger('TimeCar')=               [-0.050*ScaleParameter,                       70];
Supply.CarPassenger('CostCarPassenger')=      [-0.015*ScaleParameter,                70.*1.8/2];
Supply.CarPassenger('MotherDistance')=         -0.012*ScaleParameter;
Supply.CarPassenger('ASCCarPassenger')=       [-0.028,                1];

CheckSupply(Supply);


return