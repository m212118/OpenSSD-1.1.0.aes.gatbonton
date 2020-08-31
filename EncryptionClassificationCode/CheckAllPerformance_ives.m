%% Header
global threshold
threshold = 0.00;
global recorder
recorder = 1;
global K
% relevant directories
clc % clear command window
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
disp('Binary Classifiers')
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
code_dir = pwd;
data_dir = 'G:\Shared drives\SSD Research\Sinsley_AES_KeyClassification\Sinsley_AES_collect';
work_dir = code_dir;

classes=["Key_1", "Key_2"];
classifier1 = ["FDAR_LOG","FDAR_QDA","IPCA_LOG","IPCA_QDA","PFDA_LOG","PFDA_QDA"];
classifier2 = ["FDAR_KNN","IPCA_KNN","PFDA_KNN"];

datafile = strcat(work_dir, "\features.mat");
% generate feature matrix if it doesn't exist
if exist('feat_matrix','var')
    disp('feat_matrix variable exists')
end
if( ~exist('feat_matrix','var') || ~exist('labels','var') )
   if exist(datafile, 'file')
       disp('loading feature matrix mat file')
       load(datafile);
   else
       disp('feat_matrix and feature matrix mat file don''t exist, so generating features');
       [feat_matrix, labels] = GenerateFeatureMatrix( classes,data_dir );
       save(datafile, 'feat_matrix', 'labels');
   end
end

% dimensional information of dataset
k = length(classes);
n = size(feat_matrix, 1);
p = size(feat_matrix, 2);

close all;  % close old figures
tic;        % start timer

%% Evaluate the Performance of Each Binary Classification Pair

comb = combnk(classes, 2);

% start with the non-K-Nearest Neighbors
for k=1:length(classifier1)
    disp('--------------------------------------------------------')
    fprintf('\nEvaluating performance Recorder %d...Classifier is %s (threshold on TrimTails = %g)\n',recorder,classifier1(k),threshold)
    
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
            fprintf('%s vs %s has issues',comb{i,1},comb{i,2});
        end
    end
end
% Now do all the K-Nearest Neighbor Classifiers over a range of K
for k=1:length(classifier2)
    fprintf('\nEvaluating performance Recorder %d...Classifier is %s (threshold on TrimTails = %g)\n',recorder,classifier2(k),threshold)
    for K=1:2:7
        disp('--------------------------------------------------------')
        fprintf('\n%s, K = %d:\n',classifier2(k),K);
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
                fprintf('%s vs %s has issues',comb{i,1},comb{i,2});
            end
        end
    end
end

%% Footer
toc;    % stop timer