function [feat_matrix, labels] = GenerateFeatureMatrix( classes, topdir )

  feat_matrix = zeros(0, 300);
  labels      = cell(1,3);

  for i = 1:length(classes)
        
    % get all relevant files from class file directory
     filelist = FindFiles([topdir, '/', char(classes(i))]);

    % for each file, compute the feature matrix for that file
    for j = 1:size(filelist,1)

      % load the file and create a feature matrix
      file = [filelist(j).folder, '/', filelist(j).name];
      %disp(sprintf('in GenerateFeatureMatrix, file = %s',file));
      file_feat = Raw2FeatureMatrix(file,@FeaturesA);
      %file_feat = Raw2FeatureMatrix(file, @TrimTailsDenoise, @FeaturesA);

      % create a cell array for these features and annotate with labels
      file_label = cell(1,2);
      file_label{1} = repmat(classes(i), size(file_feat,1), 1); % this file's class
      file_label{2} = j * ones(size(file_feat,1),1);  % file number for this class

      % concatenate file's data with global feature and label sets
      feat_matrix = vertcat(feat_matrix, file_feat);
      labels{1}   = vertcat(labels{1}, file_label{1});
      labels{2}   = vertcat(labels{2}, file_label{2});

      % report the number of events processed from a file
%         fprintf('%d events created from %s\n', size(file_feat,1),...
%            filelist(j).name);

    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filelist = FindFiles(in_dir)
  filelist = dir(in_dir);
  delete = [];
  for i = 1:length(filelist)
    if ~contains( filelist(i).name, '.mat' )
      delete = horzcat(delete, i);
    end
  end
  filelist(delete) = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function feat_matrix = Raw2FeatureMatrix( file, CreateFeatures )
% Ch #1 - load file, grab the relevant signal, and dump file data
feat_matrix=[];
%disp(sprintf('In Raw2FeatureMatrix, file = %s, pausing...',file))

%load(file,recordernum)
try
    RecorderData = load( file );
    signal=RecorderData.Samples;
    clear recordernum;
    
    % generate feature matrix with CreateFeatures function handle
    feat_matrix = CreateFeatures(signal);
    %disp('pausing...'),pause
catch
     [~,name,~] = fileparts(file);
     fprintf('MATLAB cannot load file %s.mat, ignoring...\n',name)
 end

end
