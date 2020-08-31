%% Header
global threshold
threshold = 0.0;
global recorder
recorder = 1;
global K
clc  % Clear command window
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
disp('MultiClass Classifiers')
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
% relevant directories
code_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\BigTest';
%data_dir = 'G:\Team Drives\SSD Research\Walker - Reproduce Johnson Work, 2018-06\test_1';
%data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_06 (Read Only)';
%data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_12\1GB RR (7.9.18) (odds are writes, evens are reads)';
%data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_13\Small Sizes (7.12.18, odds are write, evens are reads) (first 20 @ 6KB, then next 20 at 24KB, ...256KB, ...1MB)';
%data_dir='C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_13\Small Sizes (7.12.18, odds are write, evens are reads) (first 20 @ 6KB, then next 20 at 24KB, ...256KB, ...1MB)';
%data_dir='C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_15\1GB RR w  400mA Span (7.17.18) (2 channels) (odds W, evens R)';
%data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_03';
%data_dir = 'D:\SSD Data\Crucial M4 Data\Noise (7.10.18)';
data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_18\Greedy-Malware 20 trials';
work_dir = data_dir;

classes = ["000F", "010G", "040H", "070H", "0309"];
classifier1 = ["FDAR_LOG","FDAR_QDA","IPCA_LOG","IPCA_QDA","PFDA_LOG","PFDA_QDA"];
%classifier1 = ["SVM"];
%classifier1 = [];
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
       %[feat_matrix, labels] = GenerateFeatureMatrixUseSSDForWallStartStop_FindRead( classes,data_dir );
       %[feat_matrix, labels] = GenerateFeatureMatrixUseSSDForWallStartStop_FindActivity( classes,data_dir );
       [feat_matrix, labels] = GenerateFeatureMatrix_new_data( classes,data_dir );
       save(datafile, 'feat_matrix', 'labels');
   end
end

close all;  % close old figures
tic;        % start timer

% start with the non-K-Nearest Neighbors
index=1;
for k=1:length(classifier1)
    disp('--------------------------------------------------------')
    disp(sprintf('\nEvaluating performance Recorder %d...Classifier is %s (threshold on TrimTails = %g)',recorder,classifier1(k),threshold))
    
    % report performance of binary classifier on subset of classes
    command=sprintf('performance(index) = CrossValTest(feat_matrix,labels{1},@model_%s);', classifier1(k));

    try
        eval(command);     
        fprintf('Correct classification rate:\t%g\n',performance(index).CorrectRate);
    catch
        disp(sprintf('Cannot classify: has issues'));
    end
    index=index+1;
end
% Now do all the K-Nearest Neighbor Classifiers over a range of K
for k=1:length(classifier2)
    disp(sprintf('\nEvaluating performance Recorder %d...Classifier is %s (threshold on TrimTails = %g)',recorder,classifier2(k),threshold))
    for K=1:2:7
        disp('--------------------------------------------------------')
        disp(sprintf('\n%s, K = %d:',classifier2(k),K));
        
        % report performance of binary classifier on subset of classes
        try
            command=sprintf('performance(index) = CrossValTest(feat_matrix,labels{1},@model_%s);', classifier2(k));
            eval(command);
            fprintf('Correct classification rate:\t%g\n',performance(index).CorrectRate);
        catch
            disp(sprintf('Cannot classify: has issues'));
        end
        index=index+1;
        
    end
end

%% Footer
toc;    % stop timer