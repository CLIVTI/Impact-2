function Population=SpecifyPopulationSegment_Stockholm_Gothenburg()
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
% TotalPopulationGermany=82576000;
% TotalFamilyGermanyWithMinorChil=41304000;
% OnePersonHHShare=0.418;
% TwoPersonHHShare=0.335;
% ThreePersonHHShare=0.12;
% TotalNumberOfMother=8956/11886*TwoPersonHHShare;

Population.Private.PopulationSize=3814; % check the excel file
Population.Private.Peak.Rail.CostPeakRail=403; 
Population.Private.Peak.Rail.FirstWaitTimePeakRail=1/13; 
Population.Private.Peak.Bus.CostPeakBus=250; 
Population.Private.Peak.Bus.FirstWaitTimePeakBus=1;
Population.Private.Peak.Air.CostPeakAir=1760; 
Population.Private.Peak.Air.FirstWaitTimePeakAir=1.25;
Population.Private.Peak.Air.AccessTimePeakAir=0.75;
Population.Private.Peak.Air.AccessCostPeakAir=99;
Population.Private.Peak.Car.CostPeakCar=422; 
Population.Private.Peak.Car.InVehPeakCar=6; 


% Population.MotherWithCar.PopulationSize=TotalPopolation*0.094*0.9;  % 0.094 9.4% population are mother, data comes from: https://www.destatis.de/EN/FactsFigures/Indicators/LongTermSeries/Population/lrbev05.html. we assume 90% mothers have a car
% Population.MotherWithCar.HaveCarInHH=1;  % since this is a dummy variable, we use 1 for those who have car in household
% Population.MotherWithCar.CarCompetition=0.75;   % according to www.demand.ac.uk/wp-content/uploads/2017/03/25-EC1-Tobias-Kuhnimhof.pdf, half of car owning households have as many cars as adults (assuming all have driving license)
% Population.MotherWithCar.HouseholdSize=3.61; % data comes from https://www.destatis.de/EN/FactsFigures/SocietyState/Population/HouseholdsFamilies/Tables/Families.html
% Population.MotherWithCar.MotherDistance=70; 
% Population.MotherWithCar.Women=1; 

% Population.MotherWithoutCar.PopulationSize=TotalPopolation*0.094*0.1;
% Population.MotherWithoutCar.HaveCarInHH=0;  
% Population.MotherWithoutCar.CarCompetition=0; 
% Population.MotherWithoutCar.HouseholdSize=3.61; 
% Population.MotherWithoutCar.MotherDistance=70; 
% Population.MotherWithoutCar.Women=1;
% 
% Population.WomenNoChildWithCar.PopulationSize=TotalPopolation*0.5*0.57;  % 57% share of couples without children can be found: https://www.destatis.de/EN/FactsFigures/SocietyState/Population/HouseholdsFamilies/Tables/Couples.html
% Population.WomenNoChildWithCar.HaveCarInHH=1;  
% Population.WomenNoChildWithCar.CarCompetition=0.5; 
% Population.WomenNoChildWithCar.HouseholdSize=1.8; 
% Population.WomenNoChildWithCar.MotherDistance=0; 
% Population.WomenNoChildWithCar.Women=1;
% 
% Population.WomenNoChildWithoutCar.PopulationSize=200000;
% Population.WomenNoChildWithoutCar.HaveCarInHH=0;  
% Population.WomenNoChildWithoutCar.CarCompetition=0; 
% Population.WomenNoChildWithoutCar.HouseholdSize=1.8; 
% Population.WomenNoChildWithoutCar.MotherDistance=0; 
% Population.WomenNoChildWithoutCar.Women=1;
% 
% Population.MenWithCar.PopulationSize=200000;
% Population.MenWithCar.HaveCarInHH=1;  
% Population.MenWithCar.CarCompetition=0.5; 
% Population.MenWithCar.HouseholdSize=1.8; 
% Population.MenWithCar.MotherDistance=0; 
% Population.MenWithCar.Women=0;
% 
% Population.MenWithoutCar.PopulationSize=200000;
% Population.MenWithoutCar.HaveCarInHH=0;  
% Population.MenWithoutCar.CarCompetition=0; 
% Population.MenWithoutCar.HouseholdSize=1.8; 
% Population.MenWithoutCar.MotherDistance=0; 
% Population.MenWithoutCar.Women=0;
return