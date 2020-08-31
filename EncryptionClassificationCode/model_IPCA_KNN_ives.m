function predicted = model_IPCA_KNN_ives(X_train, Y_train, X_test,K)
    
    % apply PCA to training data
    proj = ipca(X_train, 0.9);
    Xp_train = X_train * proj;
    Xp_test  = X_test * proj;
    
    % train a quadratic discriminant model
    model = fitcknn(Xp_train, Y_train, 'NumNeighbors', K);
    
    % use model to generate predictions on test data
    predicted = predict(model, Xp_test);

end
