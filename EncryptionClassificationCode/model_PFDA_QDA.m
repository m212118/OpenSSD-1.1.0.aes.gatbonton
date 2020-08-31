function predicted = model_PFDA_QDA(X_train, Y_train, X_test)
    
    % apply PFDA to training data
    proj = pfda(X_train, Y_train);
    Xp_train = X_train * proj;
    Xp_test  = X_test * proj;
    
    % train a quadratic discriminant model
    model = fitcdiscr(Xp_train, Y_train, 'DiscrimType', 'quadratic');
    
    % use model to generate predictions on test data
    predicted = predict(model, Xp_test);

end