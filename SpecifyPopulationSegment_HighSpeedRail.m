function Population=SpecifyPopulationSegment_HighSpeedRail()
% this function specifies the population segment and it returns a structure that stores all sociodemographic variables variables and parameter
% values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameter values come from Sampers report from ytan: Sampers4_rapport_v1.2.docx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% socio-demographic parameters are specified in then function SpecifySupply but variables are specified here.
% important to note that socio-demographic variables must have the same name as specified in SpecifySupply.
% all socio-demographic variables must be specified for a given population segment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Population has the following structure: 
% Population.PopulationSegmentName.VariableName stores the attribute value for VariableName in PopulationSegmentName
% Population.PopulationSegmentName.PopulationSize stores the number of individuals within this population segment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% currently specified socio-demographic variables
% Supply.CarDriver.HaveCarInHH.Parameter=3.388*ScaleParameter;
% Supply.CarDriver.CarCompetition.Parameter=-1.619*ScaleParameter;
% Supply.CarDriver.HouseholdSize.Parameter=0.244*ScaleParameter;
% Supply.CarDriver.MotherDistance.Parameter=-0.012*ScaleParameter;
% Supply.CarDriver.Women.Parameter=-1.245*ScaleParameter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Population={};
TotalPopolation=1000;
% TotalPopulationGermany=82576000;
% TotalFamilyGermanyWithMinorChil=41304000;
% OnePersonHHShare=0.418;
% TwoPersonHHShare=0.335;
% ThreePersonHHShare=0.12;
% TotalNumberOfMother=8956/11886*TwoPersonHHShare;

Population.TotalPopulation.PopulationSize=TotalPopolation; 
Population.TotalPopulation.NoCar=0.1;  
Population.TotalPopulation.Women=0.5; 

return