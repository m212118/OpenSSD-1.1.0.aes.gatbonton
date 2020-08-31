function predicted = model_SVM(X_train, Y_train, X_test)
    global K
    % apply PCA to training data
    proj = ipca(X_train, 0.9);
    Xp_train = X_train * proj;
    Xp_test  = X_test * proj;
    
    % train a quadratic discriminant model
    model = fitcsvm(Xp_train, Y_train, 'KernalFunction', 'linear');
    
    % use model to generate predictions on test data
    predicted = predict(model, Xp_test);

end
