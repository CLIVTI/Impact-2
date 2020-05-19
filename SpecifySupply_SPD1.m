function ModelStructure=SpecifySupply_SPD1(CostScaleParameter,DCValue,SeatCapacity)
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
ModelStructure.PopulationSize.All=3750/0.16825;
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter.
% use container.Map to store data

% demand
% rail demand according to Elodie: 7500 is the value for the line from Paris to Lyon : 
% you have 510 seats per train (no standing travelers as it is not allowed in France), 12 trains per hour for peak, 90% of trains coupled and a load factor of 64%

% all parameter values are current using the swedish value of time appraisal.
% below calculates the value of attractiveness from the workshop, the values are defined as sek per min travel of the
% service
Value_of_Booking=6.11*10.67; 
Value_of_Information=7.33*10.67/130; 
Value_of_Service=6.44*10.67/130; 

% the variable list:
% Rail:
% cost: 47*10.67 (47 euro *10.67 sek /euro)
% invehicle rail: 130 min
% frequency: waiting time 60*1/12/2 min, 
% delay: 5.25 min, calculated by assuming 90% accuracy, dvs, 10% trains have 30 min delay.
% Attractiveness values: all set as 1 in the baseline

% Bus
% cost: 14.99*10.67 
% invehicle bus: 342 min
% frequency: 2 buses per hour
% AccessTimeBus: 29 min by walk

% Air
% cost: 115 *10.67
% InVehPeakAir: 70 min
% frequency: 1 flight per hour
% FirstWaitTimeAir: All assuming 1 hour early at airport
% FrequencyWaitTimeAir: 78 min to airport from citycenter

% Car
% cost:  68.28*10.67
% 
%% specify the in-data structure for the demand segment Private
ModelStructure.Supply.All.Rail=containers.Map();     %    parameter,                                              value
ModelStructure.Supply.All.Rail('ASCRail')=               [0,                                                           1];  
ModelStructure.Supply.All.Rail('CostRail')=              [-CostScaleParameter(1),                               47*10.67];  % normalize cost parameters to 0.01, the scale parameter. Same variable name must be used in Specify population
ModelStructure.Supply.All.Rail('FirstWaitTimeRail')=     [-CostScaleParameter(1).*218/60,                       60*1/6/2]; 
ModelStructure.Supply.All.Rail('DelayRail')=             [-3.5*265/60.*CostScaleParameter(1),                        4.25]; 
ModelStructure.Supply.All.Rail('Att_Booking')=           [(Value_of_Booking.*CostScaleParameter(1)),                  1];  % here
ModelStructure.Supply.All.Rail('Att_Information')=       [(Value_of_Information.*CostScaleParameter(1)),          130*1];  % here
ModelStructure.Supply.All.Rail('Att_Service')=           [(Value_of_Service.*CostScaleParameter(1)),              130*1];  % here
ModelStructure.Supply.All.Rail('DiscomfortRail')=        [-130*(265/60).*CostScaleParameter(1),                  DCValue(1)^((7500)/(SeatCapacity(1)*6))];   % switch the parameter and value, here (130/60) means 130/60 h travel time, and -1.1^(3882/3614) is the discomfort parameter.
% ModelStructure.Supply.All.Rail('ScaleParameter')=        ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.All.Bus=containers.Map();  %     parameter                       , value
ModelStructure.Supply.All.Bus('ASCBus')=              [0,                                   1];  % use container.Map to store data
ModelStructure.Supply.All.Bus('CostBus')=             [-CostScaleParameter(1),    14.99*10.67]; 
ModelStructure.Supply.All.Bus('InVehBus')=            [-312/60.*CostScaleParameter(1),     342];  
ModelStructure.Supply.All.Bus('FirstWaitTimeBus')=    [-167/60.*CostScaleParameter(1),  60/2/2]; 
ModelStructure.Supply.All.Bus('AccessTimeBus')=       [-167/60.*CostScaleParameter(1),      29]; 
% ModelStructure.Supply.All.Air('ScaleParameter')=         ScaleParameter;  
%% specify the parameter and variable values
ModelStructure.Supply.All.Air=containers.Map();        %     parameter                             , value
ModelStructure.Supply.All.Air('ASCAir')=                 [0,                                              1];  % use container.Map to store data
ModelStructure.Supply.All.Air('CostAir')=                [-CostScaleParameter(1),                115 *10.67]; 
ModelStructure.Supply.All.Air('InVehPeakAir')=           [-312/60.*CostScaleParameter(1),                70];  
ModelStructure.Supply.All.Air('FirstWaitTimeAir')=       [-312/60.*CostScaleParameter(1),                60];   % it is the "Total väntetid på flygplats" in the excel file
ModelStructure.Supply.All.Air('FrequencyWaitTimeAir')=   [-239/60.*CostScaleParameter(1),             60/2];
ModelStructure.Supply.All.Air('AccessTimeAir')=          [-312/60.*CostScaleParameter(1),                78];   
% ModelStructure.Supply.All.Air('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.All.Car=containers.Map();           %   parameter              , value
ModelStructure.Supply.All.Car('ASCCar')=          [0,                           1];  % use container.Map to store data
ModelStructure.Supply.All.Car('CostCar')=         [-CostScaleParameter(1),                 68.28*10.67]; 
ModelStructure.Supply.All.Car('InVehCar')=        [-312/60.*CostScaleParameter(1),                 258];  
% ModelStructure.Supply.All.Car('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
return