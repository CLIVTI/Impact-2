function [ fvalOfElite, xVal,fvalPop ] = GeneticAlgorithm( fun, valMin, valMax, tolerance, popSize, generationsNum, crossProb, mutateProb )
%GAGO genetic algorithm
% 
% output:
% fvalOfElite: the minimum of the function
% xVal: the point that the function gets the minimum
% 
% input:
% fun: the name of the function, e.g. 'afunc'
% valMin: the low limitation of the variables, e.g. [-10,-pi]
% valMax: the high limitation of the variables, e.g. [3,exp(1)]
% tolerance: the tolerance during calculation, e.g. 1e-4
% popSize: the size of population, must be a positive even integer, e.g. 100
% generationsNum: the number of generations, the terminal criteria, e.g. 200
% crossProb: the probability of crossing over, e.g. 0.6
% mutateProb: the probability of mutation, e.g. 0.1
% 
% example:
% let there be a function afunc.m
%  function [ y ] = afunc( x )
%  y=(x(1)-1)^2+x(2)^2;
%  end
% so run the following in command window:
%  [fmin, x] = gago('afunc',[-4,-4],[4,4], 1e-4,100,200,0.6,0.1)
% you will get:
%  fmin =
% 
%     2.7163e-06
% 
% 
%  x =
% 
%      1.0016   -0.0003
% 
[initPop, chromosomeEachSizes, chromosomeSize] = init(popSize, tolerance, valMin, valMax);
pop = initPop;
i=1;
flag=0;
while i <= generationsNum && flag==0
    [ fvals, ~ ] = decodeandcal (fun ,pop ,chromosomeEachSizes ,valMin ,valMax);
    [ popNewSub, elite, ~,~] = selectchromo( pop, fvals );
    [ popNewSub ] = crossover(popNewSub,crossProb);
%     popOld=pop;
%     if sum(sum(popOld(chromosomeSelected,:)==popNewSub))==(size(popNewSub,1)*size(popNewSub,2))
%         flag=1;
%     end
    % popNewSub = popTemp(chromosomeSelected,:);
    [ popNewSub ] = mutate( popNewSub, mutateProb);
    chromosomeRandom = randi([0,1], [1,chromosomeSize]);
    pop = [popNewSub;chromosomeRandom;elite];
    [ fvalOfElite, ~ ] = decodeandcal (fun ,elite ,chromosomeEachSizes ,valMin ,valMax);
    i = i + 1;
    fprintf('The best value of Iteration %-15s is: %-8.5f\n', num2str(i), fvalOfElite )
end
[ fvalOfElite, xVal ] = decodeandcal (fun ,elite ,chromosomeEachSizes ,valMin ,valMax);
[ fvalPop, ~ ] = decodeandcal (fun ,pop ,chromosomeEachSizes ,valMin ,valMax);
end

function [ initPop, chromosomeEachSizes, chromosomeSize ] = init( popSize, tolerance, valMin, valMax)
%INIT Generate the initial populations
% output:
% initPop: the initial population, each row is a chromosome
% chromosomeEachSizes: the vector of bit lengths of each variable
% chromosomeSize: the summarized bits length
% input:
% popSize: how many populations there are
% tolerance: the tolerance of the result, e.g. 1e-4
% valMin: the low limitation of the x, e.g. [-10, -100]
% valMax: the high limitation of the x, e.g. [10, 50]
chromosomeEachSizes = ceil( log2( (valMax-valMin)./tolerance ) );
chromosomeSize = sum(chromosomeEachSizes);
initPop = randi([0,1], [popSize,chromosomeSize]);
end

function [ fvals, varsTransformed ] = decodeandcal (fun ,pop ,chromosomeEachSizes ,valMin ,valMax)
%DECODEANDCAL Check the function and variables values
% output:
% fvals: the vector of value of function
% varsTransformed: the variables transformed from chromosomes
% input:
% fun: the name of the function to be optimizated
% pop: the previous population generated
% chromosomeEachSizes: the vector of bit length of each variable
% valMin: the low limitation of the x, e.g. [-10, -100]
% valMax: the high limitation of the x, e.g. [10, 50]
varNum = length(chromosomeEachSizes); % the number of variables
popSize = size(pop ,1);
transformed = (valMax-valMin) ./ (2.^chromosomeEachSizes-1); % the scale of values
chromosomeEachSizes = [0 cumsum(chromosomeEachSizes)];
for i = 1:varNum
    popVar{i} = pop(:, chromosomeEachSizes(i) + 1:chromosomeEachSizes(i + 1) );
    % the subpop with subchromosomes_i
    var{i} = sum(ones(popSize ,1)*2.^(size(popVar{i},2)-1:-1 :0).*popVar{i} ,2) .* transformed(i) + valMin(i) ;
end
varsTransformed = [var{1,:}];
% varsTransformed(:,2)=round(varsTransformed(:,2));   %%%%%%%%%%%%%%%%%%%%%%%%assuming 2nd row is integer
for i = 1 :popSize
    fvals(i) = eval([fun ,'(varsTransformed(i , :) )']);
end
end

function [ popNewSub, elite, fvalOfElite,chromosomeSelected ] = selectchromo( popPrev, fvals )
%SELECTCHROMO Select, choose sub new population and elite
% output:
% popNewSub: the new sub population (size = size-2)
% elite: the elite chromosome of previous population
% input:
% popPrev: the previous population
% fvals: the function values of previous population
fitness = (max(fvals)-fvals)';
popSize = size(popPrev,1);
[fitnessMin, indexMin] = min(fitness);
[fitnessMax, indexMax] = max(fitness);
elite = popPrev(indexMax,:); % the min-fval aka the best individial
fvalOfElite = fvals(indexMax); % the function value on elite
listTemp = [1:popSize];
listTemp(indexMin) = 0;
listTemp(indexMax) = 0;
listTemp = nonzeros(listTemp);
popTemp = popPrev(listTemp,:);
fitnessTemp = fitness(listTemp,:);
popSizeToBeRenew = popSize - 2;
probAdded = cumsum(fitnessTemp / sum(fitnessTemp));
chromosomeSelected = sum(probAdded*ones(1,popSizeToBeRenew)<ones(popSizeToBeRenew,1)*rand(1,popSizeToBeRenew))+1;
popNewSub = popTemp(chromosomeSelected,:);
end

function [ popNew ] = crossover( popPrev, crossProb )
%CROSSOVER Generate the new population by crossing over
% output:
% popNew: the new generated population
% input:
% popPrev: the previous population
% crossProb: the probability of crossing over
[new, sortIndex] = sort(rand(size(popPrev ,1) ,1));
popSorted = popPrev(sortIndex, :);
pairsNum = size(popSorted, 1)/2;
chromosomeEachSizes = size(popSorted, 2);
parisToCross = rand(pairsNum, 1) < crossProb;
pointsToCross = parisToCross.*randi([1,chromosomeEachSizes],[pairsNum, 1]);
for i=1:pairsNum
    popNew([2*i-1,2*i],:)=[popSorted([2*i-1,2*i],1:pointsToCross(i)), popSorted([2*i,2*i-1],pointsToCross(i)+1:chromosomeEachSizes)];
end
end

function [ popNew ] = mutate( popPrev, mutateProb )
%MUTATE Generate the new population by mutation
% output:
% popNew: the new generated population
% input:
% popPrev: the previous population
% mutateProb: the probability of mutation
popNew = popPrev;
pointsToMutate = find(rand(size(popPrev))< mutateProb);
popNew(pointsToMutate) = 1 - popPrev(pointsToMutate);
end

