function performance = CrossValTest(X, Y, Func)

    if size(X,1) ~= size(Y,1)
        fprintf("Error: X and Y matrices have unequal rows!\n");
        return;
    end

    K = 10;
    kfold_index = crossvalind('Kfold', size(Y,1), 10);
    performance = classperf(cellstr(Y));
    for i = 1:K
        % create a training and testing set
        test = (kfold_index == i); train = (kfold_index ~= i);
        X_train = X(train, :);
        Y_train = Y(train);
        X_test  = X(test, :);
        
        % externally defined model is trained and creates predictions
        predicted = Func(X_train, Y_train, X_test);
        
        % use results to generate performance report
        classperf(performance, predicted, test);
    end
end