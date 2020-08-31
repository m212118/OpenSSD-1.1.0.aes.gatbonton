function predicted = model_FDAR_LOG(X_train, Y_train, X_test)
    
    % apply PFDA to training data
    proj = fdar(X_train, Y_train);
    Xp_train = X_train * proj;
    Xp_test  = X_test * proj;
    
    % train a quadratic discriminant model
    model = fitclinear(Xp_train, Y_train, 'Learner', 'logistic'); % old
    %way
     %model = fitglm(Xp_train, Y_train, 'Learner', 'logistic');
    % use model to generate predictions on test data
    predicted = predict(model, Xp_test);

end