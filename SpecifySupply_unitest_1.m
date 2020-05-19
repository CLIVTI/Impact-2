function ModelStructure=SpecifySupply_unitest_1()
% this function specifies the supply variables and it returns a structure that stores all supply variables and parameter
% values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All data comes from Ajsuna's excel file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModelStructure={};
ScaleParameter=0.5;
ModelStructure.UtilityScaleParameter=[0.01,0.01];
CostScaleParameter=ModelStructure.UtilityScaleParameter;
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

ModelStructure.PopulationSize.Private=1;
ModelStructure.PopulationSize.Business=1;
%% specify the parameter and variable values for mode alterantive rail 
% remember to multiply supply parameters with ScaleParameter.
% use container.Map to store data
%% specify the in-data structure for the demand segment Private
ModelStructure.Supply.Private.Peak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Private.Peak.Rail('ASCPrivatePeakRail')=        [0,                       1];  
ModelStructure.Supply.Private.Peak.Rail('CostPrivatePeakRail')=       [-CostScaleParameter(1),                  403];
ModelStructure.Supply.Private.Peak.Rail('ScaleParameter')=        0.5;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Peak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Peak.Bus('ASCPrivatePeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Peak.Bus('CostPrivatePeakBus')=       [-CostScaleParameter(1),                  403];
ModelStructure.Supply.Private.Peak.Bus('ScaleParameter')=         0.5;  
%%
ModelStructure.Supply.Private.Offpeak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Private.Offpeak.Rail('ASCPrivateOffpeakRail')=        [0,                       1];  
ModelStructure.Supply.Private.Offpeak.Rail('CostPrivateOffpeakRail')=       [-CostScaleParameter(1),                  403];
ModelStructure.Supply.Private.Offpeak.Rail('ScaleParameter')=        0.5;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Private.Offpeak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Private.Offpeak.Bus('ASCPrivateOffpeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Private.Offpeak.Bus('CostPrivateOffpeakBus')=       [-CostScaleParameter(1),                  403];
ModelStructure.Supply.Private.Offpeak.Bus('ScaleParameter')=         0.5;  
%%
ModelStructure.Supply.Business.Peak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Business.Peak.Rail('ASCPrivatePeakRail')=        [0,                       1];  
ModelStructure.Supply.Business.Peak.Rail('CostBusinessPeakRail')=       [-CostScaleParameter(2),                  950];
ModelStructure.Supply.Business.Peak.Rail('ScaleParameter')=        0.5;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Business.Peak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Peak.Bus('ASCPrivatePeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Peak.Bus('CostBusinessPeakBus')=       [-CostScaleParameter(2),                  950];
ModelStructure.Supply.Business.Peak.Bus('ScaleParameter')=         0.5;  
%%
ModelStructure.Supply.Business.Offpeak.Rail=containers.Map();     %     parameter,             value
ModelStructure.Supply.Business.Offpeak.Rail('ASCPrivateOffpeakRail')=        [0,                       1];  
ModelStructure.Supply.Business.Offpeak.Rail('CostBusinessOffpeakRail')=       [-CostScaleParameter(2),                  950];
ModelStructure.Supply.Business.Offpeak.Rail('ScaleParameter')=        0.5;  % make sure you use 'ScaleParameter' as the key name!!!!! strictly the same!!!!!
%% specify the parameter and variable values
ModelStructure.Supply.Business.Offpeak.Bus=containers.Map();           %     parameter              , value
ModelStructure.Supply.Business.Offpeak.Bus('ASCPrivateOffpeakBus')=          [0,                       1];  % use container.Map to store data
ModelStructure.Supply.Business.Offpeak.Bus('CostBusinessOffpeakBus')=       [-CostScaleParameter(2),                  950];
ModelStructure.Supply.Business.Offpeak.Bus('ScaleParameter')=         0.5;  
return