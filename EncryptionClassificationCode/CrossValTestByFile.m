function performance = CrossValTestByFile(X, Y,filelabels,Func)

    if size(X,1) ~= size(Y,1)
        fprintf("Error: X and Y matrices have unequal rows!\n");
        return;
    end

    K = 10;

    %kfold_index = crossvalind('Kfold', size(Y,1), 10);
    % the following produces a list of 10 random integers from 1 to 10,
    % which will be used to identify the hold-out file observations for 10-fold
    % cross-validation
    kfold_index = crossvalind('Kfold',K,K);
    
    performance = classperf(cellstr(Y));
    overallaccuracy=0.0;
    for i = 1:K
        % create a training and testing set
        %test = (kfold_index == i); train = (kfold_index ~= i);
        test = find(filelabels==kfold_index(i)); % logical vector, 1s identify test set
        train = find(filelabels~=kfold_index(i)); % logical vector, 1s identify training set
        
        X_train = X(train, :);
        Y_train = Y(train);
        X_test  = X(test, :);
        
        % externally defined model is trained and creates predictions
        predicted = Func(X_train, Y_train, X_test);
        
        % use results to generate performance report
        classperf(performance, predicted, test);
        overallaccuracy=overallaccuracy+performance.CorrectRate;
       
    end
    overallaccuracy=overallaccuracy/10;
    disp(sprintf('in CrossValTestByFile, Overall Accuracy after 10 folds = %f',overallaccuracy))
end