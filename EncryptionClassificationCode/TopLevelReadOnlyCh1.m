%% Header
global recorder % recorder number
global threshold % threshold used in preprocessing signal
% relevant directories
code_dir = 'G:\Team Drives\SSD Research\Walker - Reproduce Johnson Work, 2018-06\ssd_research-master_Johnsonv2-Walker-Ives\classification';
% data_dir = 'G:\Team Drives\SSD Research\Walker - Reproduce Johnson Work, 2018-06\test_1';
%work_dir = 'G:\Team Drives\SSD Research\Walker - Reproduce Johnson Work, 2018-06\ssd_research-master_Johnsonv2-Walker\Walker\work';

%  data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_6 (Read Only)';
%  work_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_6 (Read Only)';
%  data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_7 (Read Only)';
%  work_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_7 (Read Only)';
 
 %data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_8';
 data_dir = 'C:\Users\ivesr\Documents\Research\Comp Eng 2018\test_12\1GB RR (7.9.18) (odds are writes, evens are reads)';
 work_dir = data_dir;

 featurefile=[data_dir '\features.mat'];

% work_dir = strcat(work_dir, "\features");
classes = ["000F", "010G", "040H", "070H", "0309"];
% datafile = strcat(work_dir, "\features.mat");
% generate feature matrix if it doesn't exist
disp('right here')
if( ~exist('feat_matrix','var') || ~exist('labels','var') )
    disp('feature matrix and labels must be reloaded or recomputed')
   if exist(featurefile, 'file')
       load(featurefile);
       disp('loaded feature and labels file...')
   else
       disp('generating features and labels...')
       [feat_matrix, labels] = GenerateFeatureMatrixReadOnlyCh1( classes, data_dir);
       save(featurefile, 'feat_matrix', 'labels');
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

for i = 1:size(comb,1)
    
    % reduce features to selected classes
    mask = false(n,1);
    for j = 1:size(comb,2)
        mask = mask | strcmp(labels{1}, comb(i,j));
    end
    X = feat_matrix(mask,:); Y = labels{1}(mask);
    
    % report performance of binary classifier on subset of 
    %disp('KNN Performance');
    performance(i) = CrossValTest(X, Y, @model_PFDA_KNN);

%    disp('PFDA_QDA Performance')
%    performance(i) = CrossValTest(X, Y, @model_IPCA_QDA);
%     fprintf('%s - %s classification error rate:\t%g\n', ...
%         comb{i,1}, comb{i,2}, performance(i).ErrorRate);
    fprintf('%s - %s classification correct rate:\t%g\n', ...
        comb{i,1}, comb{i,2}, performance(i).CorrectRate);
end

save performance.mat performance
%% Footer
toc;    % stop timer