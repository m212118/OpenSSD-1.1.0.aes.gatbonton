% Running CheckAllPerformance_BinaryClassifier_CrossValidation.m will
% generate the feature matrix and labels for which to do cross-validation
% testing. labels{1} are the class names for each observation, and
% labels{2} are the file numbers for each class' observations.
load feats_for_crossval_testing.mat

classes = ["Key_1010", "Key_half1_half0"];
%classes = ["class1","class2"];
classifier1=["IPCA_LOG", "IPCA_QDA"];
%load feats_for_crossval_testing.mat
K=10;
kfold_index = crossvalind('Kfold',K,K); % creates an array where each number 
    % is the file number that is to be held out for testing, and the
    % remaining numbers are for training the model.
accuracy=0;
% First, pull out the features for these two classes...
mask=logical(zeros(size(labels{1})));
mask(find(labels{1}==classes(1)))=1;
mask(find(labels{1}==classes(2)))=1;
twoclassfeats=feat_matrix(mask,:);
twoclasslabels=labels{1}(mask);  % the two actual class names of the observations
twoclassfilenums=labels{2}(mask);  % the file number (1-10) for the observations

for k=1:length(kfold_index)
    % create a matrix for test features, and a cell array for test classes
    testmask=logical(zeros(size(twoclasslabels)));
    testmask=(testmask | (twoclassfilenums==kfold_index(k))); 
    X_test=twoclassfeats(testmask,:);
    Y_test=twoclasslabels(testmask);
    
    trainingmask=logical(zeros(size(twoclasslabels)));
    trainingmask=(trainingmask | (twoclassfilenums~=kfold_index(k)));
    X_train=twoclassfeats(trainingmask,:); % training features
    Y_train=twoclasslabels(trainingmask); % training labels
    
        % apply PCA to training data
    proj = ipca(X_train, 0.9);
    Xp_train = X_train * proj;
    Xp_test  = X_test * proj;
    
    % train a quadratic discriminant model
    %model = fitcdiscr(Xp_train, Y_train, 'DiscrimType', 'quadratic');
    model = fitclinear(Xp_train, Y_train, 'Learner', 'logistic');
    
    % use model to generate predictions on test data
    performance = classperf(twoclasslabels);
    predicted = predict(model, Xp_test);
    classperf(performance, predicted, testmask);;
    accuracy=accuracy+performance.CorrectRate;
end
overallaccuracy=accuracy/10;
disp(sprintf('10-fold accuracy = %f',overallaccuracy))