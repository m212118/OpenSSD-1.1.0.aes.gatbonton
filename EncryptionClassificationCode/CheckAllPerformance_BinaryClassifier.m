%% Header
global K
% relevant directories
code_dir = '/Volumes/GoogleDrive/Shared drives/SSD Research/Ives/BigTest/EncryptionClassificationCode';

data_dir='/Volumes/GoogleDrive/Shared drives/SSD Research/McDowell_Jasmine_AES/Large Test 7-29-19/Big_AES_test/Input_Ones';
%data_dir='/Volumes/GoogleDrive/Shared drives/SSD Research/McDowell_Jasmine_AES/Large Test 7-29-19/Big_AES_test/Input_Zeros';
%data_dir='/Volumes/GoogleDrive/Shared drives/SSD Research/McDowell_Jasmine_AES/Large Test 7-29-19/Big_AES_test/Random_Input_File';

%data_dir='/Volumes/GoogleDrive/Shared drives/SSD Research/McDowell_Jasmine_AES/Ives Test-Input 1s-key 0s';

work_dir = data_dir;

% different classes to compare
classes = ["Key_0s", "Key_1s", "Key_0101", "Key_1010", "Key_half0_half1", "Key_half1_half0", "Key_Rand1", "Key_Rand2"];
%classes = ["class1","class2"];
classifier1=["IPCA_LOG", "IPCA_QDA"];
%classifier1 = ["FDAR_LOG","FDAR_QDA","IPCA_LOG","IPCA_QDA","PFDA_LOG","PFDA_QDA"];
%classifier1 = ["SVM"];
%classifier1 = [];
classifier2 = ["FDAR_KNN","IPCA_KNN","PFDA_KNN"];

datafile = strcat(work_dir, "/features.mat");  % used to write out the features mat file
% generate feature matrix if it doesn't exist
% if exist('feat_matrix','var')
%     disp('feat_matrix variable exists')
% end
% if( ~exist('feat_matrix','var') || ~exist('labels','var') )
%    if exist(datafile, 'file')
%        disp('loading feature matrix mat file')
%        load(datafile);
%    else
%        disp('feat_matrix and feature matrix mat file don''t exist, so generating features');
%        [feat_matrix, labels] = GenerateFeatureMatrix( classes,data_dir );
%        save(datafile, 'feat_matrix', 'labels');
%    end
% end

[feat_matrix, labels] = GenerateFeatureMatrix( classes,data_dir );

disp('created features/labels, now pausing...')
pause
% dimensional information of dataset
k = length(classes);
n = size(feat_matrix, 1); % # rows (observations)
p = size(feat_matrix, 2); % # cols (features)

close all;  % close old figures
tic;        % start timer

%% Evaluate the Performance of Each Binary Classification Pair

comb = combnk(classes, 2);

% start with the non-K-Nearest Neighbors
for k=1:length(classifier1)
    disp('--------------------------------------------------------')
    disp(sprintf('\nEvaluating performance, Recorder1 data...Classifier is %s',classifier1(k)))
    
    for i = 1:size(comb,1)
        
        % reduce features to selected classes
        mask = false(n,1);
        for j = 1:size(comb,2)
            mask = mask | strcmp(labels{1}, comb(i,j));
        end
        X = feat_matrix(mask,:); Y = labels{1}(mask);
        
        % report performance of binary classifier on subset of classes
        command=sprintf('performance(i) = CrossValTest(X,Y,@model_%s);', classifier1(k));
        try
        eval(command);
        fprintf('%s - %s correct classification rate:\t%g\n', ...
            comb{i,1}, comb{i,2}, performance(i).CorrectRate);
        catch
            disp(sprintf('%s vs %s has issues',comb{i,1},comb{i,2}));
        end
    end
end
% Now do all the K-Nearest Neighbor Classifiers over a range of K
for k=1:length(classifier2)
    disp(sprintf('\nEvaluating performance Recorder1 data...Classifier is %s ',classifier2(k)))
    for K=1:2:7
        disp('--------------------------------------------------------')
        disp(sprintf('\n%s, K = %d:',classifier2(k),K));
        for i = 1:size(comb,1)
            
            % reduce features to selected classes
            mask = false(n,1);
            for j = 1:size(comb,2)
                mask = mask | strcmp(labels{1}, comb(i,j));
            end
            X = feat_matrix(mask,:); Y = labels{1}(mask);
            
            % report performance of binary classifier on subset of classes
            try
                command=sprintf('performance(i) = CrossValTest(X,Y,@model_%s);', classifier2(k));
                eval(command);
                fprintf('%s - %s correct classification rate:\t%g\n', ...
                    comb{i,1}, comb{i,2}, performance(i).CorrectRate);
            catch
                disp(sprintf('%s vs %s has issues',comb{i,1},comb{i,2}));
            end
        end
    end
end

%% Footer
toc;    % stop timer