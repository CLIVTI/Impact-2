function ModelStructure=SpecifySupply_SPD3(CostScaleParameter,DCValue,SeatCapacity)
% this function specifies the supply variables and it returns a structure that stores all supply variables and parameter
% values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All data comes from Ajsuna's excel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModelStructure={};
ScaleParameter=0.5;
ModelStructure.UtilityScaleParameter=CostScaleParameter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all parameters adn values should be included here.
% the Structure has the following structure:
% ModelStructure.PopulationSize gives the populationsize of each demand segment
% ModelStructure.Supply has the following structure
% ModelStructure.Supply.DemandSegment.Nest1_ChoiceAlternative.Nest2_ChoiceAlternative, then parameter and value paris stored in the
% container.Map
% Supply.PopulationSize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Naming convention: the same attribute name should be used if they have intrinsically same values
% e.g. travel time by rail for private and business should be the same, so using the same values.
% Important!!! Notice that the same attribute name does not necessarily mean the parameter values are the same, 
% e.g. travel time by rail for private can have parameter value -0.78 while travel time by rail for business have
% parameter value -2.65. Therefore, using the same attribute name whenever the attribute values are the same!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% specify the total population.
DemandRail=7560;
ModelStructure.PopulationSize.All=DemandRail/0.29;
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter.
% use container.Map to store data

% demand
% rail demand according to Elodie: 7500 is the value for the line from Paris to Lyon : 
% you have 510 seats per train (no standing travelers as it is not allowed in France), 12 trains per hour for peak, 90% of trains coupled and a load factor of 64%

% value of time using swedish ASEK, private travellers

% the variable list:
% Rail
InVehicleTimeRail=33; % invehicle rail: 108 min
CostRail=2.4*10.67; %  (13.5 euro *10.67 sek /euro)
WaitingTimeRail=60*1/12/2; % waiting time 60*1/12/2 min
FrequencyRail=60*1/WaitingTimeRail/2;
DelayRail=0; % delay: 4.08 min, calculated by assuming 91% accuracy, dvs, 9% trains have 20 min delay.
% Attractiveness values: all set as 1 in the baseline

% Value of time (sek/min) Rail
VOT_InVehRail=78/60;  
VOT_Delay=3.5*VOT_InVehRail; % VOTDelay is set as 3.5* VOT_InVehRail
VOT_WaitingRail=41/60;
VOT_Booking=0.21*10.67; 
VOT_Information=0.37*10.67/108; 
VOT_Service=0.53*10.67/108; 



% Bus
InVehicleTimeBus=151;
CostBus=2.4*10.67;
WaitingTimeBus=60*1/1/2;
FrequencyBus=60*1/WaitingTimeBus/2;
AccessTimeBus=5; % 113 min by walk

% Value of time (sek/min) Bus
VOT_InVehBus=42/60;  
VOT_WaitingTimeBus=11/60;
VOT_AccessTimeBus=11/60;

% Car
InVehicleTimeCar=21;
CostCar=2.63*10.67;

% Value of time (sek/min) Car
VOT_InVehCar=116/60;

% Bike
InVehicleTimeBike=41;
% Value of time (sek/min) Car
VOT_InVehBike=134/60;
%% specify the in-data structure for the demand segment Private
ModelStructure.Supply.All.PT.Rail=containers.Map();     %    parameter,                                              value
ModelStructure.Supply.All.PT.Rail('ASCRail')=               [0,                                                             1];  
ModelStructure.Supply.All.PT.Rail('CostRail')=              [-CostScaleParameter(1),                                 CostRail];  % normalize cost parameters to 0.01, the scale parameter. Same variable name must be used in Specify population
ModelStructure.Supply.All.PT.Rail('FirstWaitTimeRail')=     [-CostScaleParameter(1).*VOT_WaitingRail,         WaitingTimeRail]; 
ModelStructure.Supply.All.PT.Rail('DelayRail')=             [-VOT_Delay.*CostScaleParameter(1),                   DelayRail]; 
ModelStructure.Supply.All.PT.Rail('Att_Booking')=           [(VOT_Booking.*CostScaleParameter(1)),              1];  % here
ModelStructure.Supply.All.PT.Rail('Att_Information')=       [(VOT_Information.*CostScaleParameter(1)),          InVehicleTimeRail*1];  % here
ModelStructure.Supply.All.PT.Rail('Att_Service')=           [(VOT_Service.*CostScaleParameter(1)),              InVehicleTimeRail*1];  % here
ModelStructure.Supply.All.PT.Rail('DiscomfortRail')=        [-InVehicleTimeRail*VOT_InVehRail.*CostScaleParameter(1),       DCValue(1)^((DemandRail)/(SeatCapacity(1)*FrequencyRail))];   % switch the parameter and value, here (130/60) means 130/60 h travel time, and -1.1^(3882/3614) is the discomfort parameter.
ModelStructure.Supply.All.PT.Rail('ScaleParameter')=        ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.All.PT.Bus=containers.Map();  %     parameter                       , value
ModelStructure.Supply.All.PT.Bus('ASCBus')=              [0,                                                   1];  % use container.Map to store data
ModelStructure.Supply.All.PT.Bus('CostBus')=             [-CostScaleParameter(1),                            CostBus]; 
ModelStructure.Supply.All.PT.Bus('InVehBus')=            [-VOT_InVehBus.*CostScaleParameter(1),        InVehicleTimeBus];  
ModelStructure.Supply.All.PT.Bus('FirstWaitTimeBus')=    [-VOT_WaitingTimeBus.*CostScaleParameter(1),     WaitingTimeBus]; 
ModelStructure.Supply.All.PT.Bus('AccessTimeBus')=       [-VOT_AccessTimeBus.*CostScaleParameter(1),     AccessTimeBus]; 
ModelStructure.Supply.All.PT.Bus('ScaleParameter')=         ScaleParameter;  
%% specify the parameter and variable values
ModelStructure.Supply.All.Car=containers.Map();           %   parameter              , value
ModelStructure.Supply.All.Car('ASCCar')=          [0,                           1];  % use container.Map to store data
ModelStructure.Supply.All.Car('CostCar')=         [-CostScaleParameter(1),                   CostCar]; 
ModelStructure.Supply.All.Car('InVehCar')=        [-VOT_InVehCar.*CostScaleParameter(1),          InVehicleTimeCar];  
% ModelStructure.Supply.All.Car('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.All.Bike=containers.Map();   
ModelStructure.Supply.All.Bike('ASCBike')=          [0,                           1];  % use container.Map to store data
ModelStructure.Supply.All.Bike('InVehBike')=        [-VOT_InVehBike.*CostScaleParameter(1),          InVehicleTimeBike];  
return