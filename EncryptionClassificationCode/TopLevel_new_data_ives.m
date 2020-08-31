%% Header
global recorder
recorder = 1;
% relevant directories
code_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\BigTest';
% data_dir = 'G:\Team Drives\SSD Research\Walker - Reproduce Johnson Work, 2018-06\test_1';
data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_12\1GB RR (7.9.18) (odds are writes, evens are reads)';
data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_13\Small Sizes (7.12.18, odds are write, evens are reads) (first 20 @ 6KB, then next 20 at 24KB, ...256KB, ...1MB)';
work_dir = data_dir;

classes = ["000F", "010G", "040H", "070H", "0309"];

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
       [feat_matrix, labels] = GenerateFeatureMatrix_new_data( classes,data_dir );
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
disp('Evaluating performance...')
for i = 1:size(comb,1)
    
    % reduce features to selected classes
    mask = false(n,1);
    for j = 1:size(comb,2)
        mask = mask | strcmp(labels{1}, comb(i,j));
    end
    X = feat_matrix(mask,:); Y = labels{1}(mask);
    
    % report performance of binary classifier on subset of classes
%    performance(i) = CrossValTest(X, Y, @model_PFDA_KNN);
try
%     performance(i) = CrossValTest(X, Y, @model_PFDA_QDA);
         performance(i) = CrossValTest(X, Y, @model_FDAR_KNN);
%     fprintf('%s - %s classification error rate:\t%g\n', ...
%         comb{i,1}, comb{i,2}, performance(i).ErrorRate);
    fprintf('%s - %s correct classification rate:\t%g\n', ...
        comb{i,1}, comb{i,2}, performance(i).CorrectRate);
catch ME
    disp(sprintf('%s vs %s comparison had issues',char(comb{i,1}),char(comb{i,2})))
end
end

%% Footer
toc;    % stop timer