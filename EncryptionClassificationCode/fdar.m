function discrim_basis = fdar(data, label)

    classes = unique(label); % get a list of all classes
    p = size(data,2); k = length(classes); n = size(data,1);
    discrim_basis = zeros(size(data,2), length(classes)-1);

    % allocate memory space for class data
    Sw = zeros(p); Sb = zeros(p);
    mask  = zeros(n, k);
    num   = zeros(1, k);
    mu    = zeros(k, p);
    sigma = zeros(p, p, k);
    
    % compute class means and covariance matrices
    for i = 1:length(classes)
       tmask        = strcmp(label, classes(i));
       num(i)       = sum(tmask);
       mu(i,:)      = mean(data(tmask,:));
       sigma(:,:,i) = cov(data(tmask,:));
       mask(:,i)    = tmask;
    end

    % mean of all data
    mu2 = sum( num' .* mu ) / sum(num);
    
    % within class scatter matrix
    for i = 1:k; Sw = Sw + (num(i) - 1) * sigma(:,:,i); end
    
    % between class scatter matrix
    for i = 1:k; Sb = Sb + num(i) * QuadMat(mu(i,:), mu2); end
    
    % find most relevant real eigenvector solution
    [V,~] = eig(Sw\Sb);
    discrim_basis = real(V(:,1:k-1));

end

function result = QuadMat(k, g)
   v = k - g;
   result = v' * v;
end
