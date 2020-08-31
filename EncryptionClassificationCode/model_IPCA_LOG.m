function predicted = model_IPCA_LOG(X_train, Y_train, X_test)
    
    % apply PCA to training data
    proj = ipca(X_train, 0.9);
    Xp_train = X_train * proj;
    Xp_test  = X_test * proj;
    
    % train a quadratic discriminant model
    model = fitclinear(Xp_train, Y_train, 'Learner', 'logistic');
    %model = fitglm(Xp_train, Y_train, 'Learner', 'logistic');
    % use model to generate predictions on test data
    predicted = predict(model, Xp_test);

end