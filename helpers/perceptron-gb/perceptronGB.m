function [w,acc] = perceptronGB(X,d,classes)
% X -- each row is a predictor; each column is an example/trial/observation/repetition
% d -- vector of labels; one entry for each example
% classes -- vector of all possible classes
% w -- binary: col vector of bias (first entry) and weights. multiclass: matrix
% of such column vectors in one-vs-rest scheme in order of classes vec
    nclasses = length(classes);
    if nclasses == 2 
        [w,acc] = perceptronBinary(X,d);
    elseif nclasses > 2
        [w,acc] = perceptronMulticlass(X,d,classes);
    end
end


function [w,acc] = perceptronBinary(X,d)
    [npreds, nobs] = size(X);
    eta = 0.05; % learning rate
    w = 0.1*randn(npreds+1, 1);
    d = (d == max(d));
    for ii = 1 : nobs
        x = [1; X(:,ii)];
        if w'*x > 0, y = 1; else, y = 0; end
        delta = d(ii) - y;
        w = w + eta*delta.*x;
    end
    tmp = w'*[ones(1,nobs); X];
    tmp(tmp>0) = 1;
    tmp(tmp<=0) = 0;
    acc = nnz(tmp'==d)/nobs;
end


function [w,acc] = perceptronMulticlass(X,d,classes)
    [npreds, nobs] = size(X);
    nclasses = length(classes);
    w = nan(npreds+1,nclasses);
    for ii = 1 : nclasses
        w(:,ii) = perceptronBinary( X , d == classes(ii) );
    end
    
    [M,cln] = max(w'*[ones(1,nobs); X]);
    acc = nnz(cln'==d)/nobs;
end
