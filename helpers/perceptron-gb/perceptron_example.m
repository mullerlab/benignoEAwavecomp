clearvars;clc

%% ternary
nobs = 3000;
npreds = 2;

X = [randn(npreds,nobs/3), randn(npreds,nobs/3)+[14;0], randn(npreds,nobs/3)+[4;14]];
d = [ones(nobs/3,1); 2*ones(nobs/3,1); 3*ones(nobs/3,1)];
p = randperm(nobs);
X = X(:,p);
d = d(p);

classes = [1 2 3];

w = perceptronGB(X,d,classes);

%% binary
nobs = 1000;
npreds = 2;

X = [randn(npreds,nobs/2), randn(npreds,nobs/2)+[8;0]];
d = [zeros(nobs/2,1); ones(nobs/2,1)];
p = randperm(nobs);
X = X(:,p);
d = d(p);

classes = [0 1];

w = perceptronGB(X,d,classes);