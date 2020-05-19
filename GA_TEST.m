[fmin, x,fvalPop] = GeneticAlgorithmTest('afunc',[-5,-5],[5,9], 1e-5,100,200,0.6,0.1,0.2);
fmin
x
hist(fvalPop)
find(fvalPop==fmin)