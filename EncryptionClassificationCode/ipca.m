function C = ipca(data, var)

  % normalize training data before Prinpical Component Analysis
  set_mean = mean(data);
  data = data - repmat(set_mean, size(data,1), 1);

  % Principal Component Analysis
  [C, ~, E] = pca(data);

  % Find the minimum number of principal components to retain in order
  % to capture 'var' variance of the data set
  for i = 1:size(E,1)
    var_ratio = sum(E(1:i)) / sum(E);
    if (var_ratio > var)
      D = i;
      break;
    end
  end

  % Reduce the data set to the 1st D principal components
  C = C(:,1:D);
end