function ModelStructure=SpecifySupply_Stcokholm_Gothenburg(CostScaleParameter,DCValue,SeatCapacity)
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

ModelStructure.PopulationSize.Private=1992+55+778+800+1707+387+722+54;
ModelStructure.PopulationSize.Business=991+2+642+182;
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter.
% use container.Map to store data
%% specify the in-data structure for the demand segment Private
ModelStructure.Supply.Private.Peak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Private.Peak.Rail('ASCPrivatePeakRail')=        [0,                       1];  
ModelStructure.Supply.Private.Peak.Rail('CostPrivatePeakRail')=       [-CostScaleParameter(1),                  403];  % normalize cost parameters to 0.01, the scale parameter. Same variable name must be used in Specify population
ModelStructure.Supply.Private.Peak.Rail('FirstWaitTimePeakRail')=     [-CostScaleParameter(1).*41/60,            1/(14/7)*60/2];  % here
ModelStructure.Supply.Private.Peak.Rail('DiscomfortPrivatePeakRail')=        [3*78.*CostScaleParameter(1),           -DCValue(1)^((1992+991)/(SeatCapacity(1)*14))];   % switch the parameter and value, here 3 means 3 h travel time, and -1.1^(3882/3614) is the discomfort parameter.
ModelStructure.Supply.Private.Peak.Rail('ScaleParameter')=        ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Peak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Peak.Bus('ASCPrivatePeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Peak.Bus('CostPrivatePeakBus')=         [-CostScaleParameter(1),                 250]; 
ModelStructure.Supply.Private.Peak.Bus('InVehPeakBus')=               [-42.*CostScaleParameter(1),                   7];  
ModelStructure.Supply.Private.Peak.Bus('FirstWaitTimePeakBus')=       [-11/60.*CostScaleParameter(1),             1/(1/7)*60/2]; 
ModelStructure.Supply.Private.Peak.Bus('ScaleParameter')=         ScaleParameter;  
%% specify the parameter and variable values
ModelStructure.Supply.Private.Peak.Air=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Peak.Air('ASCPrivatePeakAir')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Peak.Air('CostPrivatePeakAir')=         [-CostScaleParameter(1),                1760]; 
ModelStructure.Supply.Private.Peak.Air('InVehPeakAir')=               [-116.*CostScaleParameter(1),                   1];  
ModelStructure.Supply.Private.Peak.Air('FirstWaitTimePeakAir')=       [-116.*CostScaleParameter(1),                 1.25];   % it is the "Total v�ntetid p� flygplats" in the excel file
ModelStructure.Supply.Private.Peak.Air('FrequencyWaitTimePeakAir')=       [-60/60.*CostScaleParameter(1),          1/(14/7)*60/2];
ModelStructure.Supply.Private.Peak.Air('AccessTimePrivatePeakAir')=          [-158.*CostScaleParameter(1),                0.75];   
ModelStructure.Supply.Private.Peak.Air('AccessCostPrivateAir')=       [-CostScaleParameter(1),                  99]; 
ModelStructure.Supply.Private.Peak.Air('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Peak.Car=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Peak.Car('ASCPrivatePeakCar')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Peak.Car('CostPrivatePeakCar')=         [-CostScaleParameter(1),                 422]; 
ModelStructure.Supply.Private.Peak.Car('InVehPeakCar')=               [-116.*CostScaleParameter(1),                   6];  
ModelStructure.Supply.Private.Peak.Car('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Offpeak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Private.Offpeak.Rail('ASCPrivateOffpeakRail')=        [0,                       1];  
ModelStructure.Supply.Private.Offpeak.Rail('CostPrivateOffpeakRail')=       [-CostScaleParameter(1)                  378];  % normalize cost parameters to 0.01, the scale parameter. Same variable name must be used in Specify population
ModelStructure.Supply.Private.Offpeak.Rail('FirstWaitTimeOffpeakRail')=     [-41/60.*CostScaleParameter(1),            1/(12/9)*60/2];
ModelStructure.Supply.Private.Offpeak.Rail('DiscomfortPrivateOffpeakRail')=        [3*78.*CostScaleParameter(1),        -DCValue(2)^((1707+99)/(SeatCapacity(2)*12))];
ModelStructure.Supply.Private.Offpeak.Rail('ScaleParameter')=        ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Offpeak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Offpeak.Bus('ASCPrivateOffpeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Offpeak.Bus('CostPrivateOffpeakBus')=         [-CostScaleParameter(1),                  180]; 
ModelStructure.Supply.Private.Offpeak.Bus('InVehOffpeakBus')=              [-42.*CostScaleParameter(1),                    7];  
ModelStructure.Supply.Private.Offpeak.Bus('FirstWaitTimeOffpeakBus')=       [-11/60.*CostScaleParameter(1),               1/(7/9)*60/2]; 
ModelStructure.Supply.Private.Offpeak.Bus('ScaleParameter')=        ScaleParameter; 
%% specify the parameter and variable values
ModelStructure.Supply.Private.Offpeak.Air=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Offpeak.Air('ASCPrivateOffpeakAir')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Offpeak.Air('CostPrivateOffpeakAir')=         [-CostScaleParameter(1),                 421]; 
ModelStructure.Supply.Private.Offpeak.Air('InVehOffpeakAir')=               [-116.*CostScaleParameter(1),                   1];  
ModelStructure.Supply.Private.Offpeak.Air('FirstWaitTimeOffpeakAir')=       [-116.*CostScaleParameter(1),                1.25];   % it is the "Total v�ntetid p� flygplats" in the excel file
ModelStructure.Supply.Private.Offpeak.Air('FrequencyWaitTimeOffpeakAir')=   [-60/60.*CostScaleParameter(1),             1/(13/9)*60/2];  
ModelStructure.Supply.Private.Offpeak.Air('AccessTimePrivateOffpeakAir')=   [-158.*CostScaleParameter(1),                0.75];   
ModelStructure.Supply.Private.Offpeak.Air('AccessCostPrivateAir')=          [-CostScaleParameter(1),                  99]; 
ModelStructure.Supply.Private.Offpeak.Air('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Offpeak.Car=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Offpeak.Car('ASCPrivateOffpeakCar')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Offpeak.Car('CostPrivateOffpeakCar')=         [-CostScaleParameter(1),                 422]; 
ModelStructure.Supply.Private.Offpeak.Car('InVehOffpeakCar')=               [-116.*CostScaleParameter(1),                   5];  
ModelStructure.Supply.Private.Offpeak.Car('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!

%% specify the in-data structure for the demand segment Business
ModelStructure.Supply.Business.Peak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Business.Peak.Rail('ASCBusinessPeakRail')=        [0,                       1];  
ModelStructure.Supply.Business.Peak.Rail('CostBusinessPeakRail')=       [-CostScaleParameter(2),                 950];  % normalize cost parameters to 0.01, the scale parameter. Same variable name must be used in Specify population
ModelStructure.Supply.Business.Peak.Rail('FirstWaitTimePeakRail')=     [-218/60.*CostScaleParameter(2),            1/(14/7)*60/2];
ModelStructure.Supply.Business.Peak.Rail('DiscomfortBusinessPeakRail')=        [3*265.*CostScaleParameter(2),        -DCValue(3)^((1992+991)/(SeatCapacity(1)*14))];
ModelStructure.Supply.Business.Peak.Rail('ScaleParameter')=        ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Business.Peak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Peak.Bus('ASCBusinessPeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Peak.Bus('CostBusinessPeakBus')=         [-CostScaleParameter(2),                 250]; 
ModelStructure.Supply.Business.Peak.Bus('InVehPeakBus')=               [-312.*CostScaleParameter(2),                   7];  
ModelStructure.Supply.Business.Peak.Bus('FirstWaitTimePeakBus')=       [-167/60.*CostScaleParameter(2),             1/(1/7)*60/2]; 
ModelStructure.Supply.Business.Peak.Bus('ScaleParameter')=         ScaleParameter;  
%% specify the parameter and variable values
ModelStructure.Supply.Business.Peak.Air=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Peak.Air('ASCBusinessPeakAir')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Peak.Air('CostBusinessPeakAir')=         [-CostScaleParameter(2),                1760]; 
ModelStructure.Supply.Business.Peak.Air('InVehPeakAir')=               [-312.*CostScaleParameter(2),                   1];  
ModelStructure.Supply.Business.Peak.Air('FirstWaitTimePeakAir')=       [-312.*CostScaleParameter(2),                 1.25];   % it is the "Total v�ntetid p� flygplats" in the excel file
ModelStructure.Supply.Business.Peak.Air('FrequencyWaitTimePeakAir')=   [-239/60.*CostScaleParameter(2),             1/(14/7)*60/2]; 
ModelStructure.Supply.Business.Peak.Air('AccessTimeBusinessPeakAir')=  [-312.*CostScaleParameter(2),                 0.30];   
ModelStructure.Supply.Business.Peak.Air('AccessCostBusinessAir')=       [-CostScaleParameter(2),                 295]; 
ModelStructure.Supply.Business.Peak.Air('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Business.Peak.Car=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Peak.Car('ASCBusinessPeakCar')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Peak.Car('CostBusinessPeakCar')=         [-CostScaleParameter(2),                 844]; 
ModelStructure.Supply.Business.Peak.Car('InVehPeakCar')=               [-312.*CostScaleParameter(2),                   6];  
ModelStructure.Supply.Business.Peak.Car('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the in-data structure for the demand segment Business
ModelStructure.Supply.Business.Offpeak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Business.Offpeak.Rail('ASCBusinessOffpeakRail')=        [0,                       1];  
ModelStructure.Supply.Business.Offpeak.Rail('CostBusinessOffpeakRail')=       [-CostScaleParameter(2),                 950];  % normalize cost parameters to 0.01, the scale parameter. Same variable name must be used in Specify population
ModelStructure.Supply.Business.Offpeak.Rail('FirstWaitTimeOffpeakRail')=     [-218/60.*CostScaleParameter(2),             1/(12/9)*60/2];
ModelStructure.Supply.Business.Offpeak.Rail('DiscomfortBusinessOffpeakRail')=        [3*265.*CostScaleParameter(2),        -DCValue(4)^((1707+99)/(SeatCapacity(2)*12))];
ModelStructure.Supply.Business.Offpeak.Rail('ScaleParameter')=        ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Business.Offpeak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Offpeak.Bus('ASCBusinessOffpeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Offpeak.Bus('CostBusinessOffpeakBus')=         [-CostScaleParameter(2),                 250]; 
ModelStructure.Supply.Business.Offpeak.Bus('InVehOffpeakBus')=               [-312.*CostScaleParameter(2),                   7];  
ModelStructure.Supply.Business.Offpeak.Bus('FirstWaitTimeOffpeakBus')=       [-167/60.*CostScaleParameter(2),             1/(7/9)*60/2]; 
ModelStructure.Supply.Business.Offpeak.Bus('ScaleParameter')=         ScaleParameter;  
%% specify the parameter and variable values
ModelStructure.Supply.Business.Offpeak.Air=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Offpeak.Air('ASCBusinessOffpeakAir')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Offpeak.Air('CostBusinessOffpeakAir')=         [-CostScaleParameter(2),                1760]; 
ModelStructure.Supply.Business.Offpeak.Air('InVehOffpeakAir')=               [-312.*CostScaleParameter(2),                   1];  
ModelStructure.Supply.Business.Offpeak.Air('FirstWaitTimeOffpeakAir')=       [-312.*CostScaleParameter(2),                 1.25];   % it is the "Total v�ntetid p� flygplats" in the excel file
ModelStructure.Supply.Business.Offpeak.Air('FrequencyWaitTimeOffpeakAir')=   [-239/60.*CostScaleParameter(2),             1/(13/9)*60/2]; 
ModelStructure.Supply.Business.Offpeak.Air('AccessTimeBusinessOffpeakAir')=  [-312.*CostScaleParameter(2),                 0.30];   
ModelStructure.Supply.Business.Offpeak.Air('AccessCostBusinessAir')=       [-CostScaleParameter(2),                 295]; 
ModelStructure.Supply.Business.Offpeak.Air('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Business.Offpeak.Car=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Offpeak.Car('ASCBusinessOffpeakCar')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Offpeak.Car('CostBusinessOffpeakCar')=         [-CostScaleParameter(2),                 844]; 
ModelStructure.Supply.Business.Offpeak.Car('InVehOffpeakCar')=               [-312.*CostScaleParameter(2),                   5];  
ModelStructure.Supply.Business.Offpeak.Car('ScaleParameter')=         ScaleParameter;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
return