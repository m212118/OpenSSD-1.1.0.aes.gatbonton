%% Header
close all;  % close old figures
tic;        % start timer

% relevant directories
code_dir = '/home/tkirk/Research/code/classification';
data_dir = '/home/tkirk/Research/data/test_1';
work_dir = '/home/tkirk/Research/work/test_1';
classes = ["000f", "010g", "040h", "070h", "0309"];
datafile = [work_dir, '/features.mat'];

% generate feature matrix if it doesn't exist
if( ~exist('feat_matrix','var') || ~exist('labels','var') )
   if exist(datafile, 'file')
       load(datafile);
   else
       [feat_matrix, labels] = GenerateFeatureMatrix( classes, data_dir );
       save(datafile, 'feat_matrix', 'labels');
   end
end

% dimensional information of dataset
k = length(classes);
n = size(feat_matrix, 1);
p = size(feat_matrix, 2);

%% Evaluate Performance of Selected Classifiers
report_pfda_qda = CrossValTest(feat_matrix, labels{1}, @model_PFDA_QDA);

%% Footer
toc;    % stop timer